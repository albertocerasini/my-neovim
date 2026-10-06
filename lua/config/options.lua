-- Opzioni globali di Neovim.  `:help option-list`

-- Leader: DEVE essere impostato prima che i plugin vengano caricati.
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Metti a false se il tuo terminale non usa una Nerd Font.
vim.g.have_nerd_font = true

-- Cartella da cui è stato avviato Neovim (l'argomento se è una directory,
-- altrimenti la cwd).  Va letta qui, prima dei plugin: project.nvim sposta poi
-- la cwd sulla radice del buffer corrente.  È la radice dell'explorer.
vim.g.startup_root = (function()
  local first = vim.fn.argv(0)
  local dir = (type(first) == 'string' and vim.fn.isdirectory(first) == 1) and first or vim.uv.cwd()
  return vim.uv.fs_realpath(dir) or dir
end)()

local o = vim.o

-- ── Numeri di riga e cursore ──────────────────────────────────────────────
o.number = true
o.relativenumber = false -- toggle: <leader>ur
o.signcolumn = 'yes'
o.cursorline = true
o.scrolloff = 10
o.wrap = false

-- ── Indentazione ──────────────────────────────────────────────────────────
-- guess-indent.nvim sovrascrive questi valori in base al file aperto.
o.expandtab = true
o.tabstop = 2
o.shiftwidth = 2
o.softtabstop = 2
o.smartindent = true
o.breakindent = true

-- ── Ricerca ───────────────────────────────────────────────────────────────
o.ignorecase = true
o.smartcase = true
o.inccommand = 'split' -- anteprima live di :%s/
o.hlsearch = true

-- ── Split ─────────────────────────────────────────────────────────────────
o.splitright = true
o.splitbelow = true

-- ── File e sessione ───────────────────────────────────────────────────────
o.undofile = true -- undo persistente tra le sessioni
o.confirm = true -- chiedi conferma invece di fallire su :q con modifiche
o.updatetime = 400 -- ritardo di CursorHold (diagnostica sotto il cursore)
o.timeoutlen = 300 -- ritardo di which-key

-- ── Interfaccia ───────────────────────────────────────────────────────────
o.mouse = 'a'
o.showmode = false -- la modalità è già nella statusline
o.termguicolors = true
o.winborder = 'rounded' -- bordo di default per tutte le finestre flottanti
o.pumheight = 12
o.laststatus = 3 -- una sola statusline globale
o.title = true -- il terminale mostra il progetto (titolo in config/autocmds.lua)
o.titlelen = 0 -- niente troncamento del titolo
o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.opt.fillchars = { eob = ' ' }

-- ── Folding (via treesitter, vedi plugins/treesitter.lua) ─────────────────
o.foldlevel = 99
o.foldlevelstart = 99
o.foldenable = true

-- ── Clipboard di sistema (differita: velocizza l'avvio) ───────────────────
vim.schedule(function()
  vim.o.clipboard = 'unnamedplus'
end)

-- ── Provider non usati: meno lavoro all'avvio ─────────────────────────────
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
