---@type NvPluginSpec
return {
  -- TODO: re-enable once html support improves
  enabled = false,
  "HiPhish/rainbow-delimiters.nvim",
  event = "FileType",
  config = function()
    local rainbow_cache = vim.g.base46_cache .. "rainbow-delimiters"
    if vim.uv.fs_stat(rainbow_cache) then
      dofile(rainbow_cache)
    end
    require("rainbow-delimiters").setup()
  end,
}
