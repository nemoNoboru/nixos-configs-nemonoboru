{ ... }:
{
  # pi (the coding agent) is installed system-wide via llm-agents; here we make
  # its *skills* part of this repo so they clone onto other machines.
  #
  # auth.json, sessions/ and models-store.json stay machine-local and are NEVER
  # committed (auth.json holds secrets).
  home.file.".pi/agent/skills/nixos-config".source = ./pi/skills/nixos-config;
}
