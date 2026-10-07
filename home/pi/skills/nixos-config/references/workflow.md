# NixOS workflow, safety, and troubleshooting

## Daily loop

```bash
cd /etc/nixos                  # principal config dir right now
git add -A                     # flakes only see tracked files
sudo nixos-rebuild switch --flake .#nixos
git commit -am "describe change" && git push
```

Build before committing so only working states enter history. If the build fails,
nothing on the system has changed.

## Dry runs (safe, no switch)

```bash
nix flake show
nix flake check
nixos-rebuild build --flake .#nixos
nix eval .#nixosConfigurations.nixos.config.networking.hostName
```

## Updating inputs

```bash
nix flake update                # all inputs
nix flake update llm-agents     # one input
sudo nixos-rebuild switch --flake .#nixos
```

Revert pins with `git checkout flake.lock`. Roll back a broken switch with
`sudo nixos-rebuild switch --rollback` or the boot menu.

## Safety checklist

- **Never commit secrets.** Everything built lands in world-readable `/nix/store`.
  Use `users.users.<name>.hashedPassword` (`mkpasswd`) for passwords; sops-nix or
  agenix for real secrets.
- **Never bump `system.stateVersion`** on an existing machine (26.05 here).
- **Don't hand-edit `hardware-configuration.nix`** — regenerate it instead.
- **Two worlds:** flake level = `inputs`/`outputs`; NixOS module level =
  `pkgs`/`config`/`lib`. `inputs` is not in modules unless captured by closure
  (dendritic) or passed via `specialArgs`.
- **`git add` new files** before rebuild; untracked files don't exist to the flake.

## Troubleshooting

| Error | Cause and fix |
|---|---|
| `cannot find flake 'flake:X' in the flake registries` | `X` appears in `outputs`' args but not in `inputs`. Declare it as an input, or if it is `pkgs`/`lib`/`config`, move that code into a module. |
| `path '…/X.nix' does not exist` | File is not tracked by git. Run `git add`. |
| `The option 'X' does not exist` loading a file under `modules/` | import-tree loaded a plain NixOS module as a flake-parts module. Prefix its name with `_` or wrap in `flake.modules.nixos.<name>`. |
| `attribute 'X' missing` on `config.flake.modules.nixos` | Feature misspelt, file untracked by git, or filename starts with `_`. |
| `The option 'flake.modules' does not exist` | `flake-parts.nix` must import `inputs.flake-parts.flakeModules.modules`. |
| `function … called without required argument 'inputs'` | A NixOS (inner) module asks for `inputs`. Capture it from the outer flake-parts function (closure) or pass `specialArgs`. |
| `infinite recursion encountered` | Usually `imports` computed from `config` inside the *same* module system. Reading from the flake-level `config` is fine. |
| flakes "experimental" error on a fresh machine | Add `--option experimental-features 'nix-command flakes'` once. |

## Useful commands

```bash
nix-collect-garbage -d          # delete old generations, free space
sudo nixos-rebuild switch --rollback
nix flake metadata .            # show resolved inputs
```
