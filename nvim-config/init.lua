-- This file simply bootstraps the installation of Lazy.nvim and then calls other files for execution
-- This file doesn't necessarily need to be touched, BE CAUTIOUS editing this file and proceed at your own risk.

-- Neovim 0.11+ deprecates vim.tbl_flatten(); many plugins still call it. The original
-- `vim.tbl_flatten` flattens ONE level (depth=1) — preserve that contract exactly.
-- Using `:flatten(math.huge)` would over-flatten and silently corrupt nested tables
-- (e.g., lazy-spec opts arrays). Verifier:
--   :lua local r = vim.iter({{1,{2,3}}}):flatten():totable(); print(vim.inspect(r))
--   should yield { 1, { 2, 3 } } (depth-1 flatten), not { 1, 2, 3 }.
if vim.iter then vim.tbl_flatten = function(t) return vim.iter(t):flatten(1):totable() end end

-- Explicitly disable language providers we don't use. Silences :checkhealth
-- provider warnings (pynvim/perl/ruby/node-host). Re-enable individually if needed.
vim.g.loaded_python3_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0

-- The Vim and Lua Markdown ftplugins both own [[/]] and append duplicate
-- normal-mode cleanup commands. Keep the Lua Tree-sitter mappings only.
vim.g.no_markdown_maps = 1

-- Narrow deprecation filter: suppress KNOWN upstream deprecation warnings that
-- are pending fixes in their respective repos. Anything else still surfaces.
--   1. `opts.jump.float` — AstroNvim astrocore/init.lua:587 still uses the old
--      diagnostic.config jump shape; removal slated for Nvim 0.14. Track:
--      github.com/AstroNvim/astrocore.
--   2. `client.supports_method` — Nvim 0.11+ wants `client:supports_method(...)`
--      (colon). Multiple plugins still call it as a function. Track each plugin's
--      issue tracker; remove this filter as plugins migrate.
-- REMOVE this block once upstream patches land and a clean nvim --headless +qa
-- yields zero "is deprecated" lines on a real-file open.
local _vim_deprecate = vim.deprecate
local _suppressed_prefixes = {
  "opts.jump.float",
  "client.supports_method",
}
---@diagnostic disable-next-line: duplicate-set-field
vim.deprecate = function(name, ...)
  if type(name) == "string" then
    for _, prefix in ipairs(_suppressed_prefixes) do
      if name == prefix or name:find(prefix, 1, true) == 1 then return end
    end
  end
  return _vim_deprecate(name, ...)
end

local lazypath = vim.env.LAZY or vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

if not (vim.env.LAZY or (vim.uv or vim.loop).fs_stat(lazypath)) then
  -- stylua: ignore
  local result = vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
  if vim.v.shell_error ~= 0 then
    -- stylua: ignore
    vim.api.nvim_echo({ { ("Error cloning lazy.nvim:\n%s\n"):format(result), "ErrorMsg" }, { "Press any key to exit...", "MoreMsg" } }, true, {})
    vim.fn.getchar()
    vim.cmd.quit()
  end
end

vim.opt.rtp:prepend(lazypath)

-- validate that lazy is available
if not pcall(require, "lazy") then
  -- stylua: ignore
  vim.api.nvim_echo({ { ("Unable to load lazy from: %s\n"):format(lazypath), "ErrorMsg" }, { "Press any key to exit...", "MoreMsg" } }, true, {})
  vim.fn.getchar()
  vim.cmd.quit()
end

require "lazy_setup"
require "polish"
