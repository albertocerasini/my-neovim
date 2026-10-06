-- ╭─────────────────────────────────────────────────────────────────────────╮
-- │  Keymaps — tutte qui, raggruppate per funzionalità                      │
-- ╰─────────────────────────────────────────────────────────────────────────╯
--
-- Sintassi standard di Neovim: vim.keymap.set(mode, lhs, rhs, { desc = ... })
-- Il campo `desc` è ciò che which-key mostra nel popup dei suggerimenti.
--
-- Prefissi (i gruppi sono dichiarati in lua/plugins/ui.lua):
--
--   <leader>a   AI / Copilot          <leader>l   Lazy & Tools
--   <leader>b   Buffer                <leader>r   Run / Test  (per linguaggio)
--   <leader>c   Codice / LSP          <leader>t   Terminale
--   <leader>d   Debug (DAP)           <leader>u   UI / Toggle
--   <leader>D   Database (SQL)        <leader>x   Diagnostica
--   <leader>f   Find / File
--   <leader>g   Git
--
-- Le mappe locali al buffer (LSP, Rust, Flutter, web, PHP, .NET) sono in fondo
-- al file, nelle funzioni M.lsp() / M.rust() / M.flutter() / M.web() /
-- M.php() / M.dotnet().

local M = {}
local map = vim.keymap.set

-- ── Helper ────────────────────────────────────────────────────────────────

--- Radice del progetto (directory che contiene .git), altrimenti la cwd.
local function project_root()
  return vim.fs.root(0, { '.git', 'Cargo.toml', 'package.json', 'pubspec.yaml' }) or vim.uv.cwd()
end

--- Wrapper pigro su telescope.builtin: il plugin viene caricato solo alla pressione.
local function tb(picker, opts)
  return function()
    require('telescope.builtin')[picker](vim.tbl_extend('force', {}, opts or {}))
  end
end

--- Esegue un comando di shell in un terminale orizzontale (toggleterm).
local function run(cmd)
  return function()
    vim.cmd(('TermExec cmd=%q direction=horizontal'):format(cmd))
  end
end

-- ╭─────────────────────────────────────────────────────────────────────────╮
-- │  Generale                                                               │
-- ╰─────────────────────────────────────────────────────────────────────────╯

map('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Pulisci evidenziazione ricerca' })
map({ 'n', 'i', 'v' }, '<C-s>', '<cmd>write<CR><Esc>', { desc = 'Salva file' })

map('n', '<leader>w', '<cmd>write<CR>', { desc = 'Salva file' })
map('n', '<leader>W', '<cmd>wall<CR>', { desc = 'Salva tutti i file' })
map('n', '<leader>q', '<cmd>confirm quit<CR>', { desc = 'Chiudi finestra' })
map('n', '<leader>Q', '<cmd>confirm qall<CR>', { desc = 'Esci da Neovim' })
map('n', '<leader>?', function()
  require('which-key').show { global = false }
end, { desc = 'Keymaps di questo buffer' })

-- Esci dalla modalità terminale.
map('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Esci dalla modalità terminale' })

-- Mantieni la selezione dopo aver indentato.
map('v', '<', '<gv', { desc = 'Riduci indentazione' })
map('v', '>', '>gv', { desc = 'Aumenta indentazione' })

-- Incolla sopra una selezione senza sovrascrivere il registro.
map('x', 'p', '"_dP', { desc = 'Incolla senza perdere il registro' })

-- Tieni il cursore al centro durante lo scorrimento e la ricerca.
map('n', '<C-d>', '<C-d>zz', { desc = 'Mezza pagina giù (centrata)' })
map('n', '<C-u>', '<C-u>zz', { desc = 'Mezza pagina su (centrata)' })
map('n', 'n', 'nzzzv', { desc = 'Risultato successivo (centrato)' })
map('n', 'N', 'Nzzzv', { desc = 'Risultato precedente (centrato)' })

-- ╭─────────────────────────────────────────────────────────────────────────╮
-- │  Finestre e navigazione                                                 │
-- ╰─────────────────────────────────────────────────────────────────────────╯

map('n', '<C-h>', '<C-w><C-h>', { desc = 'Vai alla finestra a sinistra' })
map('n', '<C-j>', '<C-w><C-j>', { desc = 'Vai alla finestra in basso' })
map('n', '<C-k>', '<C-w><C-k>', { desc = 'Vai alla finestra in alto' })
map('n', '<C-l>', '<C-w><C-l>', { desc = 'Vai alla finestra a destra' })

