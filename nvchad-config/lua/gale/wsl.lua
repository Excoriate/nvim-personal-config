-- Only load on WSL - exclude macOS, regular Linux, and Windows
if not vim.fn.has "wsl" or vim.fn.has "macunix" == 1 or vim.fn.has "win32" == 1 then
  return
end

-- Additional safety check - ensure we're actually in WSL environment
if not vim.fn.getenv "WSL_DISTRO_NAME" and not vim.fn.getenv "WSLENV" then
  return
end

-- set a global value to indicate that we are in WSL
vim.g.is_wsl = true

local copy = vim.fn.expand "$WIN" .. "/Utils/win32yank/win32yank.exe -i --crlf"
local paste = vim.fn.expand "$WIN" .. "/Utils/win32yank/win32yank.exe -o --lf"
vim.g.clipboard = {
  name = "wslclipboard",
  copy = { ["+"] = copy, ["*"] = copy },
  paste = { ["+"] = paste, ["*"] = paste },
  cache_enabled = 1,
}
