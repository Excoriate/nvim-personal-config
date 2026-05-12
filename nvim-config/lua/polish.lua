-- This will run last in the setup process.
-- Polish: custom filetypes, autocommands, and tweaks
-- Inspired by orhun/dotfiles + DevOps stack optimizations

-- Auto-enter insert mode when opening terminal
vim.api.nvim_create_autocmd({ "BufWinEnter", "WinEnter" }, {
  pattern = "term://*",
  callback = function() vim.cmd "startinsert" end,
})

-- Auto-leave insert mode when leaving terminal window
vim.api.nvim_create_autocmd("BufLeave", {
  pattern = "term://*",
  callback = function() vim.cmd "stopinsert" end,
})

-- Highlight on yank (brief flash)
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function() vim.highlight.on_yank { higroup = "Visual", timeout = 150 } end,
})

-- Auto-resize splits when window is resized
vim.api.nvim_create_autocmd("VimResized", {
  callback = function() vim.cmd "tabdo wincmd =" end,
})

-- Remove trailing whitespace on save (exclude certain filetypes and non-writable buffers).
-- Guard against E21 "Cannot make changes" on :checkhealth/:Lazy/scratch buffers.
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function()
    if not vim.bo.modifiable or vim.bo.readonly or vim.bo.buftype ~= "" then return end
    -- gitcommit/gitrebase: trailing whitespace can be semantically meaningful (soft
    -- breaks in commit body, fixup directives). diff: never mutate. markdown: trailing
    -- two-space = line-break. patch: byte-exact.
    local excluded = { "markdown", "diff", "gitcommit", "gitrebase", "patch", "mail" }
    if vim.tbl_contains(excluded, vim.bo.filetype) then return end
    local cursor = vim.api.nvim_win_get_cursor(0)
    vim.cmd [[silent! keepjumps keeppatterns %s/\s\+$//e]]
    pcall(vim.api.nvim_win_set_cursor, 0, cursor)
  end,
})

-- Close certain filetypes with just 'q'
vim.api.nvim_create_autocmd("FileType", {
  pattern = {
    "help",
    "man",
    "lspinfo",
    "qf",
    "checkhealth",
    "git",
    "fugitive",
    "fugitiveblame",
    "notify",
    "spectre_panel",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end,
})

-- Terraform/HCL/Terragrunt specific settings
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "terraform", "hcl", "terraform-vars" },
  callback = function()
    vim.opt_local.commentstring = "# %s"
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.expandtab = true
  end,
})

-- Go specific settings
vim.api.nvim_create_autocmd("FileType", {
  pattern = "go",
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.expandtab = false
  end,
})

-- Justfile/Makefile settings (tabs required)
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "just", "make" },
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.expandtab = false -- tabs required for make/just
    vim.opt_local.commentstring = "# %s"
  end,
})

-- YAML settings (2-space indent)
vim.api.nvim_create_autocmd("FileType", {
  pattern = {
    "yaml",
    "yaml.ansible",
    "yaml.docker-compose",
    "yaml.kubernetes",
    "yaml.azure-pipelines",
    "yaml.cloudformation",
    "yaml.taskfile",
    "yaml.helm",
  },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.expandtab = true
    vim.opt_local.cursorcolumn = true -- helps with YAML indentation
  end,
})

-- Markdown settings
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "mdx" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
    vim.opt_local.conceallevel = 2
    vim.opt_local.linebreak = true -- wrap at word boundaries
    vim.opt_local.textwidth = 80
  end,
})

-- Docker/Containerfile settings
vim.api.nvim_create_autocmd("FileType", {
  pattern = "dockerfile",
  callback = function() vim.opt_local.commentstring = "# %s" end,
})

-- JSON/JSONC settings
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "json", "jsonc" },
  callback = function()
    vim.opt_local.conceallevel = 0
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
  end,
})

-- TOML settings (Cargo.toml, pyproject.toml, etc.)
vim.api.nvim_create_autocmd("FileType", {
  pattern = "toml",
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.expandtab = true
  end,
})

-- TypeScript/JavaScript/Bun settings
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "typescript", "javascript", "typescriptreact", "javascriptreact" },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.expandtab = true
  end,
})

-- Python/UV settings
vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.expandtab = true
    vim.opt_local.colorcolumn = "88" -- black default line length
  end,
})

-- Git commit message settings
vim.api.nvim_create_autocmd("FileType", {
  pattern = "gitcommit",
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
    vim.opt_local.textwidth = 72
    vim.opt_local.colorcolumn = "50,72"
  end,
})

-- Return to last edit position when opening files
vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then pcall(vim.api.nvim_win_set_cursor, 0, mark) end
  end,
})

-- Auto-format on save for specific filetypes (optional - can be toggled)
-- Uncomment if you want aggressive auto-formatting
-- vim.api.nvim_create_autocmd("BufWritePre", {
--   pattern = { "*.tf", "*.hcl", "*.go", "*.rs", "*.ts", "*.js", "*.json", "*.yaml", "*.yml" },
--   callback = function()
--     vim.lsp.buf.format({ async = false, timeout_ms = 3000 })
--   end,
-- })

-- Detect Azure DevOps pipeline files
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = { "*pipeline*.yml", "*pipeline*.yaml", ".azure-pipelines/*" },
  callback = function() vim.bo.filetype = "yaml.azure-pipelines" end,
})

-- Detect Kubernetes manifest files
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = { "*.k8s.yml", "*.k8s.yaml", "*/k8s/*.yml", "*/k8s/*.yaml", "*/kubernetes/*.yml", "*/kubernetes/*.yaml" },
  callback = function() vim.bo.filetype = "yaml.kubernetes" end,
})

-- Bind vim.ui.input / vim.ui.select to snacks UNCONDITIONALLY at polish-time.
-- snacks (loaded eagerly via `lazy = false` in plugins/user.lua) sets these in
-- its own setup() — but on Nvim 0.12 with AstroNvim v6 the wiring doesn't always
-- take, and in headless mode the `User VeryLazy` event never fires. Doing this
-- here is idempotent, sync, and fires the moment init.lua → require("polish")
-- runs (which is AFTER lazy_setup has loaded snacks). Silences
-- :checkhealth ❌ `vim.ui.input not set to Snacks.input`.
-- snacks is loaded eagerly (lazy=false, priority=1000 in plugins/user.lua); we can
-- require it without pcall theatre. A failed require here means polish.lua broke
-- before plugins, which is a hard error worth surfacing.
local snacks = require "snacks"
if snacks.input and type(snacks.input.input) == "function" then vim.ui.input = snacks.input.input end
if snacks.picker and type(snacks.picker.select) == "function" then vim.ui.select = snacks.picker.select end

-- snacks.image module is intentionally disabled (plugins/user.lua: image.enabled=false).
-- Suppress both the M.health() optional-dep probes (gs / tectonic / kitty graphics)
-- AND the M.meta.needs_setup flag that triggers a "setup did not run" ERROR row.
-- pcall keeps polish.lua boot-safe if the image submodule is ever stripped from snacks.
pcall(function()
  local image = require "snacks.image"
  if image then
    image.health = function() end
    if image.meta then image.meta.needs_setup = false end
  end
end)