map('n', '<C-Up>', '<cmd>resize +2<CR>', { desc = 'Ingrandisci in altezza' })
map('n', '<C-Down>', '<cmd>resize -2<CR>', { desc = 'Riduci in altezza' })
map('n', '<C-Left>', '<cmd>vertical resize -4<CR>', { desc = 'Riduci in larghezza' })
map('n', '<C-Right>', '<cmd>vertical resize +4<CR>', { desc = 'Ingrandisci in larghezza' })

-- ╭─────────────────────────────────────────────────────────────────────────╮
-- │  Explorer (nvim-tree)                                                   │
-- ╰─────────────────────────────────────────────────────────────────────────╯

--- Radice da passare a nvim-tree: la cartella di avvio, ma solo se l'albero non
--- ce l'ha già.  Passare `path` ricrea l'albero (e perde le cartelle aperte),
--- quindi lo facciamo solo quando serve davvero, cioè alla prima apertura dopo
--- che project.nvim ha spostato la cwd in una sotto-cartella.
local function tree_root()
  if require('nvim-tree.core').get_cwd() == vim.g.startup_root then
    return nil
  end
  return vim.g.startup_root
end

map('n', '<leader>e', function()
  require('nvim-tree.api').tree.toggle { path = tree_root() }
end, { desc = 'Explorer (apri/chiudi)' })

map('n', '<leader>E', function()
  require('nvim-tree.api').tree.open { path = tree_root(), find_file = true, focus = true }
end, { desc = 'Explorer sul file corrente' })

-- ╭─────────────────────────────────────────────────────────────────────────╮
-- │  <leader>b — Buffer (barbar)                                            │
-- ╰─────────────────────────────────────────────────────────────────────────╯

map('n', '<S-l>', '<cmd>BufferNext<CR>', { desc = 'Buffer successivo' })
map('n', '<S-h>', '<cmd>BufferPrevious<CR>', { desc = 'Buffer precedente' })

map('n', '<leader>bb', '<cmd>BufferPick<CR>', { desc = 'Scegli un buffer' })
map('n', '<leader>bd', '<cmd>BufferClose<CR>', { desc = 'Chiudi buffer' })
map('n', '<leader>bD', '<cmd>BufferClose!<CR>', { desc = 'Chiudi buffer (forza)' })
map('n', '<leader>bo', '<cmd>BufferCloseAllButCurrentOrPinned<CR>', { desc = 'Chiudi gli altri buffer' })
map('n', '<leader>bp', '<cmd>BufferPin<CR>', { desc = 'Fissa/sblocca il buffer' })
map('n', '<leader>bh', '<cmd>BufferMovePrevious<CR>', { desc = 'Sposta il buffer a sinistra' })
map('n', '<leader>bl', '<cmd>BufferMoveNext<CR>', { desc = 'Sposta il buffer a destra' })
map('n', '<leader>bs', '<cmd>BufferOrderByDirectory<CR>', { desc = 'Ordina per directory' })
map('n', '<leader>br', '<cmd>BufferRestore<CR>', { desc = 'Riapri l ultimo buffer chiuso' })

-- ╭─────────────────────────────────────────────────────────────────────────╮
-- │  <leader>c — Codice / LSP  (vedi anche M.lsp() in fondo)                │
-- ╰─────────────────────────────────────────────────────────────────────────╯

map({ 'n', 'v' }, '<leader>cf', function()
  require('conform').format { async = true, lsp_format = 'fallback' }
end, { desc = 'Formatta buffer/selezione' })

-- ╭─────────────────────────────────────────────────────────────────────────╮
-- │  <leader>d — Debug (nvim-dap)                                           │
-- ╰─────────────────────────────────────────────────────────────────────────╯

local function dap(fn, ...)
  local args = { ... }
  return function()
    require('dap')[fn](unpack(args))
  end
end

