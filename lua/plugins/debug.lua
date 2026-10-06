-- Debugger (DAP).  Keymaps nel gruppo <leader>d e sui tasti F5/F10/F11/F12.
--
-- Adapter configurati:
--   Rust           codelldb (installato da Mason, usato da rustaceanvim)
--   Node / Next.js js-debug-adapter (launch, attach e Chrome)
--   Dart / Flutter gestito da flutter-tools
--   PHP            php-debug-adapter (installato da Mason) + Xdebug
--   C# / .NET      netcoredbg, cercato nel PATH (build arm64, non quella di Mason)
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

    -- ── PHP (Xdebug 3) ─────────────────────────────────────────────────
    -- Richiede PHP con l'estensione Xdebug. Per Docker / Laravel Sail servono
    -- i `pathMappings`: mettili in .vscode/launch.json.
    local php_debug = vim.fn.exepath 'php-debug-adapter'
    if php_debug == '' then
      php_debug = vim.fn.stdpath 'data' .. '/mason/bin/php-debug-adapter'
    end
    dap.adapters.php = { type = 'executable', command = php_debug }

    dap.configurations.php = {
      {
        type = 'php',
        request = 'launch',
        name = 'Xdebug: in ascolto sulla porta 9003',
        port = 9003,
      },
      {
        type = 'php',
        request = 'launch',
        name = 'PHP: esegui il file corrente',
        program = '${file}',
        cwd = '${fileDirname}',
        port = 0,
        runtimeArgs = { '-dxdebug.start_with_request=yes' },
        -- ${port} lo sostituisce l'adapter con la porta scelta.
        env = { XDEBUG_MODE = 'debug,develop', XDEBUG_CONFIG = 'client_port=${port}' },
      },
    }

    -- ── C# / .NET ──────────────────────────────────────────────────────
    -- netcoredbg va messo nel PATH a mano: Mason ha solo la build x64, che su
    -- Apple Silicon non riesce a fare il debug di processi .NET arm64.
    -- Prima di avviare, compila con `dotnet build` (<leader>rb).
    dap.adapters.coreclr = function(callback)
      local netcoredbg = vim.fn.exepath 'netcoredbg'
      if netcoredbg == '' then
        vim.notify('netcoredbg non trovato nel PATH (vedi lua/plugins/debug.lua)', vim.log.levels.ERROR)
        return
      end
      callback {
        type = 'executable',
        command = netcoredbg,
        args = { '--interpreter=vscode' },
        -- Avvia il programma dalla cartella del suo progetto, così ASP.NET
        -- trova appsettings.json e wwwroot.
        enrich_config = function(config, on_config)
          if config.request == 'launch' and not config.cwd then
            config = vim.deepcopy(config)
            config.cwd = config.program:match '^(.*)/bin/' or vim.fn.getcwd()
          end
          on_config(config)
        end,
      }
    end

    --- DLL compilate (bin/Debug) dei progetti sotto la cwd; se sono più di una
    --- chiede quale avviare.
    local function pick_dll()
      local ignored = { bin = true, obj = true, node_modules = true }
      local walk = {
        depth = 5,
        skip = function(dir)
          local name = vim.fs.basename(dir)
          return not ignored[name] and name:sub(1, 1) ~= '.'
        end,
      }
      local dlls = {}
      for path, kind in vim.fs.dir(vim.fn.getcwd(), walk) do
        if kind == 'file' and path:match '%.csproj$' then
          local project = vim.fs.joinpath(vim.fn.getcwd(), vim.fs.dirname(path))
          local name = vim.fn.fnamemodify(path, ':t:r')
          vim.list_extend(dlls, vim.fn.glob(project .. '/bin/Debug/*/' .. name .. '.dll', false, true))
        end
      end

      if #dlls == 0 then
        vim.notify('Nessuna DLL in bin/Debug: compila prima con `dotnet build`', vim.log.levels.WARN)
        return dap.ABORT
      elseif #dlls == 1 then
        return dlls[1]
      end
      local co = coroutine.running()
      vim.ui.select(dlls, {
        prompt = 'DLL da avviare',
        format_item = function(dll)
          return vim.fn.fnamemodify(dll, ':.')
        end,
      }, function(choice)
        coroutine.resume(co, choice or dap.ABORT)
      end)
      return coroutine.yield()
    end

    dap.configurations.cs = {
      {
        type = 'coreclr',
        request = 'launch',
        name = '.NET: avvia il progetto',
        program = pick_dll,
        env = { ASPNETCORE_ENVIRONMENT = 'Development', DOTNET_ENVIRONMENT = 'Development' },
      },
      {
        type = 'coreclr',
        request = 'attach',
        name = '.NET: attach a un processo',
        processId = require('dap.utils').pick_process,
      },
    }

    -- I file .vscode/launch.json del progetto vengono letti automaticamente da nvim-dap.
  end,
}
