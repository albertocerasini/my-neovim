-- Terminale integrato.  <C-\> apre/chiude al volo, gruppo <leader>t per il resto.
return {
  'akinsho/toggleterm.nvim',
  version = '*',
  event = 'VeryLazy',
  cmd = { 'ToggleTerm', 'TermExec', 'ToggleTermToggleAll' },
  opts = {
    open_mapping = [[<C-\>]],
    direction = 'horizontal',
    size = function(term)
      if term.direction == 'horizontal' then
        return 15
      elseif term.direction == 'vertical' then
        return math.floor(vim.o.columns * 0.4)
      end
    end,
    hide_numbers = true,
    shade_terminals = true,
    shading_factor = 2,
    start_in_insert = true,
    persist_size = true,
    close_on_exit = true,
    shell = vim.o.shell,
    float_opts = { border = 'curved', winblend = 0 },
    -- Naviga tra le finestre anche dal terminale, senza uscire dalla modalità.
    on_open = function(term)
      local opts = { buffer = term.bufnr, desc = 'Cambia finestra' }
      vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], opts)
      vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], opts)
      vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts)
      vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], opts)
    end,
  },
}
