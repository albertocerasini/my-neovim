-- Telescope: ricerca fuzzy di file, testo, simboli, diagnostica...
-- Le keymap sono in lua/config/keymaps.lua (gruppo <leader>f).
return {
  'nvim-telescope/telescope.nvim',
  cmd = 'Telescope',
  event = 'VeryLazy',
  dependencies = {
    'nvim-lua/plenary.nvim',
    {
      'nvim-telescope/telescope-fzf-native.nvim',
      build = 'make',
      cond = function()
        return vim.fn.executable 'make' == 1
      end,
    },
    'nvim-telescope/telescope-ui-select.nvim',
    { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
  },
  opts = function()
    return {
      defaults = {
        prompt_prefix = '❯ ',
        selection_caret = '❯ ',
        path_display = { 'truncate' },
        sorting_strategy = 'ascending',
        layout_config = {
          horizontal = { prompt_position = 'top', preview_width = 0.55 },
          width = 0.9,
          height = 0.85,
        },
        mappings = {
          i = {
            ['<C-j>'] = require('telescope.actions').move_selection_next,
            ['<C-k>'] = require('telescope.actions').move_selection_previous,
            ['<C-q>'] = require('telescope.actions').send_to_qflist + require('telescope.actions').open_qflist,
            ['<Esc>'] = require('telescope.actions').close,
          },
        },
        file_ignore_patterns = {
          '^%.git/',
          'node_modules/',
          '%.next/',
          'dist/',
          'build/',
          'target/',
          '%.dart_tool/',
          'ios/Runner%.xcassets/',
          '%.lock$',
        },
      },
      pickers = {
        find_files = { hidden = true },
        live_grep = { additional_args = { '--hidden' } },
        buffers = {
          sort_lastused = true,
          mappings = { i = { ['<C-d>'] = require('telescope.actions').delete_buffer } },
        },
        colorscheme = { enable_preview = true },
      },
      extensions = {
        ['ui-select'] = { require('telescope.themes').get_dropdown() },
      },
    }
  end,
  config = function(_, opts)
    local telescope = require 'telescope'
    telescope.setup(opts)
    pcall(telescope.load_extension, 'fzf')
    pcall(telescope.load_extension, 'ui-select')
    pcall(telescope.load_extension, 'projects')
  end,
}
