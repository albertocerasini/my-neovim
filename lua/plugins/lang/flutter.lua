-- Flutter / Dart: flutter-tools avvia e configura dartls, il log e il debugger.
-- Keymaps locali al buffer nel gruppo <leader>r (config/keymaps.lua → M.flutter).
return {
  'nvim-flutter/flutter-tools.nvim',
  ft = { 'dart' },
  cmd = {
    'FlutterRun',
    'FlutterDevices',
    'FlutterEmulators',
    'FlutterReload',
    'FlutterRestart',
    'FlutterQuit',
    'FlutterOutlineToggle',
    'FlutterDevTools',
    'FlutterLogClear',
  },
  dependencies = { 'nvim-lua/plenary.nvim' },
  opts = function()
    return {
      ui = { border = 'rounded', notification_style = 'native' },
      decorations = { statusline = { app_version = true, device = true } },
      widget_guides = { enabled = true },
      closing_tags = { enabled = true, highlight = 'Comment', prefix = '// ' },
      dev_log = { enabled = true, open_cmd = 'botright 15split' },
      debugger = { enabled = true, run_via_dap = true },
      lsp = {
        color = { enabled = true, background = false, virtual_text = true },
        capabilities = require('blink.cmp').get_lsp_capabilities(),
        on_attach = function(_, bufnr)
          require('config.keymaps').flutter(bufnr)
        end,
        settings = {
          showTodos = true,
          completeFunctionCalls = true,
          enableSnippets = true,
          renameFilesWithClasses = 'prompt',
          updateImportsOnRename = true,
          analysisExcludedFolders = {
            vim.fn.expand '$HOME/.pub-cache',
            vim.fn.expand '$HOME/dev/sdk/flutter',
          },
        },
      },
    }
  end,
}
