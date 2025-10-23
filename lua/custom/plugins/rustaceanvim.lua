return {
  'mrcjkb/rustaceanvim',
  version = '^6', -- Recommended
  lazy = false, -- This plugin is already lazy
  ft = { 'rust' }, -- Load when opening Rust files
  init = function()
    -- Configure rustaceanvim here
    vim.g.rustaceanvim = {
      tools = {
        hover_actions = {
          replace_builtin_hover = true,
        },
      },
    }
  end,
}
