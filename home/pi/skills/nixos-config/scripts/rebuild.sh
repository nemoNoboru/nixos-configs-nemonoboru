#!/usr/bin/env bash
# Rebuild this machine's NixOS system from a flake.
#
# Usage: rebuild.sh [host] [flake-dir]
#   host      defaults to "nixos" (this machine's hostname)
#   flake-dir defaults to the first existing dir among
#             ~/nixos-config, /etc/nixos, $PWD that contains a flake.nix
#
# The default order puts ~/nixos-config first (the principal config now that it
# has been ported from /etc/nixos), then /etc/nixos, then $PWD. It deliberately
# ignores the stray /home/nixos/flake.nix template.
set -euo pipefail

HOST="${1:-nixos}"
FLAKE_DIR="${2:-}"

if [[ -z "$FLAKE_DIR" ]]; then
  for d in "$HOME/nixos-config" /etc/nixos "$PWD"; do
    if [[ -f "$d/flake.nix" ]]; then
      FLAKE_DIR="$d"
      break
    fi
  done
fi

if [[ -z "$FLAKE_DIR" || ! -f "$FLAKE_DIR/flake.nix" ]]; then
  echo "error: no flake.nix found; pass a flake dir as the 2nd argument" >&2
  exit 1
fi

cd "$FLAKE_DIR"

# Flakes only see git-tracked files. Stage everything first.
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git add -A
  echo "==> staged changes in $FLAKE_DIR"
else
  echo "warning: $FLAKE_DIR is not a git repository (flakes prefer git)" >&2
fi

echo "==> rebuilding .#${HOST} from ${FLAKE_DIR}"
sudo nixos-rebuild switch --flake "${FLAKE_DIR}#${HOST}"

echo "==> done"
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "    next: cd ${FLAKE_DIR} && git commit -am 'describe change' && git push"
fi
