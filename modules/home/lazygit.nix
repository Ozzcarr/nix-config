{ vars, lib, ... }:
let
  accent = "#${vars.colors.base0D}";
  muted = "#${vars.colors.base03}";
in
{
  programs.lazygit = {
    enable = true;
    settings = lib.mkForce {
      disableStartupPopups = true;
      notARepository = "skip";
      promptToReturnFromSubprocess = false;
      os.editPreset = "vscode";
      update.method = "never";
      git = {
        commit.signOff = true;
        parseEmoji = true;
        pagers = [
          {
            colorArg = "always";
            pager = "delta --paging=never";
          }
        ];
      };
      gui = {
        theme = {
          activeBorderColor = [
            accent
            "bold"
          ];
          inactiveBorderColor = [ muted ];
        };
        showListFooter = false;
        showRandomTip = false;
        showCommandLog = false;
        showBottomLine = false;
        nerdFontsVersion = "3";
      };
    };
  };
}
