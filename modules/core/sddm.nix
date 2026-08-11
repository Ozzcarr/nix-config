{ pkgs, config, ... }:
let
  colors = config.stylix.base16Scheme;
  sddm-astronaut = pkgs.sddm-astronaut.override {
    embeddedTheme = "pixel_sakura";
    themeConfig = {
      FormPosition = "left";
      Blur = "4.0";
      HourFormat = "h:mm AP";
      HeaderTextColor = "#${colors.base05}";
      DateTextColor = "#${colors.base05}";
      TimeTextColor = "#${colors.base05}";
      LoginFieldTextColor = "#${colors.base05}";
      PasswordFieldTextColor = "#${colors.base05}";
      UserIconColor = "#${colors.base05}";
      PasswordIconColor = "#${colors.base05}";
      WarningColor = "#${colors.base05}";
      LoginButtonBackgroundColor = "#${colors.base01}";
      SystemButtonsIconsColor = "#${colors.base05}";
      SessionButtonTextColor = "#${colors.base05}";
      VirtualKeyboardButtonTextColor = "#${colors.base05}";
      DropdownBackgroundColor = "#${colors.base01}";
      HighlightBackgroundColor = "#${colors.base05}";
      FormBackgroundColor = "#${colors.base01}";
    };
  };
in
{
  services.displayManager = {
    sddm = {
      package = pkgs.kdePackages.sddm;
      extraPackages = [ sddm-astronaut ];
      enable = true;
      wayland.enable = true;
      theme = "sddm-astronaut-theme";
    };
  };

  environment.systemPackages = [ sddm-astronaut ];
}
