-- Temi disponibili nel selettore (<leader>uc).
-- Devono restare non-lazy: Telescope li elenca solo se sono nel runtimepath.
-- Per aggiungerne uno basta appenderlo a questa lista.
return {
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    lazy = false,
    priority = 1000,
    opts = {
      flavour = 'mocha', -- latte, frappe, macchiato, mocha
      transparent_background = false,
      integrations = {
        blink_cmp = true,
        gitsigns = true,
        mason = true,
        native_lsp = { enabled = true, inlay_hints = { background = true } },
        nvim_tree = true,
        telescope = { enabled = true },
        treesitter = true,
        which_key = true,
        dap = true,
        dap_ui = true,
        indent_blankline = { enabled = true },
        render_markdown = true,
      },
    },
  },

  {
    'folke/tokyonight.nvim',
    lazy = false,
    priority = 1000,
    opts = {
      styles = { comments = { italic = false } },
    },
  },

  {
    'projekt0n/github-nvim-theme',
    name = 'github-theme',
    lazy = false,
    priority = 1000,
    config = function()
      require('github-theme').setup {}
    end,
  },
}
