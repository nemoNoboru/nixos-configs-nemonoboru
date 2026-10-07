{ inputs, config, ... }:
let
  features = config.flake.modules.nixos;
in
{
  flake.nixosConfigurations.nixos = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      features.base
      features.packages
      features.user
      features.ryoku
      features."llm-agents"
      features.steam
      features."home-manager"

      # Host-specific settings. On a fresh install these come from the
      # installer-generated configuration.nix; keep them per-host.
      ({ pkgs, ... }: {
        # systemd-boot EFI boot loader.
        boot.loader.systemd-boot.enable = true;
        boot.loader.efi.canTouchEfiVariables = true;
        boot.kernelPackages = pkgs.linuxPackages_latest;

        networking.hostName = "nixos";
        networking.networkmanager.enable = true;

        time.timeZone = "Europe/Madrid";

        i18n.defaultLocale = "en_US.UTF-8";
        i18n.extraLocaleSettings = {
          LC_ADDRESS = "es_ES.UTF-8";
          LC_IDENTIFICATION = "es_ES.UTF-8";
          LC_MEASUREMENT = "es_ES.UTF-8";
          LC_MONETARY = "es_ES.UTF-8";
          LC_NAME = "es_ES.UTF-8";
          LC_NUMERIC = "es_ES.UTF-8";
          LC_PAPER = "es_ES.UTF-8";
          LC_TELEPHONE = "es_ES.UTF-8";
          LC_TIME = "es_ES.UTF-8";
        };

        # GNOME.
        services.displayManager.gdm.enable = true;
        services.desktopManager.gnome.enable = true;

        services.xserver.xkb = {
          layout = "us";
          variant = "";
        };

        # Printing.
        services.printing.enable = true;

        # PipeWire audio.
        services.pulseaudio.enable = false;
        security.rtkit.enable = true;
        services.pipewire = {
          enable = true;
          alsa.enable = true;
          alsa.support32Bit = true;
          pulse.enable = true;
        };

        programs.firefox.enable = true;

        # The NixOS release this machine was installed with. Never bump.
        system.stateVersion = "26.05";
      })

      ./_hardware-configuration.nix
    ];
  };
}
