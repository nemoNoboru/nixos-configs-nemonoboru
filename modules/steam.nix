{
  flake.modules.nixos.steam = {
    # Steam (see https://wiki.nixos.org/wiki/Steam).
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;   # Steam Remote Play
    };

    # 32-bit graphics libraries needed by many Steam games.
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };
  };
}
