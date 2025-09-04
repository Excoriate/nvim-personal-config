vim.g.mapleader = " "
vim.g.base46_cache = vim.fn.stdpath "data" .. "/nvchad/base46/"

-- Add custom themes directory to package path
local themes_path = vim.fn.stdpath "config" .. "/themes"
package.path = themes_path .. "/?.lua;" .. package.path

-- Ensure base46 cache directory exists
local base46_cache_dir = vim.g.base46_cache
if not vim.uv.fs_stat(base46_cache_dir) then
  vim.fn.mkdir(base46_cache_dir, "p")
end

local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

-- Install lazy if not in path
if not vim.uv.fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system { "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
  vim.cmd "autocmd User LazyDone lua require('nvchad.mason').install_all()"
end
vim.opt.rtp:prepend(lazypath)

local lazy_config = require "configs.lazy"
require("lazy").setup({
  { import = "gale.wezterm" },
  { import = "gale.types" },
  {
    "NvChad/NvChad",
    dev = false,
    lazy = false,
    branch = "v2.5",
    import = "nvchad.plugins",
    config = function()
      -- Ensure base46 cache is generated after NvChad loads
      pcall(function()
        require("base46").load_all_highlights()
      end)
    end,
  },
  { import = "plugins" },
}, lazy_config)

require "nvchad.autocmds"

-- Ensure base46 cache is generated when needed
vim.api.nvim_create_autocmd("User", {
  pattern = "LazyDone",
  callback = function()
    -- Generate base46 cache if missing or regenerate if needed
    pcall(function()
      require("base46").load_all_highlights()
    end)
  end,
})

-- Re-activate providers
for _, v in ipairs { "python3_provider", "node_provider" } do
  vim.g["loaded_" .. v] = nil
  vim.cmd("runtime " .. v)
end
