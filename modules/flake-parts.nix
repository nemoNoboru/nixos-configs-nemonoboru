{ inputs, ... }:
{
  imports = [ inputs.flake-parts.flakeModules.modules ];  # enables flake.modules.*
  systems = [ "x86_64-linux" ];
}
