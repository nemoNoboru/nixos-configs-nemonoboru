# Setting up flakes on NixOS

Steps, in order, to enable and use Nix flakes on a NixOS machine — including the
bootstrap on a fresh install where flakes may not be enabled yet.

## 1. Enable flakes (bootstrap)

Flakes are still marked "experimental". Recent NixOS installers pre-enable them in
the generated `configuration.nix`, but if your first `--flake` command errors with
an "experimental" message, enable them one of two ways:

**A. One-off flag (no config change — recommended for the very first switch):**

```bash
sudo nixos-rebuild switch --flake /path/to/config#hostname \
  --option experimental-features 'nix-command flakes'
```

**B. Permanent (classic config, pre-flake):**

Add to `/etc/nixos/configuration.nix`:

```nix
nix.settings.experimental-features = [ "nix-command" "flakes" ];
```

then run `sudo nixos-rebuild switch`.

> This repo already sets `nix.settings.experimental-features` in
> `configuration.nix`, so after your first flake switch, flakes stay enabled
> permanently.

## 2. Know the flake shape

A minimal `flake.nix`:

```nix
{
  description = "My NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";  # or nixos-unstable
  };

  outputs = { nixpkgs, ... }: {
    nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        ./hardware-configuration.nix
      ];
    };
  };
}
```

- `inputs` — where dependencies come from (branches/repos), pinned by `flake.lock`.
- `outputs.nixosConfigurations.<hostname>` — what `nixos-rebuild --flake .#<hostname>` builds.

## 3. Lock the inputs

`flake.lock` records the exact revision and content hash of every input. Generate
it (or let the first build do it automatically):

```bash
nix flake lock
```

Commit `flake.lock` — it is half of what makes the config reproducible.

## 4. Rebuild from the flake

```bash
sudo nixos-rebuild switch --flake /path/to/config#<hostname>
```

`<hostname>` must match an attribute in `nixosConfigurations` (by convention your
`networking.hostName`).

## 5. Make it a git repository (mandatory)

Flakes only see files tracked by git:

```bash
cd /path/to/config
git init
git add -A                 # re-run after adding/editing files, before rebuilding
sudo nixos-rebuild switch --flake .#<hostname>
git commit -m "initial config"
```

Untracked files silently do not exist from the flake's point of view.

## 6. Update inputs

```bash
nix flake update             # all inputs
nix flake update nixpkgs     # just one input
```

Then rebuild. Revert pins with `git checkout flake.lock`. If an update breaks
something: `sudo nixos-rebuild switch --rollback` or pick a previous generation in
the boot menu.

## Useful commands

```bash
nix flake show                            # list this flake's outputs
nix flake check                           # evaluate everything, catch errors early
nix flake metadata                        # resolved inputs + revisions
nixos-rebuild build --flake .#<hostname>  # build without switching (dry run)
```

## Fresh-machine bootstrap (this repo)

1. Install NixOS normally and reboot.
2. Get git and the config:

   ```bash
   nix-shell -p git
   git clone <repo-url> ~/nixos-config
   ```

3. Generate this machine's `hardware-configuration.nix` and add a host entry
   (see the main `README.md`).
4. First switch (flakes not enabled yet — use the one-off flag):

   ```bash
   sudo nixos-rebuild switch --flake ~/nixos-config#<hostname> \
     --option experimental-features 'nix-command flakes'
   ```

After that, `configuration.nix` keeps flakes enabled permanently on the machine.
