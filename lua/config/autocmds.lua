-- Autocomandi globali.  `:help autocmd`

local function augroup(name)
  return vim.api.nvim_create_augroup('user_' .. name, { clear = true })
end

-- Evidenzia brevemente il testo copiato.
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Evidenzia il testo copiato',
  group = augroup 'highlight_yank',
  callback = function()
    vim.hl.on_yank()
  end,
})

-- Riapri il file nell'ultima posizione del cursore.
vim.api.nvim_create_autocmd('BufReadPost', {
  desc = 'Ripristina la posizione del cursore',
  group = augroup 'last_location',
  callback = function(event)
    local exclude = { 'gitcommit', 'gitrebase' }
    if vim.tbl_contains(exclude, vim.bo[event.buf].filetype) then
      return
    end
    local mark = vim.api.nvim_buf_get_mark(event.buf, '"')
    local line_count = vim.api.nvim_buf_line_count(event.buf)
    if mark[1] > 0 and mark[1] <= line_count then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Chiudi le finestre "di servizio" con `q`.
vim.api.nvim_create_autocmd('FileType', {
  desc = 'Chiudi le finestre di servizio con q',
  group = augroup 'close_with_q',
  pattern = {
    'help',
    'man',
    'qf',
    'checkhealth',
    'lspinfo',
    'startuptime',
    'notify',
    'dbout',
    'query',
    'fugitive',
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set('n', 'q', '<cmd>close<CR>', { buffer = event.buf, silent = true, desc = 'Chiudi la finestra' })
  end,
})

-- Riequilibra gli split quando la finestra del terminale cambia dimensione.
vim.api.nvim_create_autocmd('VimResized', {
  desc = 'Riequilibra gli split',
  group = augroup 'resize_splits',
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd 'tabdo wincmd ='
    vim.cmd('tabnext ' .. current_tab)
  end,
})

-- Non continuare automaticamente i commenti andando a capo.
vim.api.nvim_create_autocmd('FileType', {
  desc = 'Niente continuazione automatica dei commenti',
  group = augroup 'format_options',
  callback = function()
    vim.opt_local.formatoptions:remove { 'c', 'r', 'o' }
  end,
})

-- Markdown: a capo visivo alla larghezza della finestra, spezzando tra le
-- parole.  Vale solo per la finestra (setlocal): gli altri buffer restano
-- senza wrap.  Toggle: <leader>uw
vim.api.nvim_create_autocmd('FileType', {
  desc = 'A capo visivo nei file Markdown',
  group = augroup 'markdown_wrap',
  pattern = 'markdown',
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
  end,
})

-- Crea le directory mancanti quando salvi un file nuovo.
vim.api.nvim_create_autocmd('BufWritePre', {
  desc = 'Crea le directory mancanti al salvataggio',
  group = augroup 'auto_mkdir',
  callback = function(event)
    if event.match:match '^%w%w+://' then
      return
    end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ':p:h'), 'p')
  end,
})

-- Mostra la diagnostica sotto il cursore dopo `updatetime` ms.
vim.api.nvim_create_autocmd('CursorHold', {
  desc = 'Diagnostica flottante sotto il cursore',
  group = augroup 'diagnostic_float',
  callback = function()
    -- Non aprire un float se ce n'è già uno visibile (es. hover).
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_win_get_config(win).relative ~= '' then
        return
      end
    end
    vim.diagnostic.open_float(nil, {
      focusable = false,
      close_events = { 'BufLeave', 'CursorMoved', 'InsertEnter', 'FocusLost' },
      source = 'if_many',
      prefix = ' ',
      scope = 'cursor',
    })
  end,
})

-- ── 'textwidth' = larghezza della finestra ────────────────────────────────
-- Se nessun language server del buffer sa formattare, `gq` e l'a capo
-- automatico usano il motore interno di Neovim, che va a capo a 'textwidth':
-- lo facciamo coincidere con l'area di testo della finestra, meno una colonna
-- (così il cursore a fine riga non fa scorrere la vista in orizzontale).
-- Un 'textwidth' impostato da altri (ftplugin, editorconfig, a mano: es. 72
-- nei commit) resta il limite se è più stretto.  Con un language server che
-- formatta, il wrapping spetta a lui e 'textwidth' torna a quel valore.

local function lsp_formats(buf)
  for _, method in ipairs { 'textDocument/formatting', 'textDocument/rangeFormatting' } do
    if #vim.lsp.get_clients { bufnr = buf, method = method } > 0 then
      return true
    end
  end
  return false
end

local function fit_textwidth(win)
  if not vim.api.nvim_win_is_valid(win) or vim.api.nvim_win_get_config(win).relative ~= '' then
    return
  end
  local buf = vim.api.nvim_win_get_buf(win)
  local bo, b = vim.bo[buf], vim.b[buf]
  if bo.buftype ~= '' or not bo.modifiable then
    return
  end
  -- Un valore diverso dall'ultimo impostato qui arriva da fuori: è il limite.
  if bo.textwidth ~= (b.textwidth_auto or 0) then
    b.textwidth_limit = bo.textwidth
  end
  local limit = b.textwidth_limit or 0
  local tw = limit
  if not lsp_formats(buf) then
    local info = vim.fn.getwininfo(win)[1]
    local width = math.max(info.width - info.textoff - 1, 1)
    tw = limit > 0 and math.min(limit, width) or width
  end
  b.textwidth_auto = tw
  bo.textwidth = tw
end

--- Stesso calcolo per `buf`: nella finestra corrente se lo mostra, se no nella prima che lo mostra.
local function fit_textwidth_buf(buf)
  local win = vim.api.nvim_get_current_win()
  if vim.api.nvim_win_get_buf(win) ~= buf then
    win = vim.fn.win_findbuf(buf)[1]
  end
  if win then
    fit_textwidth(win)
  end
end

local textwidth_group = augroup 'fit_textwidth'

vim.api.nvim_create_autocmd({ 'BufWinEnter', 'WinEnter' }, {
  desc = "Adatta 'textwidth' alla finestra",
  group = textwidth_group,
  callback = function()
    fit_textwidth(vim.api.nvim_get_current_win())
  end,
})

-- Numeri di riga, segni e fold cambiano la larghezza utile senza WinResized.
vim.api.nvim_create_autocmd('OptionSet', {
  desc = "Adatta 'textwidth' alle colonne laterali",
  group = textwidth_group,
  pattern = { 'number', 'relativenumber', 'signcolumn', 'foldcolumn' },
  callback = function()
    fit_textwidth(vim.api.nvim_get_current_win())
  end,
})

vim.api.nvim_create_autocmd('WinResized', {
  desc = "Adatta 'textwidth' alle finestre ridimensionate",
  group = textwidth_group,
  callback = function()
    for _, win in ipairs(vim.v.event.windows) do
      if vim.api.nvim_win_is_valid(win) then
        fit_textwidth_buf(vim.api.nvim_win_get_buf(win))
      end
    end
  end,
})

vim.api.nvim_create_autocmd({ 'LspAttach', 'LspDetach' }, {
  desc = "Ricalcola 'textwidth' quando cambia il language server",
  group = textwidth_group,
  callback = function(event)
    -- Durante LspDetach il client risulta ancora attaccato: ricalcola dopo.
    vim.schedule(function()
      if vim.api.nvim_buf_is_valid(event.buf) then
        fit_textwidth_buf(event.buf)
      end
    end)
  end,
})

-- ── Titolo della finestra del terminale ───────────────────────────────────
-- Ghostty (come ogni terminale che supporta OSC 2) usa `titlestring` come
-- titolo della finestra: con più progetti aperti si capisce a colpo d'occhio
-- a quale appartiene ogni finestra, anche dal Mission Control di macOS.
-- Il nome del progetto va per primo perché il titolo viene troncato in coda.

--- Radice del progetto del buffer corrente, con fallback su `startup_root`.
local function title_root()
  local buf = vim.api.nvim_get_current_buf()
  local name = vim.api.nvim_buf_get_name(buf)
  if name == '' or name:match '^%w%w+://' then
    return vim.g.startup_root
  end
  local ok, root = pcall(vim.fs.root, buf, {
    '.git',
    'Cargo.toml',
    'package.json',
    'pubspec.yaml',
    'go.mod',
    'Makefile',
  })
  return (ok and root) or vim.g.startup_root
end

local function set_title()
  local title = vim.fn.fnamemodify(title_root(), ':t')
  local modified = ''
  -- Il nome del file solo per i buffer veri: niente terminali, help, ecc.
  if vim.bo.buftype == '' then
    local file = vim.fn.expand '%:t'
    if file ~= '' then
      title = title .. ' — ' .. file
      -- `%( %m%)` aggiunge " [+]" solo quando ci sono modifiche non salvate:
      -- lo valuta Neovim a ogni redraw, senza bisogno di un autocomando.
      modified = '%( %m%)'
    end
  end
  -- `titlestring` è un formato tipo statusline: i '%' letterali vanno protetti.
  vim.o.titlestring = title:gsub('%%', '%%%%') .. modified
end

vim.api.nvim_create_autocmd({ 'VimEnter', 'BufEnter', 'BufWritePost', 'BufFilePost', 'DirChanged' }, {
  desc = 'Titolo della finestra = nome del progetto',
  group = augroup 'window_title',
  callback = set_title,
})

-- ── Riconoscimento di filetype non coperti da Neovim ──────────────────────
vim.filetype.add {
  filename = {
    ['.env'] = 'sh',
    ['nginx.conf'] = 'nginx',
    ['docker-compose.yml'] = 'yaml.docker-compose',
    ['docker-compose.yaml'] = 'yaml.docker-compose',
  },
  pattern = {
    ['%.env%.[%w_.-]+'] = 'sh',
    ['.*/nginx/.*%.conf'] = 'nginx',
    ['.*/sites%-available/.*'] = 'nginx',
    ['.*/sites%-enabled/.*'] = 'nginx',
    ['.*/conf%.d/.*%.conf'] = 'nginx',
  },
  extension = {
    mdx = 'markdown',
  },
}
