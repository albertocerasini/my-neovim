-- ╭─────────────────────────────────────────────────────────────────────────╮
-- │  Neovim — entry point                                                   │
-- ╰─────────────────────────────────────────────────────────────────────────╯
--
-- Struttura della configurazione:
--
--   lua/config/options.lua      opzioni globali (vim.o / vim.opt)
--   lua/config/lazy.lua         bootstrap + setup di lazy.nvim
--   lua/config/autocmds.lua     autocomandi
--   lua/config/keymaps.lua      TUTTE le keymap, raggruppate per funzionalità
--   lua/config/colorscheme.lua  selettore di tema persistente
--
--   lua/plugins/*.lua           un file per area funzionale
--   lua/plugins/lang/*.lua      configurazioni per linguaggio (rust, flutter, web)
--
-- L'ordine sotto conta: le opzioni (leader incluso) vanno impostate prima
-- di caricare i plugin.

require 'config.options'
require 'config.lazy'
require 'config.autocmds'
require 'config.keymaps'
require('config.colorscheme').setup()
