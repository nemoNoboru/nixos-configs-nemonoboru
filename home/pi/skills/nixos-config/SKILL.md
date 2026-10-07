---
name: nixos-config
description: Manage this machine's NixOS configuration. Use when editing, building, debugging, updating, or replicating the NixOS flake for this host (hostname "nixos", x86_64-linux, NixOS 26.05). Covers nixos-rebuild --flake, the edit/git-add/switch/commit loop, flake-vs-module boundaries, and the dendritic (flake-parts + import-tree) pattern.
---

# NixOS configuration for this machine

You are managing the NixOS config of the very machine you are running on.
Read `references/machine-profile.md` first — it holds host-specific facts
(hostname, hardware, user, inputs, current layout) so you don't re-derive them.

## Core rules (follow always)

1. **Describe, don't mutate.** Edit the flake/modules and rebuild; don't hand-edit
   live `/etc` state as the primary method. Exception: `/etc/nixos/hardware-configuration.nix`
   is generated and per-machine.
2. **Never commit secrets.** Everything in `/nix/store` is world-readable. Use
   `users.users.<name>.hashedPassword` for passwords and sops-nix/agenix for real secrets.
3. **Build before commit** — only working states belong in git history.
4. **`system.stateVersion` is never bumped.** It records the install release
   (26.05 on this machine), not the version you currently run.
5. **Two worlds, one boundary.** Flake level has `inputs`/`outputs`; NixOS module level
   has `pkgs`/`config`/`lib`. Do not mix names. `inputs` is NOT available inside modules
   unless captured by closure (dendritic) or injected via `specialArgs`.
6. **git is mandatory for flakes.** Nix only sees tracked (staged) files. `git add` new
   files before rebuilding or they are silently ignored / reported missing.

## Where things live

- **Principal config: `~/nixos-config/`** (git repo, dendritic) — `flake.nix`,
  `flake.lock`, `modules/` (auto-imported features + `hosts/nixos/`),
  `home/` (home-manager). Ported from `/etc/nixos`; edit here.
- `/etc/nixos/` — optional thin shim pointing at the home flake, or unused.
- Stray junk to ignore: `/home/nixos/flake.nix` and `/home/nixos/nixosconfig/`
  (unrelated template flakes, not the real config).

## Rebuild workflow

Run `scripts/rebuild.sh [host] [flake-dir]` for the standard loop, or by hand:

```bash
cd ~/nixos-config              # principal flake dir
git add -A                     # flakes only see tracked files
sudo nixos-rebuild switch --flake ~/nixos-config#nixos
git commit -am "describe change" && git push
```

Safe dry runs before switching:

```bash
nix flake show
nix flake check
nixos-rebuild build --flake .#nixos
```

Update inputs deliberately: `nix flake update [input]`, then rebuild; revert pins
with `git checkout flake.lock`. Roll back a bad switch with
`sudo nixos-rebuild switch --rollback` or the boot menu.

## When asked to change the config

- Read `references/machine-profile.md` for current facts.
- Make changes in the flake/modules, then rebuild and verify.
- If reorganizing into the dendritic pattern, read `references/dendritic-pattern.md`.
- For errors, check the troubleshooting table in `references/workflow.md`.
