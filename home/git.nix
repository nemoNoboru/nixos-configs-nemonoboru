{ ... }:
{
  programs.git = {
    enable = true;
    # TODO: set your identity before the first commit.
    settings = {
      user = {
        name = "nixos";
        email = "nixos@localhost";
      };
      init = {
        defaultBranch = "main";
      };
      pull = {
        rebase = true;
      };
    };
  };
}