map('n', '<leader>dc', dap 'continue', { desc = 'Avvia / continua' })
map('n', '<leader>db', dap 'toggle_breakpoint', { desc = 'Breakpoint on/off' })
map('n', '<leader>dB', function()
  vim.ui.input({ prompt = 'Condizione del breakpoint: ' }, function(input)
    if input then
      require('dap').set_breakpoint(input)
    end
  end)
end, { desc = 'Breakpoint condizionale' })
map('n', '<leader>di', dap 'step_into', { desc = 'Step into' })
map('n', '<leader>do', dap 'step_over', { desc = 'Step over' })
map('n', '<leader>dO', dap 'step_out', { desc = 'Step out' })
map('n', '<leader>dr', dap 'restart', { desc = 'Riavvia la sessione' })
map('n', '<leader>dt', dap 'terminate', { desc = 'Termina la sessione' })
map('n', '<leader>dl', dap 'run_last', { desc = 'Riesegui l ultima config' })
map('n', '<leader>dR', function()
  require('dap').repl.toggle()
end, { desc = 'REPL del debugger' })
map('n', '<leader>du', function()
  require('dapui').toggle()
end, { desc = 'Interfaccia del debugger' })
map({ 'n', 'v' }, '<leader>de', function()
  require('dapui').eval()
end, { desc = 'Valuta espressione' })

-- Tasti funzione, comodi durante una sessione di debug.
map('n', '<F5>', dap 'continue', { desc = 'Debug: continua' })
map('n', '<F10>', dap 'step_over', { desc = 'Debug: step over' })
map('n', '<F11>', dap 'step_into', { desc = 'Debug: step into' })
map('n', '<F12>', dap 'step_out', { desc = 'Debug: step out' })

-- ╭─────────────────────────────────────────────────────────────────────────╮
-- │  <leader>D — Database (vim-dadbod-ui / PostgreSQL)                      │
-- ╰─────────────────────────────────────────────────────────────────────────╯

map('n', '<leader>Du', '<cmd>DBUIToggle<CR>', { desc = 'Apri/chiudi la UI del DB' })
map('n', '<leader>Da', '<cmd>DBUIAddConnection<CR>', { desc = 'Aggiungi connessione' })
map('n', '<leader>Df', '<cmd>DBUIFindBuffer<CR>', { desc = 'Trova buffer SQL' })
map('n', '<leader>Dr', '<cmd>DBUIRenameBuffer<CR>', { desc = 'Rinomina buffer SQL' })
map('n', '<leader>Dq', '<cmd>DBUILastQueryInfo<CR>', { desc = 'Info ultima query' })

-- ╭─────────────────────────────────────────────────────────────────────────╮
-- │  <leader>f — Find / File (Telescope)                                    │
-- ╰─────────────────────────────────────────────────────────────────────────╯

map('n', '<leader><leader>', tb 'buffers', { desc = 'Buffer aperti' })
map('n', '<leader>/', function()
  require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, { desc = 'Cerca nel buffer corrente' })

map('n', '<leader>ff', function()
  require('telescope.builtin').find_files { cwd = project_root() }
end, { desc = 'File del progetto' })
map('n', '<leader>fF', function()
  require('telescope.builtin').find_files { cwd = project_root(), hidden = true, no_ignore = true }
end, { desc = 'Tutti i file (nascosti e ignorati)' })
map('n', '<leader>fw', function()
  require('telescope.builtin').live_grep { cwd = project_root() }
end, { desc = 'Cerca testo nel progetto (grep)' })
map('n', '<leader>fW', function()
  require('telescope.builtin').live_grep { grep_open_files = true, prompt_title = 'Grep nei file aperti' }
end, { desc = 'Cerca testo nei file aperti' })
map({ 'n', 'v' }, '<leader>fc', function()
  require('telescope.builtin').grep_string { cwd = project_root() }
end, { desc = 'Cerca la parola sotto il cursore' })
map('n', '<leader>fb', tb 'buffers', { desc = 'Buffer aperti' })
map('n', '<leader>fo', tb 'oldfiles', { desc = 'File recenti' })
map('n', '<leader>fg', tb 'git_files', { desc = 'File tracciati da git' })
map('n', '<leader>fp', '<cmd>Telescope projects<CR>', { desc = 'Progetti' })
map('n', '<leader>fh', tb 'help_tags', { desc = 'Documentazione (:help)' })
map('n', '<leader>fk', tb 'keymaps', { desc = 'Keymaps' })
map('n', '<leader>fm', tb 'marks', { desc = 'Marks' })
map('n', '<leader>fR', tb 'registers', { desc = 'Registri' })
map('n', '<leader>fd', tb 'diagnostics', { desc = 'Diagnostica del progetto' })
map('n', '<leader>fr', tb 'resume', { desc = 'Riprendi ultima ricerca' })
map('n', '<leader>ft', tb 'builtin', { desc = 'Elenco dei picker Telescope' })
map('n', '<leader>fn', function()
  require('telescope.builtin').find_files { cwd = vim.fn.stdpath 'config' }
end, { desc = 'File di configurazione di Neovim' })

