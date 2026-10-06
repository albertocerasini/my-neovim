-- ╭─────────────────────────────────────────────────────────────────────────╮
-- │  LSP — Mason installa i server, Neovim 0.11+ li configura e li avvia    │
-- ╰─────────────────────────────────────────────────────────────────────────╯
--
-- Nota: rust-analyzer NON è gestito qui (lo avvia rustaceanvim, vedi
-- lua/plugins/lang/rust.lua) e dartls è gestito da flutter-tools.
return {
  { 'mason-org/mason.nvim', cmd = 'Mason', opts = { ui = { border = 'rounded' } } },

  { 'folke/lazydev.nvim', ft = 'lua', opts = { library = { { path = '${3rd}/luv/library', words = { 'vim%.uv' } } } } },

  { 'b0o/schemastore.nvim', lazy = true },

  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      'mason-org/mason.nvim',
      'mason-org/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      'b0o/schemastore.nvim',
      { 'j-hui/fidget.nvim', opts = { notification = { window = { winblend = 0 } } } },
      'saghen/blink.cmp',
    },
    config = function()
      -- ── Aspetto della diagnostica ──────────────────────────────────────
      vim.diagnostic.config {
        severity_sort = true,
        float = { border = 'rounded', source = 'if_many' },
        underline = { severity = vim.diagnostic.severity.ERROR },
        signs = vim.g.have_nerd_font and {
          text = {
            [vim.diagnostic.severity.ERROR] = '󰅚 ',
            [vim.diagnostic.severity.WARN] = '󰀪 ',
            [vim.diagnostic.severity.INFO] = '󰋽 ',
            [vim.diagnostic.severity.HINT] = '󰌶 ',
          },
        } or {},
        virtual_text = { source = 'if_many', spacing = 2 },
      }

      -- ── Cosa succede quando un server si aggancia a un buffer ──────────
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('user_lsp_attach', { clear = true }),
        callback = function(event)
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if not client then
            return
          end

          -- Keymaps (definite in lua/config/keymaps.lua).
          require('config.keymaps').lsp(event.buf)

          -- Evidenzia le altre occorrenze del simbolo sotto il cursore.
          if client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
            local group = vim.api.nvim_create_augroup('user_lsp_highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = group,
              callback = vim.lsp.buf.document_highlight,
            })
            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = group,
              callback = vim.lsp.buf.clear_references,
            })
            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('user_lsp_detach', { clear = true }),
              callback = function(detach)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'user_lsp_highlight', buffer = detach.buf }
              end,
            })
          end

          -- Inlay hints attivi di default (<leader>uh per disattivarli).
          if client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
            vim.lsp.inlay_hint.enable(true, { bufnr = event.buf })
          end
        end,
      })

      -- ── Capabilities condivise da tutti i server ───────────────────────
      vim.lsp.config('*', { capabilities = require('blink.cmp').get_lsp_capabilities() })

      -- ── Configurazione dei singoli server ──────────────────────────────
      local servers = {
        lua_ls = {
          settings = {
            Lua = {
              completion = { callSnippet = 'Replace' },
              hint = { enable = true },
              workspace = { checkThirdParty = false },
            },
          },
        },

        -- TypeScript / JavaScript / React / Next.js
        ts_ls = {
          settings = {
            typescript = {
              inlayHints = {
                includeInlayParameterNameHints = 'literals',
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints = false,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
              },
              preferences = { importModuleSpecifier = 'non-relative' },
            },
            javascript = {
              inlayHints = {
                includeInlayParameterNameHints = 'literals',
                includeInlayFunctionParameterTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
              },
            },
          },
        },

        eslint = {
          settings = { workingDirectories = { mode = 'auto' } },
        },

        -- Svelte (SvelteKit incluso)
        svelte = {
          on_attach = function(client)
            vim.api.nvim_create_autocmd('BufWritePost', {
              pattern = { '*.js', '*.ts' },
              group = vim.api.nvim_create_augroup('user_svelte_ts', { clear = true }),
              callback = function(ctx)
                client:notify('$/onDidChangeTsOrJsFile', { uri = vim.uri_from_fname(ctx.file) })
              end,
            })
          end,
        },

        html = {},

        cssls = {
          settings = {
            -- Le direttive di Tailwind (@apply, @tailwind, ...) non sono CSS standard.
            css = { lint = { unknownAtRules = 'ignore' } },
            scss = { lint = { unknownAtRules = 'ignore' } },
            less = { lint = { unknownAtRules = 'ignore' } },
          },
        },

        tailwindcss = {
          settings = {
            tailwindCSS = {
              -- Riconosce le classi anche dentro cva(), clsx(), cn(), tw``.
              experimental = {
                classRegex = {
                  { 'cva\\(([^)]*)\\)', '["\'`]([^"\'`]*).*?["\'`]' },
                  { 'cx\\(([^)]*)\\)', '["\'`]([^"\'`]*).*?["\'`]' },
                  { 'cn\\(([^)]*)\\)', '["\'`]([^"\'`]*).*?["\'`]' },
                  { 'clsx\\(([^)]*)\\)', '["\'`]([^"\'`]*).*?["\'`]' },
                },
              },
            },
          },
        },

        emmet_language_server = {
          filetypes = {
            'html',
            'css',
            'scss',
            'sass',
            'less',
            'javascriptreact',
            'typescriptreact',
            'svelte',
            'vue',
          },
        },

        jsonls = {
          settings = {
            json = {
              schemas = require('schemastore').json.schemas(),
              validate = { enable = true },
            },
          },
        },

        yamlls = {
          settings = {
            yaml = {
              schemaStore = { enable = false, url = '' },
              schemas = require('schemastore').yaml.schemas(),
              keyOrdering = false,
            },
          },
        },

        taplo = {}, -- TOML: Cargo.toml, rustfmt.toml, ...
        bashls = {}, -- script di deploy, .sh, .env
        dockerls = {},
        docker_compose_language_service = {},
        marksman = {}, -- Markdown

        -- PHP (Laravel, Symfony, WordPress, ...). Funziona anche senza PHP
        -- installato. Licenza premium (opzionale):
        --   init_options = { licenceKey = '<chiave o percorso del file>' }
        intelephense = {
          settings = {
            intelephense = {
              -- Il limite di default (1 MB) esclude file generati come _ide_helper.php.
              files = { maxSize = 5000000 },
            },
          },
        },

        -- C# / .NET: Roslyn, lo stesso server dell'estensione C# di VS Code.
        -- Apre da solo la .sln (o i .csproj) trovata risalendo dal file.
        -- Richiede l'SDK .NET (`dotnet`).
        roslyn_ls = {
          settings = {
            ['csharp|formatting'] = { dotnet_organize_imports_on_format = true },
          },
        },

        -- nginx: la sintassi arriva da treesitter. Per il language server
        -- (richiede Python 3.10+) aggiungi qui `nginx_language_server = {}`.
      }

      for name, config in pairs(servers) do
        vim.lsp.config(name, config)
      end

      -- ── Installazione automatica ───────────────────────────────────────
      require('mason-lspconfig').setup {
        ensure_installed = vim.tbl_keys(servers),
        -- rust_analyzer è avviato da rustaceanvim: non abilitarlo qui,
        -- altrimenti partirebbero due client sullo stesso buffer.
        automatic_enable = { exclude = { 'rust_analyzer' } },
      }

      require('mason-tool-installer').setup {
        ensure_installed = {
          'stylua', -- Lua
          'prettierd', -- JS/TS/JSON/CSS/HTML/Svelte/Markdown/YAML
          'prettier',
          'shfmt', -- shell
          'sql-formatter', -- SQL / PostgreSQL
          'codelldb', -- debugger per Rust
          'js-debug-adapter', -- debugger per Node / Chrome
          'php-debug-adapter', -- debugger per PHP (Xdebug)
          -- netcoredbg (C#) NON va installato da Mason: su macOS c'è solo la
          -- build x64, che non fa il debug di .NET arm64. Vedi plugins/debug.lua.
        },
        run_on_start = true,
      }
    end,
  },
}
