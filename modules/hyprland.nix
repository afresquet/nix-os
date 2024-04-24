{ lib, config, pkgs, inputs, ... }: {
  options = {
    hyprland.enable = lib.mkEnableOption "Hyprland";
  };

  config = lib.mkIf config.hyprland.enable {
    # Bootloader.
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    # Enable the X11 windowing system.
    services.xserver.enable = true;

    # Enable SDDM
    services.displayManager.sddm.enable = true;

    # Enable Hyprland
    programs.hyprland = {
      enable = true;
      package = inputs.hyprland.packages."${pkgs.system}".hyprland;
      xwayland.enable = true;
    };

    xdg.portal.enable = true;
  };
}
