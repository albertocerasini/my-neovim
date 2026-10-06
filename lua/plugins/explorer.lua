-- File explorer laterale.  <leader>e apre/chiude, <leader>E mostra il file corrente.
--
-- La radice è sempre `vim.g.startup_root` (vedi config/options.lua e le keymap
-- in config/keymaps.lua): project.nvim sposta la cwd sulla radice del progetto
-- del buffer corrente, quindi l'albero non deve seguirla.
return {
  'nvim-tree/nvim-tree.lua',
  version = '*',
  lazy = false,
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  opts = {
    sort = { sorter = 'case_sensitive' },
    view = { width = 36, preserve_window_proportions = true },
    renderer = {
      group_empty = true,
      highlight_git = true,
      indent_markers = { enable = true },
    },
    filters = {
      dotfiles = false,
      git_ignored = false,
      custom = { '^%.git$', '^node_modules$', '^%.dart_tool$' },
    },
    git = { enable = true, ignore = false },
    diagnostics = { enable = true, show_on_dirs = true },
    actions = { open_file = { quit_on_open = false, window_picker = { enable = true } } },
    -- Segui il file aperto nell'albero, ma senza mai spostarne la radice.
    update_focused_file = { enable = true, update_root = { enable = false } },
    sync_root_with_cwd = false, -- :cd e project.nvim non cambiano la radice
    respect_buf_cwd = false,
  },
}
