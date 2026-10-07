# OPT-IN. Enable this import in home/default.nix only if you want home-manager to
# own Neovim. Ryoku currently provides a LazyVim starter (~/.config/nvim, marked
# ".ryoku-lazyvim"), so enabling this would conflict with Ryoku's nvim management.
#
# Until then, keep your personal nvim overrides in
#   ~/.config/nvim/lua/plugins/99-ryoku-user.lua
# which Ryoku leaves as a stable user hook.
{ pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    extraConfig = ''
      set number
      set relativenumber
      set cursorline
    '';
  };
}
