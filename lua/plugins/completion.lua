-- Autocompletamento (blink.cmp) e snippet (LuaSnip).
--
-- Tasti in modalità inserimento (comportamento "da IDE": <Tab> accetta):
--   <Tab>      menu aperto      → accetta la voce evidenziata
--              dentro uno snippet → salta al segnaposto successivo
--              altrimenti        → accetta il suggerimento di Copilot,
--                                  o inserisce un Tab (mappa globale in
--                                  config/keymaps.lua, raggiunta via `fallback`)
--   <S-Tab>    segnaposto precedente dello snippet
--   <C-y>      accetta la voce (alternativa a <Tab>)
--   <C-space>  apre/chiude il menu e la documentazione
--   <C-n>/<C-p>  scorri i suggerimenti
--   <C-e>      chiude il menu
--   <C-l>      accetta Copilot anche con il menu aperto (vedi plugins/ai.lua)
return {
  'saghen/blink.cmp',
  event = 'InsertEnter',
  version = '1.*',
  dependencies = {
    {
      'L3MON4D3/LuaSnip',
      version = '2.*',
      build = (function()
        if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
          return
        end
        return 'make install_jsregexp'
      end)(),
      opts = {},
    },
    'folke/lazydev.nvim',
  },
  opts = {
    -- 'super-tab': <Tab> accetta la voce evidenziata (o salta nello snippet) e,
    -- con il menu chiuso, passa alla mappa globale di <Tab> (Copilot / Tab).
    -- <C-y> viene mantenuto come tasto di accettazione alternativo.
    keymap = {
      preset = 'super-tab',
      ['<C-y>'] = { 'select_and_accept', 'fallback' },
    },
    appearance = { nerd_font_variant = 'mono' },
    completion = {
      documentation = { auto_show = true, auto_show_delay_ms = 250 },
      ghost_text = { enabled = false }, -- lo spazio è di Copilot
      list = {
        selection = {
          -- Dentro uno snippet nessuna voce è preselezionata, così <Tab> salta
          -- al segnaposto successivo invece di accettare la prima voce del menu
          -- (per accettarla: <C-n> per selezionarla e poi <Tab>, oppure <C-y>).
          preselect = function()
            return not require('blink.cmp').snippet_active { direction = 1 }
          end,
        },
      },
    },
    signature = { enabled = true },
    snippets = { preset = 'luasnip' },
    sources = {
      default = { 'lsp', 'path', 'snippets', 'buffer', 'lazydev' },
      -- Nei buffer SQL completa tabelle e colonne dal database connesso.
      per_filetype = {
        sql = { 'dadbod', 'snippets', 'buffer' },
        mysql = { 'dadbod', 'snippets', 'buffer' },
        plsql = { 'dadbod', 'snippets', 'buffer' },
      },
      providers = {
        lazydev = { name = 'LazyDev', module = 'lazydev.integrations.blink', score_offset = 100 },
        dadbod = { name = 'Dadbod', module = 'vim_dadbod_completion.blink' },
      },
    },
  },
}
