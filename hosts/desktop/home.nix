{ ... }: {
  imports = [
    ./../../home
  ];

  # Programs
  alacritty.enable = true;
  direnv.enable = true;
  git.enable = true;
  helix.enable = true;
  mako.enable = true;
  waybar.enable = true;
  wlogout.enable = true;
  wpaperd.enable = true;

  # Shells
  carapace.enable = true;
  starship.enable = true;
  zoxide.enable = true;
}

