{
  flake.modules.nixos.user = { pkgs, ... }: {
    users.users.nixos = {
      isNormalUser = true;
      description = "nixos";
      extraGroups = [ "networkmanager" "wheel" ];
      packages = with pkgs; [
        ghostty
        chromium
        lmstudio  # local LLM desktop app (unfree; allowUnfree covers it)
      ];
    };
  };
}
