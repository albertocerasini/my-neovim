-- Web (React, Next.js, Svelte, Node): i language server sono in plugins/lsp.lua,
-- la chiusura dei tag in plugins/editor.lua. Qui restano le integrazioni.
return {
  -- Rinominando o spostando un file dall'explorer, il language server
  -- aggiorna gli import negli altri file.
  {
    'antosha417/nvim-lsp-file-operations',
    event = 'LspAttach',
    main = 'lsp-file-operations',
    dependencies = { 'nvim-lua/plenary.nvim', 'nvim-tree/nvim-tree.lua' },
    opts = {},
  },
}
