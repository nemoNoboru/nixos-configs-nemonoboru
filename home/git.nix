{ ... }:
{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "nemoNoboru";
        email = "felipetavres@gmail.com";
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
