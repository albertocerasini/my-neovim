-- Interfaccia: suggerimenti dei tasti, tabline, guide di indentazione, markdown.
return {
  -- ── which-key: il popup con i suggerimenti dei tasti ───────────────────
  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    opts = {
      preset = 'modern',
      delay = 200,
      icons = { mappings = vim.g.have_nerd_font },

      -- I gruppi mostrati nel popup. Le singole keymap vivono in
      -- lua/config/keymaps.lua e portano con sé la propria `desc`.
      spec = {
        { '<leader>a', group = 'AI / Copilot', icon = '󰚩 ' },
        { '<leader>b', group = 'Buffer', icon = '󰓩 ' },
        { '<leader>c', group = 'Codice / LSP', icon = ' ', mode = { 'n', 'v' } },
        { '<leader>d', group = 'Debug', icon = ' ' },
        { '<leader>D', group = 'Database', icon = ' ' },
        { '<leader>f', group = 'Find / File', icon = ' ', mode = { 'n', 'v' } },
        { '<leader>g', group = 'Git', icon = ' ', mode = { 'n', 'v' } },
        { '<leader>k', group = 'Docker', icon = '󰡨 ' },
        { '<leader>l', group = 'Lazy & Tools', icon = '󰒓 ' },
        { '<leader>r', group = 'Run / Test', icon = ' ' },
        { '<leader>t', group = 'Terminale', icon = ' ' },
        { '<leader>u', group = 'UI / Toggle', icon = '󰙵 ' },
        { '<leader>x', group = 'Diagnostica', icon = ' ' },
        { 'g', group = 'Goto' },
        { ']', group = 'Elemento successivo' },
        { '[', group = 'Elemento precedente' },
      },
    },
  },

  -- ── barbar: la barra dei buffer in alto ────────────────────────────────
  {
    'romgrk/barbar.nvim',
    event = 'VeryLazy',
    dependencies = { 'lewis6991/gitsigns.nvim', 'nvim-tree/nvim-web-devicons' },
    init = function()
      vim.g.barbar_auto_setup = false
    end,
    opts = {
      animation = false,
      auto_hide = false,
      clickable = true,
      -- Lascia spazio all'explorer quando è aperto.
      sidebar_filetypes = {
        NvimTree = { text = 'Explorer' },
        dbui = { text = 'Database' },
      },
      icons = {
        buffer_index = true,
        diagnostics = {
          [vim.diagnostic.severity.ERROR] = { enabled = true, icon = ' ' },
          [vim.diagnostic.severity.WARN] = { enabled = true, icon = ' ' },
        },
        gitsigns = { added = { enabled = true }, changed = { enabled = true }, deleted = { enabled = true } },
      },
    },
  },

  -- ── Guide di indentazione ──────────────────────────────────────────────
  {
    'lukas-reineke/indent-blankline.nvim',
    event = { 'BufReadPost', 'BufNewFile' },
    main = 'ibl',
    opts = {
      indent = { char = '│' },
      scope = { enabled = true, show_start = false, show_end = false },
      exclude = {
        filetypes = { 'help', 'dashboard', 'lazy', 'mason', 'notify', 'toggleterm', 'NvimTree', 'dbui' },
      },
    },
  },

  -- ── TODO / FIXME evidenziati e ricercabili ─────────────────────────────
  {
    'folke/todo-comments.nvim',
    event = { 'BufReadPost', 'BufNewFile' },
    cmd = { 'TodoTelescope', 'TodoQuickFix' },
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = { signs = false },
  },

  -- ── Anteprima Markdown nel buffer ──────────────────────────────────────
  {
    'MeanderingProgrammer/render-markdown.nvim',
    ft = { 'markdown', 'codecompanion' },
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' },
    opts = {},
  },
}
