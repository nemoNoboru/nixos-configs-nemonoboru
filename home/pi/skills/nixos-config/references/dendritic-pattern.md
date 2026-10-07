# The dendritic pattern (flake-parts + import-tree)

A way to organize a NixOS config so every file except `flake.nix` is a flake-parts
module, files are auto-discovered, and hosts are just lists of features. It pays off
at ≥2 machines and ≥~10 features; for one machine a plain flake is fine.

## Three rules

1. Every Nix file except `flake.nix` is a **flake-parts module** — one file type,
   one calling convention, the same arguments everywhere.
2. Each file implements **one feature across all classes**: the NixOS part and the
   home-manager part of a concept live in one file as `flake.modules.<class>.<feature>`.
3. Files are **discovered automatically** by import-tree; paths carry no meaning to
   Nix. Paths containing a component starting with `_` are skipped.

## The two layers in every feature file

```nix
{ inputs, ... }:                          # OUTER: flake-parts module. Has inputs.
{
  flake.modules.nixos.editor =            # store a NixOS module named "editor"
    { pkgs, ... }:                        # INNER: NixOS module. Has pkgs, config.
    {
      environment.systemPackages = [ pkgs.neovim ];
    };

  flake.modules.homeManager.editor =      # same feature, another class
    { ... }: { programs.neovim.defaultEditor = true; };
}
```

The outer function runs once at flake level; the inner function runs inside each
NixOS system that selects it. The inner module is a **closure**: it captures `inputs`
from the outer function, so `specialArgs` disappears.

## Why it works

- `flake-parts` applies the module system to the flake itself. Its optional
  `flakeModules.modules` adds `flake.modules.<class>.<name>`, a merged option that
  stores lower-level modules by class and name.
- `import-tree` (`github:vic/import-tree`) recursively imports every `.nix` file in a
  directory, skipping `_`-prefixed path components.

## Target layout

```text
~/nixos-config/
├── flake.nix                       entry point (never grows)
├── flake.lock                      pinned versions (generated)
└── modules/                        auto-imported by import-tree
    ├── flake-parts.nix             imports flake-parts.flakeModules.modules; sets systems
    ├── base.nix                    feature: every machine gets this
    ├── ryoku.nix                   feature: Ryoku desktop
    ├── _ryoku-settings.nix         (skipped: plain NixOS module)
    ├── llm-agents.nix              feature: AI coding tools
    └── hosts/
        └── nixos/
            ├── default.nix         host: list of features
            ├── _configuration.nix  (skipped: old config, extracted over time)
            └── _hardware-configuration.nix (skipped)
```

`flake.nix` stays tiny:

```nix
{
  inputs = {
    nixpkgs.url     = "github:NixOS/nixpkgs/nixos-26.05";
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
    llm-agents.url  = "github:numtide/llm-agents.nix";
    ryoku.url       = "github:aethctl/Ryoku-on-NixOS/main";
  };
  outputs = inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);
}
```

Host file (`modules/hosts/nixos/default.nix`):

```nix
{ inputs, config, ... }:
let features = config.flake.modules.nixos;
in {
  flake.nixosConfigurations.nixos = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      features.base
      features.ryoku
      features.llm-agents
      ./_configuration.nix
      ./_hardware-configuration.nix
    ];
  };
}
```

## Migration from the current /etc/nixos state

1. `sudo cp -r /etc/nixos ~/nixos-config && sudo chown -R $USER:users ~/nixos-config`
2. `cd ~/nixos-config && git init`
3. Create `flake.nix` (above) and `modules/flake-parts.nix`
   (`imports = [ inputs.flake-parts.flakeModules.modules ]; systems = [ "x86_64-linux" ];`).
4. Move old files under `modules/`, prefixing plain NixOS modules with `_` so
   import-tree skips them: `configuration.nix → modules/hosts/nixos/_configuration.nix`,
   `hardware-configuration.nix → _hardware-configuration.nix`, `ryoku.nix → modules/_ryoku-settings.nix`.
5. Write feature files (`base.nix`, `ryoku.nix`, `llm-agents.nix`) and the host file.
6. **Required edit:** remove `./hardware-configuration.nix` from `_configuration.nix`'s
   `imports` (the host file imports it now).
7. `git add -A && sudo nixos-rebuild switch --flake ~/nixos-config#nixos`, then commit.

## Costs and mitigations

- Extra abstraction layer → only two layers; every file reads the same once seen.
- Two extra inputs (flake-parts, import-tree) → small and widely used.
- "Where is X defined?" has no path convention → name files after features; use `grep`/`rg`.
- Overkill for one never-changing machine → true; pays off at the second machine.

## Alternative worth knowing

snowfall-lib (`github:snowfallorg/lib`) solves the same auto-discovery problem via
directory conventions (`modules/`, `hosts/`, `packages/`, `systems/`) instead of
import-tree + `flake.modules.*`. It is the more widely adopted route; consider it
before committing to import-tree.

## Glossary (quick)

- **Store** — `/nix/store`, immutable, hash-named artifacts.
- **Derivation** — build recipe; evaluation produces it, realisation produces the store path.
- **Closure** — (store) a path + everything it references; (language) a function capturing
  variables from where it was defined.
- **Generation** — one built system version; switching/rollback move a symlink between them.
- **Module** — unit of config: a function returning `imports`, `options`, `config`.
- **Class** — which module system a module targets: nixos, homeManager, darwin, flake.
- **flake-parts** — module system applied to the flake itself.
- **import-tree** — imports every `.nix` under a directory, skipping `_`-prefixed paths.
- **Dendritic pattern** — every file a flake-parts module, organized by feature, auto-imported;
  hosts are lists of features.