-- ╭─────────────────────────────────────────────────────────────────────────╮
-- │  <leader>g — Git (gitsigns + lazygit)                                   │
-- ╰─────────────────────────────────────────────────────────────────────────╯

local function gs(fn, ...)
  local args = { ... }
  return function()
    require('gitsigns')[fn](unpack(args))
  end
end

map('n', '<leader>gg', '<cmd>LazyGit<CR>', { desc = 'LazyGit' })
map('n', '<leader>gG', '<cmd>LazyGitCurrentFile<CR>', { desc = 'LazyGit (file corrente)' })

map('n', ']c', gs('nav_hunk', 'next'), { desc = 'Hunk successivo' })
map('n', '[c', gs('nav_hunk', 'prev'), { desc = 'Hunk precedente' })

map({ 'n', 'v' }, '<leader>gs', gs 'stage_hunk', { desc = 'Stage hunk' })
map({ 'n', 'v' }, '<leader>gr', gs 'reset_hunk', { desc = 'Reset hunk' })
map('n', '<leader>gS', gs 'stage_buffer', { desc = 'Stage del buffer' })
map('n', '<leader>gR', gs 'reset_buffer', { desc = 'Reset del buffer' })
map('n', '<leader>gp', gs 'preview_hunk', { desc = 'Anteprima hunk' })
map('n', '<leader>gb', gs('blame_line', { full = true }), { desc = 'Blame della riga' })
map('n', '<leader>gd', gs 'diffthis', { desc = 'Diff con l indice' })
map('n', '<leader>gD', gs('diffthis', '@'), { desc = 'Diff con HEAD' })
map('n', '<leader>gc', tb 'git_commits', { desc = 'Commit' })
map('n', '<leader>gB', tb 'git_branches', { desc = 'Branch' })
map('n', '<leader>gt', tb 'git_status', { desc = 'Stato del repository' })

-- ╭─────────────────────────────────────────────────────────────────────────╮
-- │  <leader>l — Lazy & Tools                                               │
-- ╰─────────────────────────────────────────────────────────────────────────╯

map('n', '<leader>ll', '<cmd>Lazy<CR>', { desc = 'Lazy (gestione plugin)' })
map('n', '<leader>lu', '<cmd>Lazy update<CR>', { desc = 'Aggiorna i plugin' })
map('n', '<leader>lm', '<cmd>Mason<CR>', { desc = 'Mason (LSP, linter, DAP)' })
map('n', '<leader>li', '<cmd>checkhealth vim.lsp<CR>', { desc = 'Info sui server LSP' })
map('n', '<leader>lr', '<cmd>LspRestart<CR>', { desc = 'Riavvia i server LSP' })
map('n', '<leader>lc', '<cmd>ConformInfo<CR>', { desc = 'Info sui formattatori' })
map('n', '<leader>lt', '<cmd>TSUpdate<CR>', { desc = 'Aggiorna i parser treesitter' })
map('n', '<leader>lh', '<cmd>checkhealth<CR>', { desc = 'Checkhealth' })

-- ╭─────────────────────────────────────────────────────────────────────────╮
-- │  <leader>t — Terminale (toggleterm)                                     │
-- ╰─────────────────────────────────────────────────────────────────────────╯

map('n', '<leader>tt', '<cmd>ToggleTerm direction=horizontal<CR>', { desc = 'Terminale orizzontale' })
map('n', '<leader>tf', '<cmd>ToggleTerm direction=float<CR>', { desc = 'Terminale flottante' })
map('n', '<leader>tv', '<cmd>ToggleTerm direction=vertical<CR>', { desc = 'Terminale verticale' })
map('n', '<leader>ta', '<cmd>ToggleTermToggleAll<CR>', { desc = 'Mostra/nascondi tutti' })
map('n', '<leader>t1', '<cmd>1ToggleTerm<CR>', { desc = 'Terminale 1' })
map('n', '<leader>t2', '<cmd>2ToggleTerm<CR>', { desc = 'Terminale 2' })
map('n', '<leader>t3', '<cmd>3ToggleTerm<CR>', { desc = 'Terminale 3' })
map('n', '<leader>tn', run 'node', { desc = 'REPL Node' })
map('n', '<leader>tp', run 'psql', { desc = 'psql (PostgreSQL)' })

