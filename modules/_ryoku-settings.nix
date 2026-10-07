# Managed by ryoku-install.
{ ... }:

{
  programs.ryoku = {
    enable = true;
    defaultCompositor = "hyprland";
    browser = "chromium";
    shell = "fish";
    optionalApps = [
      "prompt"
      "bash-edit"
      "fastfetch"
      "yazi"
      "cli-tools"
      "git-tools"
      "pavucontrol"
      "songrec"
      "openrgb"
      "upscale"
      "localsend"
      "gamescope"
      "gamemode"
      "mangohud"
      "vm"
      "docker"
      "flatpak"
      "go"
      "pytools"
      "mise"
    ];
  };
}
