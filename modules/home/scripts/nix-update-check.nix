{ pkgs }:

pkgs.writeShellScriptBin "nix-update-check" ''
  #!${pkgs.bash}/bin/bash
  set -euo pipefail
  export LC_ALL=C  # comm needs sort and snapshot to agree on collation

  flake="''${NIX_FLAKE_DIR:-$HOME/nix-config}"
  host="''${1:-$(${pkgs.coreutils}/bin/uname -n)}"
  cache="''${XDG_CACHE_HOME:-$HOME/.cache}/nix-update"
  status="$cache/status.json"
  work="$cache/work"

  ${pkgs.coreutils}/bin/mkdir -p "$cache"
  tmp="$(${pkgs.coreutils}/bin/mktemp -d)"

  # Every flake source reachable from a lock, so the ones this check pulls in can
  # be handed back to the store instead of accumulating.
  sources() {
    nix eval --impure --json --expr "
      let
        go = depth: f:
          if depth == 0 then []
          else [ f.outPath ]
            ++ builtins.concatMap (go (depth - 1))
                 (builtins.attrValues (builtins.removeAttrs (f.inputs or {}) [ \"self\" ]));
      in go 5 (builtins.getFlake \"$1\")
    " 2>/dev/null | ${pkgs.jq}/bin/jq -r ".[]" | ${pkgs.coreutils}/bin/sort -u
  }

  # A resolve adds flake sources and instantiated derivations. Both are handed
  # back afterwards, so repeated checks do not accumulate; only these two path
  # kinds are ever considered, so a package fetched by anything else is safe.
  snapshot() {
    ${pkgs.coreutils}/bin/ls -1 /nix/store | ${pkgs.gnugrep}/bin/grep -E -- "-source$|\\.drv$" | ${pkgs.coreutils}/bin/sort
  }

  # Runs on every exit path, so a check that fails midway still hands back what
  # it fetched. `nix store delete` refuses anything still referenced or rooted,
  # so a live path can never be taken out.
  cleanup() {
    ${pkgs.coreutils}/bin/rm -rf "$work"
    if [ -s "$tmp/store.before" ]; then
      snapshot > "$tmp/store.after"
      ${pkgs.coreutils}/bin/comm -13 "$tmp/store.before" "$tmp/store.after" \
        | ${pkgs.gnused}/bin/sed "s|^|/nix/store/|" > "$tmp/store.new"
      ${pkgs.coreutils}/bin/comm -23 "$tmp/store.new" "$tmp/keep" > "$tmp/drop" 2>/dev/null || : > "$tmp/drop"
      # Two passes: a source is only releasable once the derivations that
      # reference it are gone.
      if [ -s "$tmp/drop" ]; then
        ${pkgs.findutils}/bin/xargs -a "$tmp/drop" -r nix store delete >/dev/null 2>&1 || true
        ${pkgs.findutils}/bin/xargs -a "$tmp/drop" -r nix store delete >/dev/null 2>&1 || true
      fi
    fi
    ${pkgs.coreutils}/bin/rm -rf "$tmp"
  }
  trap cleanup EXIT

  # Nix fetches from GitHub unauthenticated by default, which shares a 60/hour
  # limit with everything else on the machine. Lend it the gh token.
  token="$(${pkgs.gh}/bin/gh auth token 2>/dev/null || true)"
  if [ -n "$token" ]; then
    export NIX_CONFIG="access-tokens = github.com=$token"
  fi

  # Only the root inputs move on `nix flake update`; every other node follows one
  # of them, so checking the roots is enough to know whether the lock is stale.
  roots='
    .nodes as $n
    | $n.root.inputs
    | to_entries[]
    | select((.value | type) == "string")
    | [ .key,
        ($n[.value].original.owner // ""),
        ($n[.value].original.repo // ""),
        ($n[.value].original.ref // "HEAD"),
        $n[.value].locked.rev,
        ($n[.value].locked.lastModified | tostring) ]
    | @tsv
  '

  write_status() {
    ${pkgs.jq}/bin/jq -n \
      --arg checked "$(${pkgs.coreutils}/bin/date '+%Y-%m-%d %H:%M')" \
      --arg fingerprint "''${1:-}" \
      --arg error "''${2:-}" \
      --argjson stale "''${3:-0}" \
      --argjson total "''${4:-0}" \
      --arg download "''${5:-}" \
      --rawfile inputs "$tmp/behind" \
      --rawfile packages "$tmp/packages" \
      --rawfile added "$tmp/added" \
      '{
         checked: $checked,
         fingerprint: $fingerprint,
         error: $error,
         stale: $stale,
         total: $total,
         download: $download,
         inputs: ($inputs | split("\n") | map(select(length > 0))),
         packages: ($packages | split("\n") | map(select(length > 0))),
         added: ($added | split("\n") | map(select(length > 0)))
       }' > "$status.tmp"
    ${pkgs.coreutils}/bin/mv "$status.tmp" "$status"
  }

  : > "$tmp/behind"; : > "$tmp/packages"; : > "$tmp/added"

  if [ ! -r "$flake/flake.lock" ]; then
    write_status "" "No flake.lock at $flake"
    exit 0
  fi

  # Step 1: ask GitHub for each input's branch head. Metadata only — this never
  # writes to the Nix store.
  total=0
  failed=0
  : > "$tmp/heads"

  while IFS=$'\t' read -r name owner repo ref locked locked_at; do
    [ -n "$name" ] || continue
    total=$((total + 1))

    # gh follows repo renames (danth/stylix -> nix-community/stylix) and uses the
    # authenticated rate limit.
    head="$(${pkgs.coreutils}/bin/timeout 15 ${pkgs.gh}/bin/gh api \
      "repos/$owner/$repo/commits/$ref" \
      --jq '.sha + "\t" + .commit.committer.date' 2>/dev/null || true)"

    if [ -z "$head" ]; then
      failed=$((failed + 1))
      continue
    fi

    sha="''${head%%$'\t'*}"
    when="''${head##*$'\t'}"
    printf '%s\t%s\n' "$name" "$sha" >> "$tmp/heads"

    if [ "$sha" != "$locked" ]; then
      was="$(${pkgs.coreutils}/bin/date -d "@$locked_at" '+%Y-%m-%d' 2>/dev/null || echo '?')"
      printf '%-18s %s (%s) -> %s (%s)\n' \
        "$name" "''${locked:0:7}" "$was" "''${sha:0:7}" "''${when%%T*}" >> "$tmp/behind"
    fi
  done < <(${pkgs.jq}/bin/jq -r "$roots" "$flake/flake.lock")

  stale="$(${pkgs.coreutils}/bin/wc -l < "$tmp/behind")"

  if [ "$failed" -gt 0 ] && [ "$stale" -eq 0 ]; then
    write_status "" "Could not reach GitHub for $failed of $total inputs" 0 "$total"
    exit 0
  fi

  if [ "$stale" -eq 0 ]; then
    write_status "" "" 0 "$total"
    [ -t 1 ] && printf 'All %s flake inputs are up to date.\n' "$total"
    exit 0
  fi

  # Step 2: the package list only needs recomputing when the upstream revisions
  # themselves have moved since the last resolve.
  fingerprint="$(${pkgs.coreutils}/bin/sort "$tmp/heads" | ${pkgs.coreutils}/bin/sha256sum | ${pkgs.coreutils}/bin/cut -c1-16)"
  cached=""
  if [ -r "$status" ]; then
    cached="$(${pkgs.jq}/bin/jq -r '.fingerprint // ""' "$status" 2>/dev/null || true)"
  fi

  if [ "$fingerprint" = "$cached" ]; then
    ${pkgs.jq}/bin/jq -r '.packages[]?' "$status" > "$tmp/packages" 2>/dev/null || true
    ${pkgs.jq}/bin/jq -r '.added[]?' "$status" > "$tmp/added" 2>/dev/null || true
    download="$(${pkgs.jq}/bin/jq -r '.download // ""' "$status" 2>/dev/null || true)"
    write_status "$fingerprint" "" "$stale" "$total" "$download"
    [ -t 1 ] && ${pkgs.coreutils}/bin/cat "$tmp/behind"
    exit 0
  fi

  # Step 3: resolve the package list. The lock is updated on a throwaway copy so
  # the real one is never touched; Nix only evaluates git-tracked files, hence
  # the scratch repo.
  ${pkgs.coreutils}/bin/rm -rf "$work"
  ${pkgs.coreutils}/bin/cp -a "$flake" "$work"
  ${pkgs.coreutils}/bin/rm -rf "$work/.git" "$work/result"
  ${pkgs.git}/bin/git -C "$work" init -q
  ${pkgs.git}/bin/git -C "$work" add -A

  sources "$flake" > "$tmp/keep" || : > "$tmp/keep"
  snapshot > "$tmp/store.before"

  if ! nix flake update --flake "$work" >/dev/null 2>&1; then
    write_status "" "Could not refresh the flake inputs (offline, or GitHub rate limited)" "$stale" "$total"
    exit 0
  fi

  # --dry-run asks the binary cache what the closure would be and prints the
  # paths without realising any of them.
  plan="$(nix build --dry-run --no-link --no-warn-dirty \
    "$work#nixosConfigurations.$host.config.system.build.toplevel" 2>&1 || true)"


  nix-store -qR /run/current-system \
    | ${pkgs.gnused}/bin/sed 's|/nix/store/[a-z0-9]*-||' \
    | ${pkgs.coreutils}/bin/sort -u > "$tmp/cur" || true

  printf '%s\n' "$plan" \
    | ${pkgs.gnugrep}/bin/grep -oE '/nix/store/[a-z0-9]{32}-[^ ]+' \
    | ${pkgs.gnused}/bin/sed -e 's/\.drv$//' -e 's|/nix/store/[a-z0-9]*-||' \
    | ${pkgs.coreutils}/bin/sort -u > "$tmp/new" || true

  ${pkgs.gawk}/bin/awk '
    BEGIN { SEP = ", " }

    # Store path names are name-version where the version is the first
    # dash-separated field that starts with a digit.
    function split_nv(s,   n, a, i, idx) {
      n = split(s, a, "-")
      idx = 0
      for (i = 2; i <= n; i++) if (a[i] ~ /^[0-9]/) { idx = i; break }
      if (idx == 0) { NM = s; VER = ""; return }
      NM = a[1]
      for (i = 2; i < idx; i++) NM = NM "-" a[i]
      VER = a[idx]
      for (i = idx + 1; i <= n; i++) VER = VER "-" a[i]
      sub(/-(bin|dev|lib|man|doc|devdoc|info|data|getent|env|su|out|debug|static|unwrapped)$/, "", VER)
    }

    function push(arr, k, v) {
      if (!(k in arr)) arr[k] = v
      else if (index(SEP arr[k] SEP, SEP v SEP) == 0) arr[k] = arr[k] SEP v
    }

    FNR == NR { split_nv($0); if (VER != "") push(cur, NM, VER); next }

    {
      split_nv($0)
      if (VER == "" || NM == "source") next
      if ((NM in cur) && index(SEP cur[NM] SEP, SEP VER SEP) > 0) next
      push(nw, NM, VER)
    }

    # A long list of superseded versions costs tooltip width without saying
    # anything; past a point only the newest one is worth showing.
    function trim(list,   n, a) {
      if (length(list) <= 30) return list
      n = split(list, a, SEP)
      return "… " a[n]
    }

    END {
      for (k in nw) {
        if (k in cur) print "CHANGED\t" k "\t" trim(cur[k]) " -> " trim(nw[k])
        else print "NEW\t" k "\t" trim(nw[k])
      }
    }
  ' "$tmp/cur" "$tmp/new" | ${pkgs.coreutils}/bin/sort -u > "$tmp/out"

  # GTK hard-wraps tooltip text at 70 columns and no CSS overrides it, so every
  # line has to fit. When it will not, the superseded versions give way first.
  fmt='
    function fit(name, vers,   budget, arrow, to) {
      budget = 69 - (length(name) < 20 ? 20 : length(name)) - 1
      if (length(vers) <= budget) return vers
      arrow = index(vers, " -> ")
      if (arrow > 0) {
        to = substr(vers, arrow + 4)
        if (length(to) + 5 <= budget) return "… -> " to
      }
      return substr(vers, 1, budget - 1) "…"
    }
    { printf "%-20s %s\n", $2, fit($2, $3) }
  '

  ${pkgs.gnugrep}/bin/grep '^CHANGED' "$tmp/out" \
    | ${pkgs.gawk}/bin/awk -F'\t' "$fmt" > "$tmp/packages" || true
  ${pkgs.gnugrep}/bin/grep '^NEW' "$tmp/out" \
    | ${pkgs.gawk}/bin/awk -F'\t' "$fmt" > "$tmp/added" || true

  download="$(printf '%s\n' "$plan" \
    | ${pkgs.gnugrep}/bin/grep -oE '[0-9.]+ [KMG]iB download' | ${pkgs.coreutils}/bin/head -n1 || true)"

  write_status "$fingerprint" "" "$stale" "$total" "$download"

  if [ -t 1 ]; then
    ${pkgs.coreutils}/bin/cat "$tmp/behind"
    printf '\n'
    ${pkgs.coreutils}/bin/cat "$tmp/packages" "$tmp/added"
  fi
''
