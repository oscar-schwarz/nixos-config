{ pkgs, inputs, ... }: {
  imports = [ inputs.nvf.homeManagerModules.default ];

  programs.nvf = {
    enable = true;
    settings = {
      vim = {
        languages = {
          nix.enable = true;
          sql.enable = true;
          ts.enable = true;
          markdown.enable = true;
          html.enable = true;
          php.enable = true;
        };
        lazy.plugins = {
          "telescope.nvim" = {
            package = pkgs.vimPlugins.telescope-nvim; 
          };
          "plenary.nvim" = {
            package = pkgs.vimPlugins.plenary-nvim;
          };
        };
      };
    };
  };
} 