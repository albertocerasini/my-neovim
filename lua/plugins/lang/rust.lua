-- Rust: rustaceanvim gestisce rust-analyzer, i test, il debug e le code action.
-- NON configurare rust_analyzer in plugins/lsp.lua: partirebbero due client.
-- Keymaps locali al buffer nel gruppo <leader>r (vedi config/keymaps.lua → M.rust).
return {
  {
    'mrcjkb/rustaceanvim',
    version = '^6',
    lazy = false, -- il plugin si attiva da solo sui file .rs
    init = function()
      vim.g.rustaceanvim = function()
        return {
          tools = {
            hover_actions = { replace_builtin_hover = true },
            float_win_config = { border = 'rounded' },
          },
          server = {
            capabilities = require('blink.cmp').get_lsp_capabilities(),
            on_attach = function(_, bufnr)
              require('config.keymaps').rust(bufnr)
            end,
            default_settings = {
              ['rust-analyzer'] = {
                cargo = {
                  allFeatures = true,
                  buildScripts = { enable = true },
                },
                -- Usa clippy al posto di `cargo check`: più lento ma molto più utile.
                checkOnSave = true,
                check = { command = 'clippy', extraArgs = { '--no-deps' } },
                procMacro = { enable = true },
                inlayHints = {
                  bindingModeHints = { enable = false },
                  closureReturnTypeHints = { enable = 'with_block' },
                  lifetimeElisionHints = { enable = 'never' },
                  parameterHints = { enable = true },
                  typeHints = { enable = true },
                },
                files = { excludeDirs = { '.git', 'target', 'node_modules' } },
              },
            },
          },
          dap = {}, -- usa codelldb installato da Mason
        }
      end
    end,
  },

  -- Versioni delle dipendenze direttamente dentro Cargo.toml.
  {
    'saecki/crates.nvim',
    event = { 'BufRead Cargo.toml' },
    opts = {
      completion = { crates = { enabled = true } },
      lsp = { enabled = true, actions = true, completion = true, hover = true },
    },
  },
}
