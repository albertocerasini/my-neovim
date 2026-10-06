-- Debugger (DAP).  Keymaps nel gruppo <leader>d e sui tasti F5/F10/F11/F12.
--
-- Adapter configurati:
--   Rust           codelldb (installato da Mason, usato da rustaceanvim)
--   Node / Next.js js-debug-adapter (launch, attach e Chrome)
--   Dart / Flutter gestito da flutter-tools
return {
  'mfussenegger/nvim-dap',
  event = 'VeryLazy',
  dependencies = {
    { 'rcarriga/nvim-dap-ui', dependencies = { 'nvim-neotest/nvim-nio' }, opts = {} },
    { 'theHamsta/nvim-dap-virtual-text', opts = {} },
  },
  config = function()
    local dap = require 'dap'
    local dapui = require 'dapui'

    -- Apri/chiudi automaticamente l'interfaccia con la sessione.
    dap.listeners.after.event_initialized['dapui'] = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated['dapui'] = function()
      dapui.close()
    end
    dap.listeners.before.event_exited['dapui'] = function()
      dapui.close()
    end

    -- Icone dei breakpoint.
    local sign = vim.fn.sign_define
    sign('DapBreakpoint', { text = '●', texthl = 'DiagnosticError' })
    sign('DapBreakpointCondition', { text = '◆', texthl = 'DiagnosticWarn' })
    sign('DapStopped', { text = '▶', texthl = 'DiagnosticInfo', linehl = 'Visual' })

    -- ── Node / TypeScript / React / Next.js ────────────────────────────
    -- js-debug-adapter è installato da Mason (vedi plugins/lsp.lua).
    local js_debug = vim.fn.exepath 'js-debug-adapter'
    if js_debug == '' then
      js_debug = vim.fn.stdpath 'data' .. '/mason/bin/js-debug-adapter'
    end

    for _, adapter in ipairs { 'pwa-node', 'pwa-chrome' } do
      dap.adapters[adapter] = {
        type = 'server',
        host = 'localhost',
        port = '${port}',
        executable = { command = js_debug, args = { '${port}' } },
      }
    end

    local js_config = {
      {
        type = 'pwa-node',
        request = 'launch',
        name = 'Node: esegui il file corrente',
        program = '${file}',
        cwd = '${workspaceFolder}',
        sourceMaps = true,
      },
      {
        type = 'pwa-node',
        request = 'attach',
        name = 'Node: attach a un processo',
        processId = require('dap.utils').pick_process,
        cwd = '${workspaceFolder}',
        sourceMaps = true,
      },
      {
        type = 'pwa-node',
        request = 'launch',
        name = 'Next.js / npm run dev (server)',
        runtimeExecutable = 'npm',
        runtimeArgs = { 'run', 'dev' },
        cwd = '${workspaceFolder}',
        console = 'integratedTerminal',
        skipFiles = { '<node_internals>/**', 'node_modules/**' },
      },
      {
        type = 'pwa-chrome',
        request = 'launch',
        name = 'Browser: apri localhost:3000',
        url = 'http://localhost:3000',
        webRoot = '${workspaceFolder}',
        sourceMaps = true,
      },
    }

    for _, ft in ipairs { 'javascript', 'typescript', 'javascriptreact', 'typescriptreact', 'svelte' } do
      dap.configurations[ft] = js_config
    end

    -- I file .vscode/launch.json del progetto vengono letti automaticamente da nvim-dap.
  end,
}