-- ╭─────────────────────────────────────────────────────────────────────────╮
-- │  <leader>u — UI / Toggle                                                │
-- ╰─────────────────────────────────────────────────────────────────────────╯

map('n', '<leader>uc', function()
  require('config.colorscheme').pick()
end, { desc = 'Colorscheme (persistente)' })
map('n', '<leader>ub', function()
  require('config.colorscheme').toggle_background()
end, { desc = 'Sfondo chiaro/scuro' })
map('n', '<leader>uh', function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = 0 }, { bufnr = 0 })
end, { desc = 'Inlay hints' })
map('n', '<leader>ud', function()
  vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end, { desc = 'Diagnostica' })
map('n', '<leader>uv', function()
  local cfg = vim.diagnostic.config()
  vim.diagnostic.config { virtual_text = not cfg.virtual_text and { source = 'if_many', spacing = 2 } or false }
end, { desc = 'Diagnostica inline (virtual text)' })
map('n', '<leader>uw', '<cmd>setlocal wrap!<CR>', { desc = 'A capo automatico' })
map('n', '<leader>us', '<cmd>setlocal spell!<CR>', { desc = 'Correttore ortografico' })
map('n', '<leader>ur', '<cmd>setlocal relativenumber!<CR>', { desc = 'Numeri di riga relativi' })
map('n', '<leader>un', '<cmd>setlocal number!<CR>', { desc = 'Numeri di riga' })
map('n', '<leader>ui', '<cmd>IBLToggle<CR>', { desc = 'Guide di indentazione' })
map('n', '<leader>ug', '<cmd>Gitsigns toggle_current_line_blame<CR>', { desc = 'Blame a fine riga' })
map('n', '<leader>uf', function()
  vim.g.disable_autoformat = not vim.g.disable_autoformat
  vim.notify('Formattazione al salvataggio: ' .. (vim.g.disable_autoformat and 'OFF' or 'ON'))
end, { desc = 'Formattazione al salvataggio' })

-- ╭─────────────────────────────────────────────────────────────────────────╮
-- │  <leader>x — Diagnostica                                                │
-- ╰─────────────────────────────────────────────────────────────────────────╯

map('n', '<leader>xx', function()
  require('telescope.builtin').diagnostics { bufnr = 0 }
end, { desc = 'Diagnostica del buffer' })
map('n', '<leader>xX', tb 'diagnostics', { desc = 'Diagnostica del progetto' })
map('n', '<leader>xd', vim.diagnostic.open_float, { desc = 'Dettaglio sotto il cursore' })
map('n', '<leader>xq', vim.diagnostic.setqflist, { desc = 'Manda alla quickfix list' })
map('n', '<leader>xl', vim.diagnostic.setloclist, { desc = 'Manda alla location list' })
map('n', '<leader>xt', '<cmd>TodoTelescope<CR>', { desc = 'TODO / FIXME del progetto' })

-- ╭─────────────────────────────────────────────────────────────────────────╮
-- │  <leader>a — AI / Copilot                                               │
-- ╰─────────────────────────────────────────────────────────────────────────╯

map('n', '<leader>ae', '<cmd>Copilot enable<CR>', { desc = 'Abilita Copilot' })
map('n', '<leader>ad', '<cmd>Copilot disable<CR>', { desc = 'Disabilita Copilot' })
map('n', '<leader>as', '<cmd>Copilot status<CR>', { desc = 'Stato di Copilot' })
map('n', '<leader>ap', '<cmd>Copilot panel<CR>', { desc = 'Pannello dei suggerimenti' })

