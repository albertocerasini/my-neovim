return {
  'projekt0n/github-nvim-theme',
  name = 'github-theme',
  lazy = false, -- make sure we load this during startup if it is your main colorscheme
  priority = 1000, -- make sure to load this before all the other start plugins
  config = function()
    require('github-theme').setup {
      -- ...
    }

    -- Theme will be loaded by colorscheme.lua or manually via :Telescope colorscheme
    -- Available variants: github_dark, github_dark_dimmed, github_dark_high_contrast,
    -- github_light, github_light_high_contrast, etc.
  end,
}
