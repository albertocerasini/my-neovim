-- Formattazione (conform.nvim).
--   <leader>cf  formatta ora
--   <leader>uf  attiva/disattiva la formattazione al salvataggio
return {
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },
  opts = {
    notify_on_error = false,
    default_format_opts = { lsp_format = 'fallback' },

    format_on_save = function(bufnr)
      if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
        return nil
      end
      return { timeout_ms = 1000, lsp_format = 'fallback' }
    end,

    formatters_by_ft = {
      lua = { 'stylua' },
      -- prettierd è più veloce; prettier è il fallback se non c'è.
      javascript = { 'prettierd', 'prettier', stop_after_first = true },
      javascriptreact = { 'prettierd', 'prettier', stop_after_first = true },
      typescript = { 'prettierd', 'prettier', stop_after_first = true },
      typescriptreact = { 'prettierd', 'prettier', stop_after_first = true },
      svelte = { 'prettierd', 'prettier', stop_after_first = true },
      vue = { 'prettierd', 'prettier', stop_after_first = true },
      css = { 'prettierd', 'prettier', stop_after_first = true },
      scss = { 'prettierd', 'prettier', stop_after_first = true },
      less = { 'prettierd', 'prettier', stop_after_first = true },
      html = { 'prettierd', 'prettier', stop_after_first = true },
      json = { 'prettierd', 'prettier', stop_after_first = true },
      jsonc = { 'prettierd', 'prettier', stop_after_first = true },
      yaml = { 'prettierd', 'prettier', stop_after_first = true },
      markdown = { 'prettierd', 'prettier', stop_after_first = true },
      graphql = { 'prettierd', 'prettier', stop_after_first = true },
      sh = { 'shfmt' },
      bash = { 'shfmt' },
      zsh = { 'shfmt' },
      sql = { 'sql_formatter' },
      rust = { 'rustfmt' },
      -- dart e nginx usano il formattatore del rispettivo language server.
    },

    formatters = {
      sql_formatter = { prepend_args = { '--language', 'postgresql' } },
      shfmt = { prepend_args = { '-i', '2', '-ci' } },
    },
  },
}
