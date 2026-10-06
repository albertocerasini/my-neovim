-- Comportamento dell'editor: oggetti testuali, coppie, indentazione, progetti.
return {
  -- ── mini.nvim: moduli piccoli e indipendenti ───────────────────────────
  {
    'echasnovski/mini.nvim',
    event = 'VeryLazy',
    config = function()
      -- Oggetti testuali estesi: va) vi) ca" ...
      require('mini.ai').setup { n_lines = 500 }
      -- Aggiungi/cambia/togli parentesi e virgolette: saiw) sd' sr)'
      require('mini.surround').setup()

      local statusline = require 'mini.statusline'
      statusline.setup { use_icons = vim.g.have_nerd_font }
      statusline.section_location = function()
        return '%2l:%-2v'
      end
    end,
  },

  -- ── Chiusura automatica di parentesi e virgolette ──────────────────────
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    opts = { check_ts = true },
  },

  -- ── Chiusura automatica dei tag HTML/JSX/Svelte ────────────────────────
  {
    'windwp/nvim-ts-autotag',
    ft = {
      'html',
      'xml',
      'javascript',
      'javascriptreact',
      'typescript',
      'typescriptreact',
      'svelte',
      'vue',
      'markdown',
      'php',
    },
    opts = {},
  },

  -- ── Rileva tabstop/shiftwidth dal file aperto ──────────────────────────
  {
    'NMAC427/guess-indent.nvim',
    event = { 'BufReadPost', 'BufNewFile' },
    opts = {},
  },

  -- ── Riconoscimento dei progetti (usato da Telescope: <leader>fp) ───────
  {
    'ahmedkhalf/project.nvim',
    event = 'VeryLazy',
    main = 'project_nvim',
    opts = {
      detection_methods = { 'pattern', 'lsp' },
      patterns = {
        '.git',
        'Cargo.toml',
        'package.json',
        'pubspec.yaml',
        'nginx.conf',
        'docker-compose.yml',
        'Makefile',
      },
    },
  },
}
