-- GitHub Copilot.  Keymaps nel gruppo <leader>a; in inserimento <Tab> (o <C-l>)
-- accetta il suggerimento.
return {
  'github/copilot.vim',
  event = 'InsertEnter',
  init = function()
    -- Niente mappa <Tab> del plugin: la gestiamo noi in config/keymaps.lua,
    -- coordinata con blink.cmp (plugins/completion.lua).
    vim.g.copilot_no_tab_map = true
    vim.g.copilot_assume_mapped = true
    vim.g.copilot_filetypes = {
      ['*'] = true,
      ['dbui'] = false,
      ['TelescopePrompt'] = false,
    }
  end,
}
