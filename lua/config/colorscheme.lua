-- ╭─────────────────────────────────────────────────────────────────────────╮
-- │  Selettore di colorscheme PERSISTENTE                                   │
-- ╰─────────────────────────────────────────────────────────────────────────╯
--
-- Il tema scelto (e lo sfondo chiaro/scuro) viene salvato in
--   ~/.local/share/nvim/colorscheme.json
-- e ricaricato automaticamente al prossimo avvio.
--
-- Uso:
--   <leader>uc   apre il selettore con anteprima live (Telescope)
--   <leader>ub   alterna sfondo chiaro/scuro
--   :ColorschemePick / :ColorschemeReset
--
-- Qualunque `:colorscheme <nome>` digitato a mano viene comunque salvato,
-- perché l'evento ColorScheme fa da trigger.

local M = {}

M.file = vim.fn.stdpath 'data' .. '/colorscheme.json'
M.fallback = 'catppuccin-mocha'

--- Legge lo stato salvato su disco.
---@return table|nil
local function read_state()
  local fd = io.open(M.file, 'r')
  if not fd then
    return nil
  end
  local content = fd:read '*a'
  fd:close()
  local ok, data = pcall(vim.json.decode, content)
  return (ok and type(data) == 'table') and data or nil
end

--- Scrive lo stato su disco.
---@param data table
local function write_state(data)
  local fd = io.open(M.file, 'w')
  if not fd then
    return
  end
  fd:write(vim.json.encode(data))
  fd:close()
end

--- Salva il tema attualmente attivo.
function M.save()
  local name = vim.g.colors_name
  if not name or name == '' then
    return
  end
  write_state { colorscheme = name, background = vim.o.background }
end

--- Applica un tema, con fallback se non è installato.
---@param name string
---@param background string|nil 'dark' | 'light'
function M.apply(name, background)
  if background == 'dark' or background == 'light' then
    vim.o.background = background
  end
  if not pcall(vim.cmd.colorscheme, name) then
    vim.notify(("Colorscheme '%s' non disponibile, uso '%s'"):format(name, M.fallback), vim.log.levels.WARN)
    pcall(vim.cmd.colorscheme, M.fallback)
  end
end

--- Ricarica il tema salvato (o il fallback al primo avvio).
function M.load()
  local state = read_state()
  M.apply(state and state.colorscheme or M.fallback, state and state.background)
end

--- Selettore con anteprima live: la scelta viene salvata dall'evento ColorScheme.
function M.pick()
  require('telescope.builtin').colorscheme { enable_preview = true, ignore_builtins = true }
end

--- Alterna sfondo chiaro/scuro (utile con tokyonight, github-theme, ...).
function M.toggle_background()
  vim.o.background = vim.o.background == 'dark' and 'light' or 'dark'
  M.save()
end

--- Torna al tema di default e cancella lo stato salvato.
function M.reset()
  os.remove(M.file)
  M.apply(M.fallback)
end

function M.setup()
  local group = vim.api.nvim_create_augroup('user_colorscheme', { clear = true })

  -- Ogni cambio di tema (comando, Telescope, script) viene reso persistente.
  vim.api.nvim_create_autocmd('ColorScheme', {
    group = group,
    callback = function()
      M.save()
    end,
  })

  -- Anche il solo cambio di `background` va salvato.
  vim.api.nvim_create_autocmd('OptionSet', {
    group = group,
    pattern = 'background',
    callback = function()
      M.save()
    end,
  })

  vim.api.nvim_create_user_command('ColorschemePick', M.pick, { desc = 'Scegli il colorscheme (persistente)' })
  vim.api.nvim_create_user_command('ColorschemeReset', M.reset, { desc = 'Ripristina il colorscheme di default' })

  M.load()
end

return M
