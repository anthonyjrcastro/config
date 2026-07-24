--- For completions and analysis for Nvim plugins in the runtime path:
--- https://github.com/neovim/nvim-lspconfig/blob/master/lsp/emmylua_ls.lua
---@type vim.lsp.Config
return {
  on_init = function(client)
    -- If the workspace has its own config file, defer to it.
    if client.workspace_folders then
      local path = client.workspace_folders[1].name
      if
        path ~= vim.fn.stdpath 'config'
        and (vim.uv.fs_stat(path .. '/.emmyrc.json') or vim.uv.fs_stat(path .. '/.luarc.json'))
      then
        client.config.settings = {}
      end
    end
  end,
  settings = {
    emmylua = {
      -- Usually the case for Nvim.
      runtime = { version = 'LuaJIT' },
      -- Make the server aware of Nvim runtime files.
      workspace = {
        library = {
          vim.env.VIMRUNTIME,
          -- For LSP Settings Type Annotations: https://github.com/neovim/nvim-lspconfig#lsp-settings-type-annotations
          vim.api.nvim_get_runtime_file('lua/lspconfig', false)[1],
        },
      },
    },
  },
}
