# nixos-config

NixOS configuration for this machine (`nixos`, x86_64-linux, NixOS 26.05), ported
from `/etc/nixos` and kept in git so it can be cloned onto another machine.

## Layout

- `flake.nix` — pinned inputs + `nixosConfigurations.nixos`
- `configuration.nix` — shared system config (GNOME, networking, user, packages)
- `ryoku.nix` — Ryoku desktop settings
- `home-manager.nix` — wires home-manager for the `nixos` user
- `home/` — per-user dotfiles and packages (git, pi skills, nvim, …)
- `hosts/nixos/hardware-configuration.nix` — this machine's hardware scan (per-machine, generated)
- `docs/flakes-setup.md` — steps to enable flakes on NixOS (fresh machines)
- `docs/pi-setup.md` — pi (coding agent) plugins/packages installed on this machine

## Rebuild (this machine)

```bash
cd ~/nixos-config
git add -A
sudo nixos-rebuild switch --flake ~/nixos-config#nixos
git commit -am "describe change" && git push
```

Dry runs: `nix flake check`, `nixos-rebuild build --flake ~/nixos-config#nixos`.

## Home-manager (dotfiles)

Per-user config lives in `home/` (git identity, pi skills, nvim, …) and is applied
as part of every `nixos-rebuild switch`. It is wired in `home-manager.nix`.

- `home/default.nix` — user + imports
- `home/git.nix` — git identity (edit `userName`/`userEmail` before your first commit)
- `home/pi.nix` — symlinks the `nixos-config` pi skill from this repo into `~/.pi/agent/skills`
- `home/nvim.nix` — opt-in: only enable if you want home-manager to own Neovim

Ryoku already manages the desktop dotfiles (nvim/LazyVim, fish, starship,
alacritty, hypr, …). Keep those in Ryoku; use home-manager for the personal layer.
Personal nvim overrides go in `~/.config/nvim/lua/plugins/99-ryoku-user.lua`.

## Reference this flake from /etc/nixos

You don't need a full config in `/etc/nixos` anymore. Two options:

1. **Rebuild straight from home (recommended):**

   ```bash
   sudo nixos-rebuild switch --flake ~/nixos-config#nixos
   ```

2. **Optional shim** so `/etc/nixos` keeps working as a pointer. Create
   `/etc/nixos/flake.nix` with:

   ```nix
   {
     inputs.home-config.url = "path:/home/nixos/nixos-config";
     outputs = { home-config, ... }: {
       nixosConfigurations = home-config.nixosConfigurations;
     };
   }
   ```

   then once run `sudo nix flake lock /etc/nixos` and rebuild with
   `sudo nixos-rebuild switch --flake /etc/nixos#nixos`.

## Clone to another machine

1. Install NixOS normally and reboot.
2. `nix-shell -p git`, then `git clone <your-repo-url> ~/nixos-config`.
3. Generate this machine's hardware scan and add it as a new host:

   ```bash
   mkdir -p ~/nixos-config/hosts/<newname>
   sudo nixos-generate-config --show-hardware-config > ~/nixos-config/hosts/<newname>/hardware-configuration.nix
   ```

4. In `flake.nix`, add a second `nixosConfigurations.<newname>` entry (copy the
   `nixos` one and point its hardware module at `./hosts/<newname>/hardware-configuration.nix`).
5. If you want a different hostname, change `networking.hostName` (see
   `configuration.nix`) or move it into a per-host module.
6. `sudo nixos-rebuild switch --flake ~/nixos-config#<newname>`.

## Push to a remote

```bash
git remote add origin git@github.com:YOURNAME/nixos-config.git
git push -u origin main
```

## Never commit

Secrets, passwords, API keys, Wi-Fi passphrases, private SSH keys. Anything in
`/nix/store` is world-readable. Use `hashedPassword` for user passwords and
sops-nix/agenix for real secrets.
