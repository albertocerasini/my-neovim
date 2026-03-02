local builtin = require 'telescope.builtin'
local telescope = require 'telescope'
event = 'VimEnter'
-- In this case, we create a function that lets us more easily define mappings specific
-- for LSP related items. It sets the mode, buffer and description for us each time.
local map = function(keys, func, desc, mode)
  mode = mode or 'n'
  vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
end

-- Toggle between light and dark background
local function toggle_theme()
  if vim.opt.background:get() == 'dark' then
    vim.opt.background = 'light'
  else
    vim.opt.background = 'dark'
  end
end

-- Get git root directory for consistent file search
local function get_git_root()
  local git_root = vim.fn.systemlist('git rev-parse --show-toplevel')[1]
  if vim.v.shell_error == 0 then
    return git_root
  end
  return vim.fn.getcwd()
end

return {
  vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>'),

  -- Azioni comuni (stile AstroNvim)
  vim.keymap.set('n', '<leader>w', '<cmd>w<CR>', { desc = 'Save file' }),
  vim.keymap.set('n', '<leader>W', '<cmd>wa<CR>', { desc = 'Save all files' }),
  vim.keymap.set('n', '<leader>q', '<cmd>q<CR>', { desc = 'Quit' }),
  vim.keymap.set('n', '<leader>qa', '<cmd>qa<CR>', { desc = 'Quit All' }),
  vim.keymap.set('n', '<leader>Q', '<cmd>q!<CR>', { desc = 'Quit without saving' }),
  vim.keymap.set('n', '<leader>c', '<cmd>bd<CR>', { desc = 'Close buffer' }),
  vim.keymap.set('n', '<leader>C', '<cmd>bd!<CR>', { desc = 'Close buffer (force)' }),

  -- Diagnostic keymaps (sotto <leader>x)
  vim.keymap.set('n', '<leader>xq', vim.diagnostic.setloclist, { desc = 'Diagnostic [Q]uickfix list' }),
  vim.keymap.set('n', '<leader>xd', vim.diagnostic.open_float, { desc = '[D]iagnostic float' }),

  -- File explorer
  vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', { desc = 'Toggle file explorer' }),
  -- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
  -- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
  -- is not what someone will guess without a bit more experience.
  --
  -- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
  -- or just use <C-\><C-n> to exit terminal mode
  vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' }),

  -- TIP: Disable arrow keys in normal mode
  -- vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
  -- vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
  -- vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
  -- vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

  -- Keybinds to make split navigation easier.
  --  Use CTRL+<hjkl> to switch between windows
  --
  --  See `:help wincmd` for a list of all window commands

  -- Window navigation
  vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' }),
  vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' }),
  vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' }),
  vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' }),

  -- FIND KEYMAPS (stile AstroNvim)
  vim.keymap.set('n', '<leader>ff', function()
    builtin.find_files { cwd = get_git_root() }
  end, { desc = '[F]ind [F]iles' }),
  vim.keymap.set('n', '<leader>fF', function()
    builtin.find_files { cwd = get_git_root(), hidden = true, no_ignore = true }
  end, { desc = '[F]ind ALL [F]iles (include hidden/ignored)' }),
  vim.keymap.set('n', '<leader>fw', function()
    builtin.live_grep { cwd = get_git_root() }
  end, { desc = '[F]ind [W]ords (grep)' }),
  vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[F]ind [B]uffers' }),
  vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = '[F]ind [H]elp' }),
  vim.keymap.set('n', '<leader>fk', builtin.keymaps, { desc = '[F]ind [K]eymaps' }),
  vim.keymap.set('n', '<leader>fo', builtin.oldfiles, { desc = '[F]ind [O]ld/recent files' }),
  vim.keymap.set('n', '<leader>fc', function()
    builtin.grep_string { cwd = get_git_root() }
  end, { desc = '[F]ind [C]urrent word' }),
  vim.keymap.set('n', '<leader>fD', builtin.diagnostics, { desc = '[F]ind [D]iagnostics' }),
  vim.keymap.set('n', '<leader>fr', builtin.resume, { desc = '[F]ind [R]esume' }),
  vim.keymap.set('n', '<leader>ft', builtin.builtin, { desc = '[F]ind [T]elescope builtins' }),
  vim.keymap.set('n', '<leader>fp', telescope.extensions.projects.projects, { desc = '[F]ind [P]rojects' }),
  vim.keymap.set('n', '<leader>fC', function()
    builtin.colorscheme { enable_preview = true }
  end, { desc = '[F]ind [C]olorscheme' }),

  -- DBUI
  -- Open database UI
  vim.keymap.set('n', '<leader>du', ':DBUI<CR>', { desc = 'Open Database UI' }),
  -- Close database UI
  vim.keymap.set('n', '<leader>dq', ':DBUIQuit<CR>', { desc = 'Close Database UI' }),
  -- Toggle database UI
  vim.keymap.set('n', '<leader>dt', ':DBUIToggle<CR>', { desc = 'Toggle Database UI' }),
  -- LSP Keymaps

  -- Rename the variable under your cursor.
  --  Most Language Servers support renaming across files, etc.
  map('grn', vim.lsp.buf.rename, '[R]e[n]ame'),

  -- Execute a code action, usually your cursor needs to be on top of an error
  -- or a suggestion from your LSP for this to activate.
  map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' }),

  -- Find references for the word under your cursor.
  map('grr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences'),

  -- Jump to the implementation of the word under your cursor.
  --  Useful when your language has ways of declaring types without an actual implementation.
  map('gri', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation'),

  -- Jump to the definition of the word under your cursor.
  --  This is where a variable was first declared, or where a function is defined, etc.
  --  To jump back, press <C-t>.
  map('grd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition'),

  -- WARN: This is not Goto Definition, this is Goto Declaration.
  --  For example, in C this would take you to the header.
  map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration'),

  -- Fuzzy find all the symbols in your current document.
  --  Symbols are things like variables, functions, types, etc.
  map('gO', require('telescope.builtin').lsp_document_symbols, 'Open Document Symbols'),

  -- Fuzzy find all the symbols in your current workspace.
  --  Similar to document symbols, except searches over your entire project.
  map('gW', require('telescope.builtin').lsp_dynamic_workspace_symbols, 'Open Workspace Symbols'),

  -- Jump to the type of the word under your cursor.
  --  Useful when you're not sure what type a variable is and you want to see
  --  the definition of its *type*, not where it was *defined*.
  map('grt', require('telescope.builtin').lsp_type_definitions, '[G]oto [T]ype Definition'),
  vim.keymap.set('n', '<leader>ut', toggle_theme, {}),
}
