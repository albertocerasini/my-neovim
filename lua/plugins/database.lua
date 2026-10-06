-- PostgreSQL (e altri DB) dentro Neovim: vim-dadbod + dadbod-ui.
-- Keymaps nel gruppo <leader>D.
--
-- Le connessioni si aggiungono con <leader>Da, oppure dichiarandole in
-- init.lua / in una variabile d'ambiente, per esempio:
--   vim.g.dbs = { dev = 'postgres://user:pass@localhost:5432/mydb' }
return {
  {
    'kristijanhusak/vim-dadbod-ui',
    dependencies = {
      { 'tpope/vim-dadbod', lazy = true },
      { 'kristijanhusak/vim-dadbod-completion', ft = { 'sql', 'mysql', 'plsql' }, lazy = true },
    },
    cmd = { 'DBUI', 'DBUIToggle', 'DBUIAddConnection', 'DBUIFindBuffer', 'DBUIRenameBuffer', 'DBUILastQueryInfo' },
    init = function()
      vim.g.db_ui_use_nerd_fonts = 1
      vim.g.db_ui_win_position = 'left'
      vim.g.db_ui_winwidth = 36
      vim.g.db_ui_show_database_icon = 1
      vim.g.db_ui_force_echo_notifications = 1
      vim.g.db_ui_execute_on_save = 0 -- <leader>S nel buffer SQL per eseguire
      vim.g.db_ui_save_location = vim.fn.stdpath 'data' .. '/db_ui'
    end,
  },
}
