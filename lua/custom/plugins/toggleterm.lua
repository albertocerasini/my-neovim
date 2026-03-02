return {
  'akinsho/toggleterm.nvim',
  version = '*',
  config = function()
    require('toggleterm').setup {
      size = function(term)
        if term.direction == 'horizontal' then
          return 15
        elseif term.direction == 'vertical' then
          return vim.o.columns * 0.4
        end
      end,
      direction = 'horizontal', -- Default horizontal
      open_mapping = [[<C-\>]],
      hide_numbers = true,
      shade_terminals = true,
      shading_factor = 2,
      start_in_insert = true,
      persist_size = true,
      close_on_exit = true,
      shell = vim.o.shell,
      float_opts = {
        border = 'curved',
        winblend = 0,
      },
    }

    -- Keymaps per navigazione in terminal mode
    function _G.set_terminal_keymaps()
      local opts = { buffer = 0 }
      vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], opts)
      vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], opts)
      vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts)
      vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], opts)
    end

    vim.cmd 'autocmd! TermOpen term://*toggleterm#* lua set_terminal_keymaps()'
  end,

  keys = {
    -- Toggle principale (horizontal di default)
    { '<leader>tt', '<cmd>ToggleTerm direction=horizontal<CR>', desc = '[T]erminal [T]oggle' },

    -- Varianti direzione
    { '<leader>tf', '<cmd>ToggleTerm direction=float<CR>', desc = '[T]erminal [F]loat' },
    { '<leader>tv', '<cmd>ToggleTerm direction=vertical<CR>', desc = '[T]erminal [V]ertical' },
    { '<leader>th', '<cmd>ToggleTerm direction=horizontal<CR>', desc = '[T]erminal [H]orizontal' },

    -- Terminali numerati
    { '<leader>t1', '<cmd>1ToggleTerm<CR>', desc = '[T]erminal [1]' },
    { '<leader>t2', '<cmd>2ToggleTerm<CR>', desc = '[T]erminal [2]' },
    { '<leader>t3', '<cmd>3ToggleTerm<CR>', desc = '[T]erminal [3]' },
    { '<leader>t4', '<cmd>4ToggleTerm<CR>', desc = '[T]erminal [4]' },

    -- Gestione terminali
    { '<leader>ta', '<cmd>ToggleTermToggleAll<CR>', desc = '[T]erminal Toggle [A]ll' },
  },
}
