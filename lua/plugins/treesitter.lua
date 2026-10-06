-- nvim-treesitter (branch `main`, richiesto da Neovim 0.12).
-- Fornisce i parser; l'highlighting, il folding e l'indentazione sono
-- attivati da Neovim tramite l'autocomando FileType qui sotto.
--
-- Richiede la CLI `tree-sitter` (brew install tree-sitter-cli) e un compilatore C.
return {
  'nvim-treesitter/nvim-treesitter',
  branch = 'main',
  lazy = false, -- questo plugin non supporta il lazy-loading
  build = ':TSUpdate',
  config = function()
    require('nvim-treesitter').setup {
      install_dir = vim.fn.stdpath 'data' .. '/site',
    }

    -- Parser per il tuo stack. Aggiungine liberamente: `:TSInstall <lingua>`.
    local parsers = {
      -- base / editor
      'bash',
      'c',
      'diff',
      'lua',
      'luadoc',
      'luap',
      'markdown',
      'markdown_inline',
      'query',
      'regex',
      'vim',
      'vimdoc',
      -- git
      'git_config',
      'gitcommit',
      'gitignore',
      -- web
      'css',
      'scss',
      'html',
      'javascript',
      'jsdoc',
      'typescript',
      'tsx',
      'svelte',
      'graphql',
      'json',
      'json5',
      'yaml',
      'toml',
      'xml',
      -- backend / infra
      'rust',
      'dart',
      'sql',
      'prisma',
      'dockerfile',
      'nginx',
      'ssh_config',
    }

    local installed = require('nvim-treesitter.config').get_installed 'parsers'
    local missing = vim.tbl_filter(function(lang)
      return not vim.tbl_contains(installed, lang)
    end, parsers)
    if #missing > 0 then
      require('nvim-treesitter').install(missing)
    end

    -- Attiva highlighting, indentazione e folding per ogni buffer che ha un parser.
    vim.api.nvim_create_autocmd('FileType', {
      group = vim.api.nvim_create_augroup('user_treesitter', { clear = true }),
      callback = function(event)
        local lang = vim.treesitter.language.get_lang(vim.bo[event.buf].filetype)
        if not lang or not pcall(vim.treesitter.start, event.buf, lang) then
          return
        end
        vim.bo[event.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        if vim.api.nvim_get_current_buf() == event.buf then
          vim.wo[0][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
          vim.wo[0][0].foldmethod = 'expr'
        end
      end,
    })
  end,
}
