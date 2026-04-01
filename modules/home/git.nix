{ host, ... }:
let
  inherit (import ../../hosts/${host}/variables.nix) gitUsername gitEmail;
in
{
  programs.git = {
    enable = true;

    settings = {
      user = {
        name = "${gitUsername}";
        email = "${gitEmail}";
      };

      push.default = "simple";
      credential.helper = "cache --timeout=7200";
      init.defaultBranch = "main";
      log.decorate = "full";
      log.date = "iso";
      merge.conflictStyle = "diff3";
      delta.features = "catppuccin-mocha";

      "delta \"catppuccin-mocha\"" = {
        blame-palette = "#1e1e2e #181825 #11111b #313244 #45475a";
        commit-decoration-style = "#6c7086 bold box ul";
        dark = true;
        file-decoration-style = "#6c7086";
        file-style = "#cdd6f4";
        hunk-header-decoration-style = "#6c7086 box ul";
        hunk-header-file-style = "bold";
        hunk-header-line-number-style = "bold #a6adc8";
        hunk-header-style = "file line-number syntax";
        line-numbers-left-style = "#6c7086";
        line-numbers-minus-style = "bold #f38ba8";
        line-numbers-plus-style = "bold #a6e3a1";
        line-numbers-right-style = "#6c7086";
        line-numbers-zero-style = "#6c7086";
        minus-emph-style = "bold syntax #694559";
        minus-style = "syntax #493447";
        plus-emph-style = "bold syntax #4e6356";
        plus-style = "syntax #394545";
        map-styles = "bold purple => syntax \"#5b4e74\", bold blue => syntax \"#445375\", bold cyan => syntax \"#446170\", bold yellow => syntax \"#6b635b\"";
        syntax-theme = "Catppuccin Mocha";
      };

      alias = {
        br = "branch --sort=-committerdate";
        co = "checkout";
        df = "diff";
        com = "commit -a";
        gs = "stash";
        gp = "pull";
        lg = "log --graph --pretty=format:'%Cred%h%Creset - %C(yellow)%d%Creset %s %C(green)(%cr)%C(bold blue) <%an>%Creset' --abbrev-commit";
        st = "status";
      };
    };
  };
}