-- In inserimento:
--   <Tab>  accetta il suggerimento di Copilot, altrimenti inserisce un Tab.
--          blink.cmp (plugins/completion.lua) intercetta <Tab> prima di questa
--          mappa e ci arriva (via `fallback`) solo con il menu chiuso e fuori
--          dagli snippet: è ciò che rende <Tab> un unico tasto "accetta".
--   <C-l>  accetta Copilot in ogni caso, anche con il menu di blink aperto.
map('i', '<Tab>', function()
  -- copilot#Accept(default) restituisce i tasti per inserire il suggerimento,
  -- oppure `default` se non ce n'è uno. Il pcall copre Copilot non caricato.
  local ok, keys = pcall(vim.fn['copilot#Accept'], vim.keycode '<Tab>')
  return ok and keys or vim.keycode '<Tab>'
end, {
  expr = true,
  replace_keycodes = false,
  desc = 'Copilot: accetta il suggerimento (o Tab)',
})
map('i', '<C-l>', 'copilot#Accept("\\<CR>")', {
  expr = true,
  replace_keycodes = false,
  desc = 'Copilot: accetta il suggerimento',
})
-- <M-]> / <M-[> scorrono i suggerimenti (mappe di default di copilot.vim).

-- ╭─────────────────────────────────────────────────────────────────────────╮
-- │  Mappe locali al buffer                                                 │
-- ╰─────────────────────────────────────────────────────────────────────────╯

--- Keymaps LSP: chiamata da plugins/lsp.lua sull'evento LspAttach.
---@param bufnr integer
function M.lsp(bufnr)
  local function lmap(mode, lhs, rhs, desc)
    map(mode, lhs, rhs, { buffer = bufnr, desc = 'LSP: ' .. desc })
  end

  -- Navigazione. `grn` (rinomina), `gra` (code action) e `grr`/`gri` sono già
  -- mappe native di Neovim 0.11+: qui sostituiamo solo la lista dei risultati
  -- con i picker di Telescope.
  lmap('n', 'gd', tb 'lsp_definitions', 'Vai alla definizione')
  lmap('n', 'gD', vim.lsp.buf.declaration, 'Vai alla dichiarazione')
  lmap('n', 'grr', tb 'lsp_references', 'Riferimenti')
  lmap('n', 'gri', tb 'lsp_implementations', 'Implementazioni')
  lmap('n', 'gy', tb 'lsp_type_definitions', 'Definizione del tipo')
  lmap('n', 'gO', tb 'lsp_document_symbols', 'Simboli del documento')
  lmap('n', 'gW', tb 'lsp_dynamic_workspace_symbols', 'Simboli del progetto')
  lmap('n', 'K', vim.lsp.buf.hover, 'Documentazione')
  lmap('i', '<C-k>', vim.lsp.buf.signature_help, 'Firma della funzione')

  -- Azioni sul codice.
  lmap({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, 'Azioni sul codice')
  lmap('n', '<leader>cr', vim.lsp.buf.rename, 'Rinomina simbolo')
  lmap('n', '<leader>cs', tb 'lsp_document_symbols', 'Simboli del documento')
  lmap('n', '<leader>cS', tb 'lsp_dynamic_workspace_symbols', 'Simboli del progetto')
  lmap('n', '<leader>cd', vim.diagnostic.open_float, 'Diagnostica sotto il cursore')
  lmap('n', '<leader>ci', tb 'lsp_incoming_calls', 'Chiamate entranti')
  lmap('n', '<leader>co', tb 'lsp_outgoing_calls', 'Chiamate uscenti')
end

--- Keymaps Rust: chiamata da plugins/lang/rust.lua.
---@param bufnr integer
function M.rust(bufnr)
  local function rmap(lhs, cmd, desc)
    map('n', lhs, '<cmd>RustLsp ' .. cmd .. '<CR>', { buffer = bufnr, desc = 'Rust: ' .. desc })
  end

  rmap('<leader>rr', 'runnables', 'Esegui (runnables)')
  rmap('<leader>rt', 'testables', 'Test')
  rmap('<leader>rd', 'debuggables', 'Debug')
  rmap('<leader>rm', 'expandMacro', 'Espandi la macro')
  rmap('<leader>rc', 'openCargo', 'Apri Cargo.toml')
  rmap('<leader>rp', 'parentModule', 'Modulo genitore')
  rmap('<leader>re', 'explainError', 'Spiega l errore')
  rmap('<leader>rD', 'renderDiagnostic', 'Diagnostica estesa')
  rmap('<leader>rj', 'joinLines', 'Unisci le righe')
  map('n', '<leader>rb', run 'cargo build', { buffer = bufnr, desc = 'Rust: cargo build' })
  map('n', '<leader>rC', run 'cargo clippy --all-targets', { buffer = bufnr, desc = 'Rust: cargo clippy' })
  -- K mostra le hover actions di rustaceanvim (documentazione + azioni).
  map('n', 'K', '<cmd>RustLsp hover actions<CR>', { buffer = bufnr, desc = 'Rust: documentazione e azioni' })
end

--- Keymaps Flutter / Dart: chiamata da plugins/lang/flutter.lua.
---@param bufnr integer
function M.flutter(bufnr)
  local function fmap(lhs, cmd, desc)
    map('n', lhs, '<cmd>' .. cmd .. '<CR>', { buffer = bufnr, desc = 'Flutter: ' .. desc })
  end

  fmap('<leader>rr', 'FlutterRun', 'Avvia l app')
  fmap('<leader>rq', 'FlutterQuit', 'Termina l app')
  fmap('<leader>rl', 'FlutterReload', 'Hot reload')
  fmap('<leader>rR', 'FlutterRestart', 'Hot restart')
  fmap('<leader>rd', 'FlutterDevices', 'Dispositivi')
  fmap('<leader>re', 'FlutterEmulators', 'Emulatori')
  fmap('<leader>ro', 'FlutterOutlineToggle', 'Outline dei widget')
  fmap('<leader>rt', 'FlutterDevTools', 'DevTools')
  fmap('<leader>rc', 'FlutterLogClear', 'Pulisci il log')
  map('n', '<leader>rp', run 'flutter pub get', { buffer = bufnr, desc = 'Flutter: pub get' })
end

--- Keymaps per i progetti JS/TS (React, Next.js, Svelte, Node).
---@param bufnr integer
function M.web(bufnr)
  local function wmap(lhs, cmd, desc)
    map('n', lhs, run(cmd), { buffer = bufnr, desc = 'npm: ' .. desc })
  end

  wmap('<leader>rr', 'npm run dev', 'npm run dev')
  wmap('<leader>rb', 'npm run build', 'npm run build')
  wmap('<leader>rs', 'npm start', 'npm start')
  wmap('<leader>rt', 'npm test', 'npm test')
  wmap('<leader>ri', 'npm install', 'npm install')
  wmap('<leader>rl', 'npm run lint', 'npm run lint')
end

--- Keymaps PHP (composer, phpunit).
---@param bufnr integer
function M.php(bufnr)
  local function pmap(lhs, cmd, desc)
    map('n', lhs, run(cmd), { buffer = bufnr, desc = 'PHP: ' .. desc })
  end

  pmap('<leader>rr', 'php ' .. vim.fn.shellescape(vim.api.nvim_buf_get_name(bufnr)), 'Esegui il file')
  pmap('<leader>rt', 'vendor/bin/phpunit', 'phpunit')
  pmap('<leader>ri', 'composer install', 'composer install')
  pmap('<leader>ru', 'composer update', 'composer update')
end

--- Keymaps C# / .NET. run e watch puntano al .csproj del file corrente,
--- così funzionano anche nelle solution con più progetti.
---@param bufnr integer
function M.dotnet(bufnr)
  local function dmap(lhs, cmd, desc)
    map('n', lhs, run(cmd), { buffer = bufnr, desc = '.NET: ' .. desc })
  end

  local project = vim.fs.root(bufnr, function(name)
    return name:match '%.csproj$' ~= nil
  end)
  local target = project and (' --project ' .. vim.fn.shellescape(project)) or ''

  dmap('<leader>rr', 'dotnet run' .. target, 'dotnet run')
  dmap('<leader>rw', 'dotnet watch' .. target, 'dotnet watch')
  dmap('<leader>rb', 'dotnet build', 'dotnet build')
  dmap('<leader>rt', 'dotnet test', 'dotnet test')
  dmap('<leader>ri', 'dotnet restore', 'dotnet restore')
end

-- Le mappe web sono locali ai buffer JS/TS/Svelte.
vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('user_keymaps_web', { clear = true }),
  pattern = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact', 'svelte', 'vue', 'json' },
  callback = function(event)
    M.web(event.buf)
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('user_keymaps_php', { clear = true }),
  pattern = 'php',
  callback = function(event)
    M.php(event.buf)
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('user_keymaps_dotnet', { clear = true }),
  pattern = 'cs',
  callback = function(event)
    M.dotnet(event.buf)
  end,
})

return M
