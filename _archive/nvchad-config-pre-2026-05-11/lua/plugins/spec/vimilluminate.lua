---@type NvPluginSpec
return {
  "RRethy/vim-illuminate",
  enabled = false,
  event = "BufEnter",
  opts = {
    filetypes_denylist = { "NvimTree", "TelescopePrompt", "NeogitStatus", "lazy", "mason" },
  },
  config = function(_, opts)
    local illuminate_cache = vim.g.base46_cache .. "vim-illuminate"
    if vim.uv.fs_stat(illuminate_cache) then
      dofile(illuminate_cache)
    end
    require("illuminate").configure(opts)
  end,
}
