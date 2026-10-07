{ inputs, ... }:
{
  flake.modules.nixos.llm-agents = { pkgs, ... }: {
    environment.systemPackages =
      with inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; [
        skills
        codegraph
        tuicr
        annot
        kandev-desktop
        herdr
        pi
        orca
        omp
        nono
        luvus
        sidecar
        td
      ];
  };
}
