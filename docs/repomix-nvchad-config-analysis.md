This file is a merged representation of a subset of the codebase, containing files not matching ignore patterns, combined into a single document by Repomix.

<file_summary>
This section contains a summary of this file.

<purpose>
This file contains a packed representation of a subset of the repository's contents that is considered the most important context.
It is designed to be easily consumable by AI systems for analysis, code review,
or other automated processes.
</purpose>

<file_format>
The content is organized as follows:
1. This summary section
2. Repository information
3. Directory structure
4. Repository files (if enabled)
5. Multiple file entries, each consisting of:
  - File path as an attribute
  - Full contents of the file
</file_format>

<usage_guidelines>
- This file should be treated as read-only. Any changes should be made to the
  original repository files, not this packed version.
- When processing this file, use the file path to distinguish
  between different files in the repository.
- Be aware that this file may contain sensitive information. Handle it with
  the same level of security as you would the original repository.
</usage_guidelines>

<notes>
- Some files may have been excluded based on .gitignore rules and Repomix's configuration
- Binary files are not included in this packed representation. Please refer to the Repository Structure section for a complete list of file paths, including binary files
- Files matching these patterns are excluded: **/test_lsp_files/**
- Files matching patterns in .gitignore are excluded
- Files matching default ignore patterns are excluded
- Files are sorted by Git change count (files with more changes are at the bottom)
</notes>

</file_summary>

<directory_structure>
lua/
  configs/
    conform.lua
    lazy.lua
    lspconfig.lua
  gale/
    aliases.lua
    autocmds.lua
    chadrc_aux.lua
    filetypes.lua
    globals.lua
    linux.lua
    lsp.lua
    telescope.lua
    types.lua
    usercmds.lua
    utils.lua
    vim.lua
    wezterm.lua
    wsl.lua
  plugins/
    local/
      binarypeek.lua
      popurri.lua
    spec/
      autopairs.lua
      better-escape.lua
      ccc.lua
      cdproject.lua
      codesnap.lua
      comment.lua
      crates copy.lua
      crates.lua
      dappython.lua
      dapui.lua
      dapvirtualtext.lua
      debug.lua
      diffview.lua
      dressing.lua
      dropbar.lua
      edgy.lua
      fugitive.lua
      gitsigns copy.lua
      gitsigns.lua
      gleam.lua
      gotopreview.lua
      grugfar.lua
      harpoon.lua
      helpview.lua
      hop.lua
      indentline.lua
      linter.lua
      lspendenhints.lua
      lspsignature.lua
      markview.lua
      matchup.lua
      mdpreview.lua
      multicursor.lua
      mylorem.lua
      neogit.lua
      noice.lua
      obsidian.lua
      oil.lua
      oilvcsstatus.lua
      oneliners.lua
      outline.lua
      precognition.lua
      rainbowdelimiters.lua
      regexplainer.lua
      rustaceanvim.lua
      screenkey.lua
      scrolleof.lua
      showkeys.lua
      statuscol.lua
      supermaven.lua
      telescope.lua
      tinycodeaction.lua
      tinyinlinediagnostic.lua
      todocomments.lua
      treesitter.lua
      treesittertextobjects.lua
      trouble.lua
      tsautotag.lua
      tscontextcommentstring.lua
      undotree.lua
      vimastro.lua
      vimilluminate.lua
      vimvisualmulti.lua
      zen-mode.lua
    init.lua
  autocmds.lua
  bootstrap.lua
  chadrc.lua
  mappings.lua
  options.lua
themes/
  catppuccin-frape.lua
</directory_structure>

<files>
This section contains the contents of the repository's files.

<file path="lua/configs/conform.lua">
local options = {
  formatters_by_ft = {
    lua = { "stylua" },
    -- css = { "prettier" },
    -- html = { "prettier" },
  },

  -- format_on_save = {
  --   -- These options will be passed to conform.format()
  --   timeout_ms = 500,
  --   lsp_fallback = true,
  -- },
}

return options
</file>

<file path="lua/configs/lazy.lua">
return {
  defaults = { lazy = true },
  install = { colorscheme = { "nvchad" } },

  ui = {
    border = "rounded",
    icons = {
      ft = "",
      lazy = "󰂠 ",
      loaded = "",
      not_loaded = "",
    },
  },

  performance = {
    rtp = {
      disabled_plugins = {
        "2html_plugin",
        "tohtml",
        "getscript",
        "getscriptPlugin",
        "gzip",
        "logipat",
        "netrw",
        "netrwPlugin",
        "netrwSettings",
        "netrwFileHandlers",
        "matchit",
        "tar",
        "tarPlugin",
        "rrhelper",
        "spellfile_plugin",
        "vimball",
        "vimballPlugin",
        "zip",
        "zipPlugin",
        "tutor",
        "rplugin",
        "syntax",
        "synmenu",
        "optwin",
        "compiler",
        "bugreport",
        "ftplugin",
      },
    },
  },
}
</file>

<file path="lua/configs/lspconfig.lua">
-- load defaults i.e lua_lsp
require("nvchad.configs.lspconfig").defaults()

local lspconfig = require "lspconfig"
local nvlsp = require "nvchad.configs.lspconfig"

-- List of servers to configure
local servers = { "html", "cssls", "gopls", "pyright", "ts_ls", "terraformls" }

-- Configure each server
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = nvlsp.on_attach,
    on_init = nvlsp.on_init,
    capabilities = nvlsp.capabilities,
  }
end

-- Additional settings for specific servers
lspconfig.gopls.setup {
  on_attach = nvlsp.on_attach,
  on_init = nvlsp.on_init,
  capabilities = nvlsp.capabilities,
  settings = {
    gopls = {
      gofumpt = true,
      usePlaceholders = true,
      completeUnimported = true,
      staticcheck = true,
      semanticTokens = true,
      codelenses = {
        gc_details = false,
        generate = true,
        regenerate_cgo = true,
        test = true,
        tidy = true,
        upgrade_dependency = true,
        vendor = true,
      },
      hints = {
        assignVariableTypes = true,
        compositeLiteralFields = true,
        compositeLiteralTypes = true,
        constantValues = true,
        functionTypeParameters = true,
        parameterNames = true,
        rangeVariableTypes = true,
      },
      analyses = {
        nilness = true,
        unusedparams = true,
        unusedwrite = true,
        useany = true,
      },
    },
  },
}

lspconfig.pyright.setup {
  on_attach = nvlsp.on_attach,
  on_init = nvlsp.on_init,
  capabilities = nvlsp.capabilities,
  settings = {
    python = {
      analysis = {
        -- Enhanced type checking for production
        typeCheckingMode = "strict", -- Changed from "basic" to "strict"
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        -- Performance and reliability settings
        diagnosticMode = "workspace", -- Changed from "openFilesOnly" for better coverage
        autoImportCompletions = true,
        diagnosticSeverityOverrides = {
          reportMissingTypeStubs = "warning",
          reportMissingImports = "error",
          reportMissingModuleSource = "warning",
          reportUnusedImport = "information",
          reportUnusedClass = "information",
          reportUnusedFunction = "information",
          reportUnusedVariable = "warning",
          reportDuplicateImport = "warning",
          reportOptionalSubscript = "warning",
          reportOptionalMemberAccess = "warning",
          reportOptionalCall = "warning",
          reportOptionalIterable = "warning",
          reportOptionalContextManager = "warning",
          reportOptionalOperand = "warning",
          reportTypedDictNotRequiredAccess = "warning",
        },
        -- Workspace and import management
        stubPath = "typings",
        venvPath = ".",
        include = {},
        exclude = {
          "**/node_modules",
          "**/__pycache__",
          ".git",
          ".pytest_cache",
          ".mypy_cache",
          ".tox",
          ".venv",
          "venv",
          "env",
        },
        extraPaths = {},
        -- Enhanced completion and IntelliSense
        completeFunctionCalls = true,
        indexing = true,
        logLevel = "Information",
      },
    },
  },
}

lspconfig.ts_ls.setup {
  on_attach = nvlsp.on_attach,
  on_init = nvlsp.on_init,
  capabilities = nvlsp.capabilities,
  settings = {
    typescript = {
      -- Enhanced type checking and analysis
      suggest = {
        includeCompletionsForModuleExports = true,
        includeAutomaticOptionalChainCompletions = true,
      },
      preferences = {
        quoteStyle = "double",
        includePackageJsonAutoImports = "auto",
        allowIncompleteCompletions = true,
        allowRenameOfImportPath = true,
      },
      -- Strict mode for production
      disableSuggestions = false,
      -- Enhanced inlay hints
      inlayHints = {
        includeInlayParameterNameHints = "all",
        includeInlayParameterNameHintsWhenArgumentMatchesName = false,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = true,
        includeInlayVariableTypeHintsWhenTypeMatchesName = false,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayEnumMemberValueHints = true,
      },
      -- Code actions and refactoring
      updateImportsOnFileMove = {
        enabled = "always",
      },
      -- Workspace symbol search
      workspaceSymbols = {
        search = {
          kind = "allSymbols",
        },
      },
    },
    javascript = {
      -- Enhanced suggestions for JavaScript
      suggest = {
        includeCompletionsForModuleExports = true,
        includeAutomaticOptionalChainCompletions = true,
      },
      preferences = {
        quoteStyle = "double",
        includePackageJsonAutoImports = "auto",
        allowIncompleteCompletions = true,
        allowRenameOfImportPath = true,
      },
      -- Enhanced inlay hints
      inlayHints = {
        includeInlayParameterNameHints = "all",
        includeInlayParameterNameHintsWhenArgumentMatchesName = false,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = true,
        includeInlayVariableTypeHintsWhenTypeMatchesName = false,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayEnumMemberValueHints = true,
      },
      -- Code actions and refactoring
      updateImportsOnFileMove = {
        enabled = "always",
      },
    },
    -- Global completion settings
    completions = {
      completeFunctionCalls = true,
    },
    -- Import organization
    organizeImports = {
      enableCodeAction = true,
    },
  },
}

-- Terraform Language Server (terraformls)
lspconfig.terraformls.setup {
  on_attach = nvlsp.on_attach,
  on_init = nvlsp.on_init,
  capabilities = nvlsp.capabilities,
  cmd = { "terraform-ls", "serve" },
  filetypes = { "terraform", "terraform-vars", "hcl" },
  root_dir = lspconfig.util.root_pattern(".terraform", "*.tf", "*.tfvars"),
  settings = {
    terraform = {
      -- Enhanced validation and formatting
      validation = {
        enableEnhancedValidation = true,
      },
      formatting = {
        enableDocumentFormatting = true,
        enableDocumentRangeFormatting = true,
      },
      -- Language features
      languageServer = {
        -- Enable comprehensive language features
        experimentalFeatures = {
          validateOnSave = true,
          prefillRequiredFields = true,
        },
        -- Code completion settings
        completion = {
          enableAutocomplete = true,
          enableDefinition = true,
          enableReferences = true,
        },
        -- Diagnostics configuration
        diagnostics = {
          -- Enable all diagnostics for production safety
          enableHover = true,
          enableDiagnostics = true,
          enableCodeActions = true,
        },
        -- Module and provider management
        terraform = {
          -- Enable provider and module schema fetching
          requiredVersion = "~> 1.0",
          experimentalFeatures = {
            prefillRequiredFields = true,
          },
        },
        -- Workspace configuration
        workspace = {
          ignoreSingleFileWarning = true,
        },
      },
    },
    terraformls = {
      -- Additional terraform-ls specific settings
      indexing = {
        ignoreDirectoryNames = {
          ".terraform",
          ".git",
          "node_modules",
        },
        ignorePaths = {
          "**/.terraform/**",
          "**/node_modules/**",
        },
      },
    },
  },
}

-- Note: Rust is handled by rustaceanvim plugin
</file>

<file path="lua/gale/aliases.lua">
local alias = require("gale.utils").add_alias

alias("CdProjectTab", "tcdp")

-- Workarounds for my dumb fingers
alias("qa", "Qa")
alias("qa", "QA")
alias("q", "Q")
alias("w", "W")
</file>

<file path="lua/gale/autocmds.lua">
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd
local utils = require "gale.utils"
local buf_map = utils.buf_map

autocmd("LspAttach", {
  desc = "Unattach vtsls if denols is detected.",
  callback = function()
    vim.schedule(function()
      local lsps = vim.lsp.get_clients()
      local is_deno_project = false
      local vtsls_id = -1

      for _, lsp in ipairs(lsps) do
        if lsp.name == "denols" then
          is_deno_project = true
        elseif lsp.name == "vtsls" then
          vtsls_id = lsp.id
        end
      end

      if is_deno_project and vtsls_id ~= -1 then
        vim.lsp.stop_client(vtsls_id)
      end
    end)
  end,
})

autocmd("FileType", {
  desc = "Set custom conceal level in markdown files.",
  pattern = "markdown",
  callback = function()
    if vim.bo.ft == "markdown" then
      vim.opt.conceallevel = 2
    else
      vim.opt.conceallevel = 0
    end
  end,
})

autocmd("LspAttach", {
  desc = "Redraw statusline on attaching lsp.",
  pattern = "*",
  group = augroup("RedrawStatusline", { clear = true }),
  callback = function()
    vim.cmd "redrawstatus"
  end,
})

-- TODO: Fix this
--[[ autocmd("LspAttach", {
  desc = "Display code action sign in gutter if available.",
  pattern = "*",
  group = augroup("UserLspConfig", { clear = true }),
  callback = function()
    autocmd({ "CursorMoved", "CursorMovedI" }, {
      group = augroup("CodeActionSign", { clear = true }),
      callback = function()
        vim.schedule(function()
          utils.code_action_listener()
        end)
      end,
    })
  end,
}) ]]

autocmd("Filetype", {
  desc = "Prevent <Tab>/<S-Tab> from switching specific buffers.",
  pattern = {
    "lazy",
    "mason",
    "Neogit*",
    "qf",
  },
  group = augroup("PreventBufferSwap", { clear = true }),
  callback = function(event)
    local lhs_list = { "<Tab>", "<S-Tab>" }
    buf_map(event.buf, "n", lhs_list, "<nop>")
  end,
})

autocmd("FileType", {
  desc = "Workaround for NvCheatsheet's zindex being higher than Mason's.",
  pattern = "nvcheatsheet",
  group = augroup("FixCheatsheetZindex", { clear = true }),
  callback = function()
    vim.api.nvim_win_set_config(0, { zindex = 44 })
  end,
})

autocmd({ "BufEnter", "FileType" }, {
  desc = "Prevent auto-comment on new line.",
  pattern = "*",
  group = augroup("NoNewLineComment", { clear = true }),
  command = [[
    setlocal formatoptions-=c formatoptions-=r formatoptions-=o
  ]],
})

autocmd({ "BufNewFile", "BufRead" }, {
  desc = "Add support for .mdx files.",
  pattern = { "*.mdx" },
  group = augroup("MdxSupport", { clear = true }),
  callback = function()
    vim.api.nvim_set_option_value("filetype", "markdown", { scope = "local" })
  end,
})

autocmd("VimResized", {
  desc = "Auto resize panes when resizing nvim window.",
  pattern = "*",
  group = augroup("VimAutoResize", { clear = true }),
  command = [[ tabdo wincmd = ]],
})

autocmd("TextYankPost", {
  desc = "Highlight on yank.",
  group = augroup("HighlightOnYank", { clear = true }),
  callback = function()
    vim.highlight.on_yank { higroup = "YankVisual", timeout = 200, on_visual = true }
  end,
})

autocmd("ModeChanged", {
  desc = "Strategically disable diagnostics to focus on editing tasks.",
  pattern = { "n:i", "n:v", "i:v" },
  group = augroup("UserDiagnostic", { clear = true }),
  callback = function()
    vim.diagnostic.enable(false)
  end,
})

autocmd({ "BufRead", "BufNewFile" }, {
  desc = "Disable diagnostics in node_modules.",
  pattern = "*/node_modules/*",
  group = augroup("UserDiagnostic", { clear = true }),
  callback = function()
    vim.diagnostic.enable(false)
  end,
})

autocmd("ModeChanged", {
  desc = "Enable diagnostics upon exiting insert mode to resume feedback.",
  pattern = "i:n",
  group = augroup("UserDiagnostic", { clear = true }),
  callback = function()
    vim.diagnostic.enable(true)
  end,
})

autocmd("BufWritePre", {
  desc = "Remove trailing whitespaces on save.",
  group = augroup("TrimWhitespaceOnSave", { clear = true }),
  command = [[ %s/\s\+$//e ]],
})

autocmd("FileType", {
  desc = "Define windows to close with 'q'",
  pattern = {
    "empty",
    "help",
    "startuptime",
    "qf",
    "query",
    "lspinfo",
    "man",
    "checkhealth",
    "nvcheatsheet",
  },
  group = augroup("WinCloseOnQDefinition", { clear = true }),
  command = [[
    nnoremap <buffer><silent> q :close<CR>
    set nobuflisted
  ]],
})

autocmd("ModeChanged", {
  -- https://github.com/L3MON4D3/LuaSnip/issues/258
  desc = "Prevent weird snippet jumping behavior.",
  pattern = { "s:n", "i:*" },
  group = augroup("PreventSnippetJump", { clear = true }),
  callback = function()
    local ls = require "luasnip"
    local bufnr = vim.api.nvim_get_current_buf()

    if ls.session.current_nodes[bufnr] and not ls.session.jump_active then
      ls.unlink_current()
    end
  end,
})

-- https://unix.stackexchange.com/questions/149209/refresh-changed-content-of-file-opened-in-vim/383044#383044
-- https://vi.stackexchange.com/questions/13692/prevent-focusgained-autocmd-running-in-command-line-editing-mode
autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  desc = "Automatically update changed file in nvim.",
  group = augroup("AutoupdateOnFileChange", { clear = true }),
  command = [[
    if mode() !~ '\v(c|r.?|!|t)' && getcmdwintype() == '' | checktime | endif
  ]],
})

-- https://vi.stackexchange.com/questions/13091/autocmd-event-for-autoread
autocmd("FileChangedShellPost", {
  desc = "Show notification on file change.",
  group = augroup("NotifyOnFileChange", { clear = true }),
  command = [[
    echohl WarningMsg | echo "File changed on disk. Buffer reloaded." | echohl None
  ]],
})

autocmd("User", {
  desc = "Enable line number in Telescope preview.",
  pattern = "TelescopePreviewerLoaded",
  group = augroup("CustomTelescopePreview", { clear = true }),
  callback = function()
    vim.opt_local.number = true
  end,
})

autocmd("TermOpen", {
  desc = "Prevent left click on terminal buffers from exiting insert mode.",
  pattern = "*",
  group = augroup("LeftMouseClickTerm", { clear = true }),
  callback = function(event)
    vim.opt_local.foldcolumn = "0"
    local mouse_actions = {
      "<LeftMouse>",
      "<2-LeftMouse>",
      "<3-LeftMouse>",
      "<4-LeftMouse>",
    }
    buf_map(event.buf, "t", mouse_actions, "<nop>")
  end,
})
</file>

<file path="lua/gale/chadrc_aux.lua">
local M = {}
local utils = require "gale.utils"

local X_COLOURS = {
  SUBTLE_PURPLE = "#7589BF",
  ST_GREY = "#8386A8",
  D_WHITE = "#DDDDDD",
}

M.themes_customs = {
  ["bearded-arc"] = {
    ---@type Base46HLGroupsList
    hl_override = {
      Comment = { fg = X_COLOURS.SUBTLE_PURPLE },
      FloatBorder = { fg = X_COLOURS.SUBTLE_PURPLE },
      LspInlayHint = { fg = X_COLOURS.SUBTLE_PURPLE },
      TelescopeSelection = { fg = X_COLOURS.D_WHITE },
      StText = { fg = X_COLOURS.ST_GREY },
      St_cwd = { fg = "red", bg = "one_bg1" },
      St_NormalMode = { fg = "blue", bg = "one_bg1" },
      St_InsertMode = { fg = "blue", bg = "one_bg1" },
      St_CommandMode = { bg = "one_bg1" },
      St_ConfirmMode = { bg = "one_bg1" },
      St_SelectMode = { bg = "one_bg1" },
      St_VisualMode = { bg = "one_bg1" },
      St_ReplaceMode = { bg = "one_bg1" },
      St_TerminalMode = { bg = "one_bg1" },
      St_NTerminalMode = { bg = "one_bg1" },
      TbBufOn = { link = "Normal" },
      CursorLineNr = { fg = "yellow" },
      ColorColumn = { bg = "black2" },
    },
  },

  ["eldritch"] = {
    ---@type Base46HLGroupsList
    hl_override = {
      NormalFloat = { bg = "black" },
      Comment = { fg = "dark_purple" },
      FloatBorder = { fg = "purple" },
      TelescopeSelection = { bg = "black", fg = X_COLOURS.D_WHITE, bold = true },
      FoldColumn = { fg = "purple" },
      StText = { fg = "light_grey" },
      St_cwd = { bg = "yellow", fg = "black" },
      St_NormalMode = { bg = "blue", fg = "black" },
      St_InsertMode = { bg = "purple", fg = "black" },
      St_CommandMode = { bg = "black", reverse = true },
      St_ConfirmMode = { bg = "black", reverse = true },
      St_SelectMode = { bg = "black", reverse = true },
      St_VisualMode = { bg = "black", reverse = true },
      St_ReplaceMode = { bg = "black", reverse = true },
      St_TerminalMode = { bg = "black", reverse = true },
      St_NTerminalMode = { bg = "black", reverse = true },
      St_HarpoonActive = { link = "St_Ft" },
      CursorLineNr = { fg = "yellow", bold = true },
      MatchWord = { bg = "#444C5B", fg = "#ABB7C1" },
      MatchBackground = { link = "MatchWord" },
      CodeActionSignHl = { fg = "yellow" },
      TbBufOn = { fg = "green" },
      TbBufOnClose = { fg = "baby_pink" },
      TbBufOff = { fg = "nord_blue" },
      TbTabOn = { fg = "baby_pink" },
      TbCloseAllBufsBtn = { bg = "pink", fg = "black" },
      TbTabTitle = { fg = "white", bg = "blue" },
      ColorColumn = { bg = "black2" },
    },
  },
}

--- Show harpoon indicator in statusline
local harpoon_statusline_indicator = function()
  -- inspiration from https://github.com/letieu/harpoon-lualine
  local run = "%@RunHarpoon@"
  local stop = "%X"
  local inactive = "%#St_HarpoonInactive#"
  local active = "%#St_HarpoonActive#"

  local options = {
    icon = active .. " ⇁ ",
    separator = "",
    indicators = {
      inactive .. "q",
      inactive .. "w",
      inactive .. "e",
      inactive .. "r",
      inactive .. "t",
      inactive .. "y",
    },
    active_indicators = {
      active .. "1",
      active .. "2",
      active .. "3",
      active .. "4",
      active .. "5",
      active .. "6",
    },
  }

  local list = require("harpoon"):list()
  local root_dir = list.config:get_root_dir()
  local current_file_path = vim.api.nvim_buf_get_name(0)
  local length = math.min(list:length(), #options.indicators)
  local status = { options.icon }

  local get_full_path = function(root, value)
    if vim.uv.os_uname().sysname == "Windows_NT" then
      return root .. "\\" .. value
    end

    return root .. "/" .. value
  end

  for i = 1, length do
    local value = list:get(i).value
    local full_path = get_full_path(root_dir, value)

    if full_path == current_file_path then
      table.insert(status, options.active_indicators[i])
    else
      table.insert(status, options.indicators[i])
    end
  end

  if length > 0 then
    table.insert(status, " ")
    return run .. table.concat(status, options.separator) .. stop
  else
    return ""
  end
end

local stbufnr = function()
  return vim.api.nvim_win_get_buf(vim.g.statusline_winid or 0)
end

local filename = function()
  local transparency = require("chadrc").base46.transparency
  local hl = ""
  local icon = "  󰈚"
  local path = vim.api.nvim_buf_get_name(stbufnr())
  local name = (path == "" and "Empty") or vim.fs.basename(path)
  local ext = name:match "%.([^%.]+)$" or name

  if name ~= "Empty" then
    local devicons_present, devicons = pcall(require, "nvim-web-devicons")
    if devicons_present then
      local hl_group = "DevIcon" .. ext
      local ok, ft_hl = pcall(vim.api.nvim_get_hl, 0, { name = hl_group })
      if ok and ft_hl.fg then
        local ft_fg = string.format("#%06x", ft_hl.fg)
        local st_hl_name = "St_DevIcon" .. ext
        hl = "%#" .. st_hl_name .. "#"
        vim.api.nvim_set_hl(0, st_hl_name, { bg = transparency and "NONE" or "#242D3D", fg = ft_fg })
        local ft_icon = devicons.get_icon(name)
        icon = (ft_icon ~= nil and "  " .. ft_icon) or ("  " .. icon)
      else
        return
      end
    end
  end

  return hl .. icon .. " %#StText#" .. name
end

local git_custom = function()
  local run = "%@RunNeogit@"
  local stop = "%X"

  local bufnr = stbufnr()
  if not vim.b[bufnr].gitsigns_head or vim.b[bufnr].gitsigns_git_status then
    return ""
  end

  local git_status = vim.b[bufnr].gitsigns_status_dict
  local clear_hl = "%#StText#"
  local add_hl = "%#St_Lsp#"
  local changed_hl = "%#StText#"
  local rm_hl = "%#St_LspError#"
  local branch_hl = "%#St_GitBranch#"

  local added = (git_status.added and git_status.added ~= 0) and (add_hl .. "  " .. clear_hl .. git_status.added)
    or ""
  local changed = (git_status.changed and git_status.changed ~= 0)
      and (changed_hl .. "  " .. clear_hl .. git_status.changed)
    or ""
  local removed = (git_status.removed and git_status.removed ~= 0)
      and (rm_hl .. "  " .. clear_hl .. git_status.removed)
    or ""
  local branch_name = branch_hl .. " " .. clear_hl .. git_status.head

  return run .. " " .. branch_name .. " " .. added .. changed .. removed .. stop
end

local lspx = function()
  local count = 0
  local display = ""
  local run = "%@LspHealthCheck@"
  local stop = "%X"

  if rawget(vim, "lsp") then
    for _, client in ipairs(vim.lsp.get_clients()) do
      if client.attached_buffers[vim.api.nvim_win_get_buf(vim.g.statusline_winid or 0)] then
        count = count + 1
        display = (vim.o.columns > 100 and run .. " %#St_Lsp#  LSP ~ " .. client.name .. " " .. stop)
          or run .. " %#St_Lsp#  LSP " .. stop
      end
    end
  end

  if count > 1 then
    return run .. " %#St_Lsp#  LSP (" .. count .. ") " .. stop
  else
    return display
  end
end

M.modules = {
  ---@type table<string, string|fun():string>
  statusline = {
    separator = " ", -- Add space between modules
    hack = "%#@comment#%", -- Hack to make module highlight visible
    tint = "%#StText#", -- Force grey on modules that absorb neighbour colour
    oil_dir_cwd = "%@OilDirCWD@",
    force_stop = "%X",

    modified = function()
      return vim.bo.modified and " *" or " "
    end, -- Show modified indicator

    bufnr = function()
      local bufnr = vim.api.nvim_get_current_buf()
      return "%#StText#" .. tostring(bufnr)
    end, -- Show current buffer number in statusline

    filename = filename,
    git_custom = git_custom,
    harpoon = harpoon_statusline_indicator,
    word_count = function()
      return " %#StText#󱀽" .. utils.count_words_in_line() .. utils.count_words_in_buffer()
    end,
  },

  ---@type table<string, fun():string>
  tabufline = {
    fill = function()
      return "%#TbFill#%="
    end, -- Fill tabufline with TbFill hl
  },

  lspx = lspx,
}

return M
</file>

<file path="lua/gale/filetypes.lua">
vim.filetype.add {
  extension = {
    jsonl = "json",
  },
}

vim.api.nvim_create_autocmd("FileType", {
  desc = "Unattach jsonls from jsonl buffers.",
  pattern = "json",
  callback = function(args)
    vim.schedule(function()
      if not args.data then
        return
      end

      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if not client then
        return
      end

      local bufname = vim.api.nvim_buf_get_name(args.buf)
      if client.name == "jsonls" and bufname:match "%.jsonl$" then
        vim.schedule(function()
          vim.lsp.stop_client(client.id)
        end)
      end
    end)
  end,
})
</file>

<file path="lua/gale/globals.lua">
-- Automatically detect context for comment string
_G.__toggle_contextual = function(mode)
  local cfg = require("Comment.config"):get()
  local U = require "Comment.utils"
  local Op = require "Comment.opfunc"
  local range = U.get_region(mode)
  local same_line = range.srow == range.erow

  local ctx = {
    cmode = U.cmode.toggle,
    range = range,
    cmotion = U.cmotion[mode] or U.cmotion.line,
    ctype = same_line and U.ctype.linewise or U.ctype.blockwise,
  }

  local lcs, rcs = U.parse_cstr(cfg, ctx)
  local lines = U.get_lines(range)

  local params = {
    range = range,
    lines = lines,
    cfg = cfg,
    cmode = ctx.cmode,
    lcs = lcs,
    rcs = rcs,
    cfg,
  }

  if same_line then
    Op.linewise(params)
  else
    Op.blockwise(params)
  end
end

---@param case_table table
-- Add Switch/Case functionality
_G.switch = function(param, case_table)
  local case = case_table[param]
  if case then
    return case()
  end
  local def = case_table["default"]
  return def and def() or nil
end
</file>

<file path="lua/gale/linux.lua">
if vim.fn.has "unix" ~= 1 or vim.fn.has "macunix" == 1 or vim.fn.has "wsl" == 1 then
  return
end

-- Function to check if a command exists
local function command_exists(cmd)
  return vim.fn.executable(cmd) == 1
end

-- Check for available clipboard tools
local clipboard_tool = ""
if command_exists "xclip" then
  clipboard_tool = "xclip -selection clipboard"
elseif command_exists "xsel" then
  clipboard_tool = "xsel --clipboard --input"
elseif command_exists "wl-copy" then
  clipboard_tool = "wl-copy"
else
  -- Try to install xclip on Ubuntu/Debian systems
  if command_exists "apt-get" then
    print "Clipboard tool not found. Attempting to install xclip..."
    os.execute "sudo apt-get update && sudo apt-get install -y xclip"
    if command_exists "xclip" then
      clipboard_tool = "xclip -selection clipboard"
      print "xclip installed successfully."
    else
      print "Failed to install xclip. Please install xclip, xsel, or wl-copy manually."
      return
    end
  else
    print "No clipboard tool found. Please install xclip, xsel, or wl-copy manually."
    return
  end
end

vim.g.clipboard = {
  name = "linux-clipboard",
  copy = {
    ["+"] = clipboard_tool,
    ["*"] = clipboard_tool,
  },
  paste = {
    ["+"] = clipboard_tool == "wl-copy" and "wl-paste" or (clipboard_tool .. " -o"),
    ["*"] = clipboard_tool == "wl-copy" and "wl-paste" or (clipboard_tool .. " -o"),
  },
  cache_enabled = 0,
}
</file>

<file path="lua/gale/lsp.lua">
local M = {}

---@alias OnAttach fun(client: vim.lsp.Client, bufnr: integer)
---@alias OnInit fun(client: vim.lsp.Client, initialize_result: lsp.InitializeResult)

---@type OnAttach
local on_attach = function(_, bufnr)
  local map = function(mode, lhs, rhs, opts)
    local options = { buffer = bufnr }
    if opts then
      options = vim.tbl_deep_extend("force", options, opts)
    end
    vim.keymap.set(mode, lhs, rhs, options)
  end

  map("n", "gd", vim.lsp.buf.definition, { desc = "LSP go to definition" })
  map("n", "gi", vim.lsp.buf.implementation, { desc = "LSP go to implementation" })
  map("n", "<leader>gd", vim.lsp.buf.declaration, { desc = "LSP go to declaration" })
  map("n", "<leader>sh", vim.lsp.buf.signature_help, { desc = "LSP show signature help" })
  map("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, { desc = "LSP add workspace folder" })
  map("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, { desc = "LSP remove workspace folder" })
  map("n", "<leader>gr", vim.lsp.buf.references, { desc = "LSP show references" })
  map("n", "<leader>gt", vim.lsp.buf.type_definition, { desc = "LSP go to type definition" })

  map("n", "<leader>wl", function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, { desc = "LSP list workspace folders" })

  map("n", "<leader>ra", function()
    require "nvchad.lsp.renamer"()
  end, { desc = "LSP rename" })
end

---@param custom_on_attach? OnAttach
---@return OnAttach # A new function that combines default and custom on_attach behaviour
M.generate_on_attach = function(custom_on_attach)
  return function(client, bufnr)
    on_attach(client, bufnr)

    if custom_on_attach then
      custom_on_attach(client, bufnr)
    end
  end
end

---@type OnInit
M.on_init = function(client, _)
  if client:supports_method "textDocument/semanticTokens" then
    client.server_capabilities.semanticTokensProvider = nil
  end
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem = {
  documentationFormat = { "markdown", "plaintext" },
  snippetSupport = true,
  preselectSupport = true,
  insertReplaceSupport = true,
  labelDetailsSupport = true,
  deprecatedSupport = true,
  commitCharactersSupport = true,
  tagSupport = { valueSet = { 1 } },
  resolveSupport = {
    properties = {
      "documentation",
      "detail",
      "additionalTextEdits",
    },
  },
}

M.capabilities = capabilities

M.lsp = {
  vtsls = {
    inlay_hints_settings = {
      parameterNames = {
        enabled = "all",
      },
      parameterTypes = {
        enabled = true,
      },
      variableTypes = {
        enabled = true,
      },
      propertyDeclarationTypes = {
        enabled = true,
      },
      functionLikeReturnTypes = {
        enabled = true,
      },
    },
  },
}

return M
</file>

<file path="lua/gale/telescope.lua">
-- Inspired in <https://github.com/xzbdmw/nvimconfig/blob/main/lua/custom/telescope-pikers.lua>
-- and <https://github.com/nvim-telescope/telescope.nvim/issues/2014#issuecomment-1541423345>
local M = {}

local entry_display = require "telescope.pickers.entry_display"
local make_entry = require "telescope.make_entry"
local strings = require "plenary.strings"
local utils = require "telescope.utils"

-- local devicons = require "nvim-web-devicons"
-- local icon_width = strings.strdisplaywidth(devicons.get_icon("fname", { default = true }))
local icon_width = 2 -- offers the best results

local get_path_and_tail = function(file_name)
  local tail = utils.path_tail(file_name)
  local truncated_path = strings.truncate(file_name, #file_name - #tail, "")

  local path = utils.transform_path({
    path_display = { "truncate" },
  }, truncated_path)

  return tail, path
end

---@param filetype "find" | "old"
---@param opts? table
-- Generate a custom file finder picker
local files = function(filetype, opts)
  local files_opts = {
    previewer = false,
    layout_config = {
      horizontal = {
        width = 0.35,
        height = 0.7,
      },
      mirror = false,
    },
  }

  local oldfiles_opts = {
    previewer = false,
    layout_config = {
      prompt_position = "top",
      width = 0.4,
      height = 0.95,
      mirror = true,
      preview_cutoff = 0,
    },
  }

  local picker_data
  if filetype == "find" then
    picker_data = {
      picker = "find_files",
      options = opts and vim.tbl_deep_extend("force", files_opts, opts) or files_opts,
    }
  elseif filetype == "old" then
    picker_data = {
      cwd_only = false,
      picker = "oldfiles",
      options = opts and vim.tbl_deep_extend("force", oldfiles_opts, opts) or oldfiles_opts,
    }
  end

  if type(picker_data) ~= "table" or picker_data.picker == nil then
    return
  end

  local options = picker_data.options or {}
  local base_entry_maker = make_entry.gen_from_file(options)

  options.entry_maker = function(line)
    local base_entry_table = base_entry_maker(line)

    local displayer = entry_display.create {
      separator = " ",
      items = {
        { width = icon_width },
        { width = nil },
        { remaining = true },
      },
    }

    base_entry_table.display = function(entry)
      local tail, path_to_display = get_path_and_tail(entry.value)
      local tail_to_display = tail
      local icon, icon_highlight = utils.get_devicons(tail)

      return displayer {
        { icon, icon_highlight },
        { tail_to_display },
        { path_to_display, "@comment" },
      }
    end

    return base_entry_table
  end

  if picker_data.picker == "find_files" then
    require("telescope.builtin").find_files(options)
  elseif picker_data.picker == "git_files" then
    require("telescope.builtin").git_files(options)
  elseif picker_data.picker == "oldfiles" then
    require("telescope.builtin").oldfiles(options)
  elseif picker_data.picker == "" then
    print "Picker was not specified"
  else
    print "Picker is not supported"
  end
end

---@param search "grep_string" | "egrepify" | "agitator" | "live_grep"
---@param default_text string | nil
---@param filetype string | nil
---@param opts? table
-- Generate a custom live grep picker
local grep = function(search, default_text, filetype, opts)
  local grep_opts = {
    layout_strategy = "vertical",
    layout_config = {
      vertical = {
        prompt_position = "top",
        width = 0.8,
        height = 0.95,
        mirror = true,
        preview_cutoff = 0,
        preview_height = 0.5,
      },
    },
  }

  local picker_data = {
    picker = search,
    options = opts and vim.tbl_deep_extend("force", grep_opts, opts) or grep_opts,
  }

  local escape_for_ripgrep = function(text)
    local escapes = {
      ["\\"] = [[\]],
      ["^"] = [[\^]],
      ["$"] = [[\$]],
      ["."] = [[\.]],
      ["["] = [[\[]],
      ["]"] = "\\]",
      ["("] = [[\(]],
      [")"] = [[\)]],
      ["{"] = [[\{]],
      ["}"] = [[\}]],
      ["*"] = [[\*]],
      ["+"] = [[\+]],
      ["-"] = [[\-]],
      ["?"] = [[\?]],
      ["|"] = [[\|]],
      ["#"] = [[\#]],
      ["&"] = [[\&]],
      ["%"] = [[\%]],
    }

    return text:gsub(".", function(c)
      return escapes[c] or c
    end)
  end

  if default_text then
    if filetype == nil then
      picker_data.options.default_text = default_text
      picker_data.options.initial_mode = "insert"
    else
      local escaped_text = escape_for_ripgrep(default_text)
      local reformated_body = escaped_text:gsub("%s*\r?\n%s*", " ")

      if filetype == "rust" then
        filetype = "rs"
      end

      if filetype ~= "" then
        picker_data.options.default_text = "`" .. filetype .. " " .. reformated_body
      else
        picker_data.options.default_text = reformated_body
      end

      picker_data.options.initial_mode = "normal"
    end
  end

  if type(picker_data) ~= "table" or picker_data.picker == nil then
    return
  end

  local options = picker_data.options or {}
  local base_entry_maker = make_entry.gen_from_vimgrep(options)

  options.entry_maker = function(line)
    local base_entry_table = base_entry_maker(line)

    local displayer = entry_display.create {
      separator = " ",
      items = {
        { width = icon_width },
        { width = nil },
        { remaining = true },
      },
    }

    base_entry_table.display = function(entry)
      local tail, _ = get_path_and_tail(entry.filename)
      local icon, icon_highlight = utils.get_devicons(tail)

      -- Add coordinates if required by `options`
      local coordinates = ""

      if not options.disable_coordinates then
        if entry.lnum then
          coordinates = string.format(":%s", entry.lnum)
        end
      end

      -- Append coordinates to tail
      tail = tail .. coordinates
      local tail_to_display = tail

      -- Encode text if necessary
      local text = options.file_encoding and vim.iconv(entry.text, options.file_encoding, "utf8") or entry.text
      text = "  " .. text

      return displayer {
        { icon, icon_highlight },
        { tail_to_display },
        { text, "@comment" },
      }
    end

    return base_entry_table
  end

  if picker_data.picker == "live_grep" then
    require("telescope.builtin").live_grep(options)
  elseif picker_data.picker == "grep_string" then
    require("telescope.builtin").grep_string(options)
  elseif picker_data.picker == "egrepify" then
    require("telescope").extensions.egrepify.egrepify(options)
  elseif picker_data.picker == "agitator" then
    options.preview = {
      timeout = 10000,
    }
    require("agitator").search_in_added(options)
  elseif picker_data.picker == "" then
    print "Picker was not specified"
  else
    print "Picker is not supported"
  end
end

---@param previewer boolean
---@param opts? table
--- Generate a custom buffer picker
local buffers = function(previewer, opts)
  local buf_opts = {
    bufnr_width = 0,
    layout_strategy = "horizontal",
    previewer = false,
    layout_config = {
      horizontal = {
        width = 0.35,
        height = 0.7,
      },
      mirror = false,
    },
  }

  if previewer then
    buf_opts = opts and vim.tbl_deep_extend("force", buf_opts, opts) or buf_opts
  end

  if buf_opts ~= nil and type(buf_opts) ~= "table" then
    return
  end

  local options = buf_opts or {}
  local base_entry_maker = make_entry.gen_from_buffer(options)

  options.entry_maker = function(line)
    local base_entry_table = base_entry_maker(line)

    local displayer = entry_display.create {
      separator = " ",
      items = {
        { width = icon_width },
        { width = nil },
        { remaining = true },
      },
    }

    base_entry_table.display = function(entry)
      local tail, path = get_path_and_tail(entry.filename)
      local tail_to_display = tail
      local icon, icon_highlight = utils.get_devicons(tail)

      return displayer {
        { icon, icon_highlight },
        { tail_to_display },
        { path, "@comment" },
      }
    end

    return base_entry_table
  end

  require("telescope.builtin").buffers(options)
end

M.pickers = {
  files = files,
  grep = grep,
  buffers = buffers,
}

return M
</file>

<file path="lua/gale/types.lua">
return {
  { "Bilal2453/luvit-meta" },
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        { path = "luvit-meta/library", words = { "vim%.uv" } },
        {
          path = vim.fn.stdpath "data" .. "/lazy/ui/nvchad_types",
          words = { "ChadrcConfig", "NvPluginSpec", "Base46Table", "Base46HLGroupsList" },
        },
        { path = "wezterm-types", mods = { "wezterm" } },
        -- vim.fn.expand "$HOME/workspace/neovim/ui/nvchad_types", -- get types when dev = true
      },
    },
  },
}
</file>

<file path="lua/gale/usercmds.lua">
local create_cmd = vim.api.nvim_create_user_command
local utils = require "gale.utils"

create_cmd("CombineLists", utils.combine_lists, {})
create_cmd("MergeLists", utils.combine_lists, {})

create_cmd("WipeReg", function()
  utils.clear_registers()
  vim.notify(" Registers cleared and shada file successfully updated.", vim.log.levels.INFO)
end, { desc = "Wipe registers" })

create_cmd("ToggleWordCount", function()
  if vim.g.st_words_in_buffer then
    vim.g.st_words_in_buffer = false
    vim.g.st_words_in_line = true
  else
    vim.g.st_words_in_buffer = true
    vim.g.st_words_in_line = false
  end
end, { desc = "Toggle word count mode (line/buffer)" })

create_cmd("TabuflineToggle", function()
  if vim.g.tabufline_visible then
    vim.o.showtabline = 0
    vim.g.tabufline_visible = false
  else
    vim.o.showtabline = 2
    vim.g.tabufline_visible = true
  end
end, { desc = "Toggle Tabufline" })

create_cmd("SrcPlugins", function()
  local script = vim.fn.stdpath "config"
  vim.cmd("luafile " .. script .. "/scripts/update-lazy-imports.lua")
end, { desc = "Update plugins imports" })

create_cmd("SrcFile", function()
  if vim.bo.filetype ~= "" then
    vim.cmd "so %"
    vim.notify.dismiss() ---@diagnostic disable-line
    vim.notify(vim.fn.expand "%" .. " sourced!", vim.log.levels.INFO)
  else
    vim.notify.dismiss() ---@diagnostic disable-line
    vim.notify("No file to source", vim.log.levels.ERROR)
  end
end, { desc = "Source current file" })

create_cmd("TabbyStart", function()
  require("gale.tabby").start()
end, { desc = "Start TabbyML docker container" })

create_cmd("TabbyStop", function()
  require("gale.tabby").stop()
end, { desc = "Stop TabbyML docker container" })

create_cmd("ToggleInlayHints", function()
  ---@diagnostic disable-next-line
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end, { desc = "Toogle inlay hints in current buffer" })

create_cmd("DiagnosticsVirtualTextToggle", function()
  local current_value = vim.diagnostic.config().virtual_text
  if current_value then
    vim.diagnostic.config { virtual_text = false }
  else
    vim.diagnostic.config { virtual_text = true }
  end
end, { desc = "Toggle inline diagnostics" })

create_cmd("DiagnosticsToggle", function()
  local current_value = vim.diagnostic.is_enabled()
  if current_value then
    vim.diagnostic.enable(false)
  else
    vim.diagnostic.enable(true)
  end
end, { desc = "Toggle diagnostics" })

create_cmd("DapUIToggle", function()
  require("dapui").toggle()
end, { desc = "Open DapUI" })

create_cmd("UpdateAll", function()
  require("lazy").load { plugins = { "mason.nvim", "nvim-treesitter" } }
  vim.cmd "MasonUpdate"
  vim.cmd "TSUpdate"
  vim.cmd "Lazy sync"
end, { desc = "Batch update" })

create_cmd("FormatToggle", function(args)
  local is_global = not args.bang
  if is_global then
    vim.g.disable_autoformat = not vim.g.disable_autoformat
    if vim.g.disable_autoformat then
      vim.notify("Format on save disabled", vim.log.levels.WARN)
    else
      vim.notify("Format on save enabled", vim.log.levels.INFO)
    end
  else
    vim.b.disable_autoformat = not vim.b.disable_autoformat
    if vim.b.disable_autoformat then
      vim.notify("Format on save disabled for this buffer", vim.log.levels.WARN)
    else
      vim.notify("Format on save enabled for this buffer", vim.log.levels.INFO)
    end
  end
end, {
  desc = "Toggle format on save",
  bang = true,
})

create_cmd("FormatFile", function()
  require("conform").format { lsp_fallback = true }
end, { desc = "Format files via conform" })

create_cmd("FormatProject", function()
  local project_dir = vim.fn.getcwd()
  local lua_files = vim.fn.systemlist("find " .. project_dir .. ' -type f -name "*.lua"')
  for _, path in ipairs(lua_files) do
    utils.format_file(path)
  end
end, { desc = "Format project via conform" })

create_cmd("VerifyLSP", function()
  local verify_script = vim.fn.stdpath "config" .. "/test_lsp_files/verify_lsp.lua"
  if vim.fn.filereadable(verify_script) == 1 then
    vim.cmd("luafile " .. verify_script)
  else
    vim.notify("LSP verification script not found at: " .. verify_script, vim.log.levels.ERROR)
  end
end, { desc = "Verify LSP configuration and test functionality" })
</file>

<file path="lua/gale/utils.lua">
---@class Utils
--- Add an alias to any existing command
---@field add_alias fun(target_cmd: string, alias: string)
--- Check if any value is a table
---@field is_tbl fun(v: any): boolean
--- Create a global keymap
---@field glb_map fun(mode: string | table, lhs: string | table, rhs: string | fun(), opts?: table | nil)
--- Create a keymap local to buffer
---@field buf_map fun(buf?: integer, mode: string | table, lhs: string | table, rhs: string | fun(), opts?: table)
--- Delete keymap/s globally. Does not attempt to unmap if keymap does not exist.
---@field del_map fun(mode: string | table, trigger: string | table)
--- Format a file based on its path, using conform
---@field format_file fun(file_path: string)
--- Helper function to match valid "words" in a line
---@field word_iterator fun(line: string): function
--- Helper function to count valid "words" in a line
---@field count_with_exclude fun(line: string, opts?: table): integer
--- Return count of valid "words" in a line as a string
---@field count_words_in_line fun(): string
--- Return count of valid "words" in a buffer as a string
---@field count_words_in_buffer fun(): string
--- Debounce a function by timeout
---@field debounce fun(func: function, timeout: integer): function
--- Combine two lists of strings
---@field combine_lists fun()
local M = {}

M.add_alias = function(target_cmd, alias)
  vim.cmd("ca " .. alias .. " " .. target_cmd)
end

M.is_tbl = function(v)
  if type(v) == "table" then
    return true
  else
    return false
  end
end

M.glb_map = function(mode, lhs, rhs, opts)
  local options = { noremap = true, silent = true }

  if opts then
    options = vim.tbl_extend("force", options, opts)
  end

  if M.is_tbl(lhs) then
    ---@cast lhs table
    for _, trigger in ipairs(lhs) do
      vim.keymap.set(mode, trigger, rhs, options)
    end
  else
    ---@cast lhs string
    vim.keymap.set(mode, lhs, rhs, options)
  end
end

M.buf_map = function(bufnr, mode, lhs, rhs, opts)
  opts = opts or {}
  opts.buffer = bufnr and bufnr or 0
  M.glb_map(mode, lhs, rhs, opts)
end

local map_exists = function(name, map_mode)
  local check = vim.fn.maparg(name, map_mode)
  if check == "" then
    return false
  elseif check == {} then
    return false
  else
    return true
  end
end

M.del_map = function(mode, trigger)
  local del = vim.api.nvim_del_keymap
  local is_tbl = M.is_tbl

  local get_case = function(vmode, lhs)
    if not is_tbl(vmode) and not is_tbl(lhs) then
      return 1
    elseif not is_tbl(vmode) and is_tbl(lhs) then
      return 2
    elseif is_tbl(vmode) and not is_tbl(lhs) then
      return 3
    elseif is_tbl(vmode) and is_tbl(lhs) then
      return 4
    end
  end

  local case = get_case(mode, trigger)
  switch(case, {
    [1] = function()
      ---@cast mode string
      ---@cast trigger string
      if map_exists(trigger, mode) then
        del(mode, trigger)
      end
    end,
    [2] = function()
      ---@cast mode string
      ---@cast trigger table
      for _, triggerval in ipairs(trigger) do
        if map_exists(triggerval, mode) then
          del(mode, triggerval)
        end
      end
    end,
    [3] = function()
      ---@cast mode table
      ---@cast trigger string
      for _, modeval in ipairs(mode) do
        if map_exists(trigger, modeval) then
          del(modeval, trigger)
        end
      end
    end,
    [4] = function()
      ---@cast mode table
      ---@cast trigger table
      for _, modeval in ipairs(mode) do
        for _, triggerval in ipairs(trigger) do
          if map_exists(triggerval, modeval) then
            del(modeval, triggerval)
          end
        end
      end
    end,
  })
end

local is_inspect_tree_open = function()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    local buf_name = vim.api.nvim_get_option_value("filetype", { buf = buf })
    if buf_name and buf_name == "query" then
      return true, win
    end
  end
  return false, nil
end

--- Toggle treesitter inspection tree
M.toggle_inspect_tree = function()
  local open, win = is_inspect_tree_open()
  if open then
    ---@cast win integer
    local bufnr = vim.api.nvim_win_get_buf(win)
    vim.api.nvim_buf_delete(bufnr, { force = true })
  else
    vim.cmd "InspectTree"
  end
end

--- Navigate to plugin repo if valid string name under cursor
M.go_to_github_link = function()
  local ts = vim.treesitter
  local node = ts.get_node()

  if not node then
    return
  end

  local string = ts.get_node_text(node, 0)

  local is_github_string = function(str)
    local _, count = str:gsub("/", "")
    return count == 1
  end

  if string then
    local is_valid_string = is_github_string(string)

    if is_valid_string then
      local gh_link = string.format("https://github.com/%s.git", string)
      vim.ui.open(gh_link)
    else
      vim.notify.dismiss() ---@diagnostic disable-line
      vim.notify(" Not a valid GitHub string", vim.log.levels.ERROR, { icon = "" })
      return
    end
  else
    vim.notify.dismiss() ---@diagnostic disable-line
    vim.notify(" Not a string", vim.log.levels.ERROR, { icon = "" })
    return
  end
end

M.format_file = function(file_path)
  local bufnr = vim.fn.bufadd(file_path)
  vim.fn.bufload(bufnr)

  require("conform").format {
    lsp_fallback = true,
    bufnr = bufnr,
  }

  if vim.api.nvim_get_option_value("modified", { buf = bufnr }) then
    vim.api.nvim_buf_call(bufnr, function()
      vim.cmd "w"
    end)
  end

  vim.api.nvim_buf_delete(bufnr, { force = true })
end

--- Listener for code actions capabilities
-- TODO: Fix this
M.code_action_listener = function()
  local buffer = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients { bufnr = buffer }

  if clients == nil or #clients == 0 then
    return
  end

  local has_code_action_support = vim.tbl_filter(function(client)
    return client.server_capabilities.codeActionProvider
  end, clients)[1] ~= nil

  if has_code_action_support then
    -- local context = { diagnostics = vim.lsp.diagnostic.get_line_diagnostics(buffer) }
    local params = vim.lsp.util.make_range_params(0, "utf-8")
    -- params.context = context

    vim.lsp.buf_request(buffer, "textDocument/codeAction", params, function(_, result, _, _)
      vim.fn.sign_unplace("code_action_gear", { buffer = buffer })

      if result and next(result) then
        vim.fn.sign_place(
          0,
          "code_action_gear",
          "CodeActionSign",
          buffer,
          { lnum = vim.api.nvim_win_get_cursor(0)[1], priority = 100 }
        )
      end
    end)
  end
end

M.handle_copy = function()
  local mode = vim.fn.mode()
  if mode == "v" or mode == "V" or mode == "" then
    if vim.fn.line "'<" == vim.fn.line "'>" and vim.fn.col "'<" == vim.fn.col "'>" then
      vim.cmd.normal '"+yy'
    else
      vim.cmd.normal '"+y'
    end
  else
    vim.cmd.normal '"+yy'
  end
end

M.handle_paste = function()
  vim.cmd.normal '"+p'
end

M.menus = {
  main = {
    --[[ {
      name = "  Copy",
      cmd = M.handle_copy,
    },
    {
      name = "  Paste",
      cmd = M.handle_paste,
    },
    { name = "separator" }, ]]
    {
      name = "󰉁 Lsp Actions",
      hl = "Exblue",
      items = "lsp",
    },
    { name = "separator" },
    {
      name = "  Color Picker",
      hl = "Exred",
      cmd = function()
        require("minty.huefy").open()
      end,
    },
  },
}

M.word_iterator = function(line)
  -- Match sequences of alphanumeric characters, underscores, periods, or hyphens
  local pattern = "[%w_%-%.]+"
  return function()
    return string.gmatch(line, pattern)
  end
end

M.count_with_exclude = function(line, opts)
  opts = opts or {}
  local word_count = 0
  for word in M.word_iterator(line)() do
    if word ~= opts.exclude then
      word_count = word_count + 1
    end
  end
  return word_count
end

vim.g.st_words_in_line = true
M.count_words_in_line = function()
  local line = vim.api.nvim_get_current_line()
  local word_count = M.count_with_exclude(line, { exclude = ".." })
  if vim.g.st_words_in_line then
    return string.format(" %%#St_GitBranch#%d ", word_count)
  else
    return ""
  end
end

M.count_words_in_buffer = function()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local total_word_count = 0
  for _, line in ipairs(lines) do
    total_word_count = total_word_count + M.count_with_exclude(line, { exclude = ".." })
  end
  if vim.g.st_words_in_buffer then
    return string.format(" %d ", total_word_count)
  else
    return ""
  end
end

M.clear_registers = function()
  vim.cmd "rshada!"

  for i = 0, 9 do
    vim.fn.setreg(tostring(i), "")
  end

  for char = string.byte "a", string.byte "z" do
    vim.fn.setreg(string.char(char), "")
    vim.fn.setreg(string.char(char):upper(), "")
  end

  local special_registers = { '"', "-", "_", "*", "+", "=" }
  for _, reg in ipairs(special_registers) do
    vim.fn.setreg(reg, "")
  end

  if vim.fn.bufname "#" ~= "" then
    vim.fn.setreg("#", "")
  end

  vim.cmd "let @/ = ''"

  vim.cmd "wshada!"
end

M.harpoon_menu = function()
  local harpoon = require "harpoon"
  harpoon.ui:toggle_quick_menu(harpoon:list(), {
    title = " Harpoon btw ",
    title_pos = "center",
    border = "rounded",
    ui_width_ratio = 0.40,
  })
end

M.debounce = function(func, timeout)
  local timer = vim.uv.new_timer()
  return function(...)
    timer:stop()
    local args = { ... }
    timer:start(timeout, 0, function()
      vim.schedule_wrap(func)(unpack(args))
    end)
  end
end

M.combine_lists = function()
  local bufnr = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  -- Find the first empty line that acts as a separator.
  -- We use a pattern to catch any whitespace-only line.

  local separator_index = nil
  for i, line in ipairs(lines) do
    if line:match "^%s*$" then
      separator_index = i
      break
    end
  end

  if not separator_index then
    vim.notify("Separator (empty line) not found!", vim.log.levels.ERROR)
    return
  end

  -- Build list1 (lines before the separator) and list2 (lines after)
  local list1 = {}
  local list2 = {}

  for i = 1, separator_index - 1 do
    table.insert(list1, lines[i])
  end

  for i = separator_index + 1, #lines do
    table.insert(list2, lines[i])
  end

  if #list1 ~= #list2 then
    vim.notify("The lists have different lengths!", vim.log.levels.ERROR)
    return
  end

  -- Combine the two lists, adding " - " between each pair.
  local combined = {}
  for i = 1, #list1 do
    table.insert(combined, list1[i] .. " - " .. list2[i])
  end

  -- Replace the entire buffer with the combined lines.
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, combined)
  vim.notify "Lists combined successfully!"
end

return M
</file>

<file path="lua/gale/vim.lua">
vim.cmd [[
  function! LspHealthCheck(...)
    LspInfo
  endfunction
]]

vim.cmd [[
  function! RunNeogit(...)
    lua require("neogit").open()
  endfunction
]]

vim.cmd [[
  function! RunHarpoon(...)
    RunHarpoon
  endfunction
]]

vim.cmd [[
  function! OilDirCWD(...)
    Oil ./
  endfunction
]]
</file>

<file path="lua/gale/wezterm.lua">
if not vim.g.is_wsl then
  return {}
end

local is_wezterm = function()
  local term = vim.fn.getenv "TERM_PROGRAM"
  return term == "WezTerm"
end

if not is_wezterm() then
  return {}
end

return {
  { "justinsgithub/wezterm-types" },
}
</file>

<file path="lua/gale/wsl.lua">
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
</file>

<file path="lua/plugins/local/binarypeek.lua">
---@type NvPluginSpec
return {
  "mgastonportillo/binary-peek.nvim",
  enabled = false,
  dev = true,
  name = "binary-peek",
  event = "VeryLazy",
  init = function()
    local map = vim.keymap.set
    map("n", "<leader>bs", "<cmd>BinaryPeek<CR>", { desc = "BinaryPeek start" })
    map("n", "<leader>bx", "<cmd>BinaryPeek abort<CR>", { desc = "BinaryPeek abort" })
  end,
  config = true,
}
</file>

<file path="lua/plugins/local/popurri.lua">
---@type NvPluginSpec
return {
  "mgastonportillo/popurri.nvim",
  enabled = false, -- needs a couple fixes
  dev = true,
  cmd = "Popurri",
  init = function()
    vim.keymap.set("n", "<leader>pp", "<cmd>Popurri<CR>", { desc = "Toggle Popurri" })
  end,
  opts = {
    default_query = "args",
  },
}
</file>

<file path="lua/plugins/spec/autopairs.lua">
-- autopairs
-- https://github.com/windwp/nvim-autopairs
---@type NvPluginSpec
return {
  "windwp/nvim-autopairs",
  event = "InsertEnter",
  opts = {},
}
</file>

<file path="lua/plugins/spec/better-escape.lua">
---@type NvPluginSpec
return {
  "max397574/better-escape.nvim",
  event = "InsertEnter",
  config = function()
    require("better_escape").setup()
  end,
}
</file>

<file path="lua/plugins/spec/ccc.lua">
---@type NvPluginSpec
return {
  "uga-rosa/ccc.nvim",
  cmd = { "CccPick", "CccConvert", "CccHighlighterToggle" },
  init = function()
    local map = vim.keymap.set
    map("n", "cc", "<cmd>CccConvert<CR>", { desc = "Change Color space" })
    map("n", "ch", "<cmd>CccHighlighterToggle<CR>", { desc = "Toggle Color highlighter" })
  end,
  config = function()
    require("ccc").setup {
      highlighter = {
        auto_enable = false,
        lsp = true,
      },
    }
  end,
}
</file>

<file path="lua/plugins/spec/cdproject.lua">
---@type NvPluginSpec
return {
  "LintaoAmons/cd-project.nvim",
  dev = false,
  event = "VimEnter",
  opts = {
    projects_config_filepath = vim.fn.expand "~/.cd-project.nvim.json",
    projects_picker = "telescope", -- "vim-ui" | "telescope"
    hooks = {
      {
        callback = function(dir)
          vim.notify("Switched to dir: " .. dir)
        end,
      },
      {
        callback = function(dir)
          vim.notify("Switched to dir: " .. dir)
        end,
        name = "cd hint",
        order = 1,
        pattern = "cd-project.nvim",
        trigger_point = "DISABLE",
        match_rule = function(dir)
          return true
        end,
      },
    },
  },
}
</file>

<file path="lua/plugins/spec/codesnap.lua">
---@type NvPluginSpec
return {
  "mistricky/codesnap.nvim",
  event = "LspAttach",
  init = function()
    local map = vim.keymap.set
    map("x", "<leader>cc", "<cmd>CodeSnap<CR>", { desc = "Save selected code snapshot into clipboard" })
    map("x", "<leader>cs", "<cmd>CodeSnapSave<CR>", { desc = "Save selected code snapshot in ~/Pictures" })
  end,
  opts = {
    save_path = "~/Pictures",
    code_font_family = "JetBrainsMono Nerd Font",
    has_breadcrumbs = true,
    bg_theme = "grape",
    watermark = "",
  },
  build = "make",
}
</file>

<file path="lua/plugins/spec/comment.lua">
---@type NvPluginSpec
return {
  "numToStr/Comment.nvim",
  dependencies = "JoosepAlviste/nvim-ts-context-commentstring",
  init = function()
    local map = vim.keymap.set
    local api = require "Comment.api"

    map("n", "<leader>_", function()
      api.toggle.blockwise.current()
    end, { desc = "Comment toggle (block) in single line" })

    map("n", "<leader>/", function()
      api.toggle.linewise.current()
    end, { desc = "Comment toggle" })

    map(
      "x",
      "<leader>/",
      "<cmd>set operatorfunc=v:lua.__toggle_contextual<CR>g@",
      { desc = "Comment toggle (aware of context)" }
    )
  end,
  ---@param opts CommentConfig
  config = function(_, opts)
    local comment = require "Comment"
    local ts_addon = require "ts_context_commentstring.integrations.comment_nvim"
    opts.pre_hook = ts_addon.create_pre_hook()
    comment.setup(opts)
  end,
}
</file>

<file path="lua/plugins/spec/crates copy.lua">
---@type NvPluginSpec
return {
  "saecki/crates.nvim",
  event = { "BufRead Cargo.toml" },
  tag = "stable",
  opts = function(_, opts)
    local crates = require "crates"

    vim.keymap.set("n", "<leader>cu", function()
      crates.upgrade_all_crates()
    end, { desc = "Update crates" })

    local options = {
      completion = {
        cmp = {
          enabled = true,
        },
      },
    }

    opts = vim.tbl_deep_extend("force", opts or {}, options)
    return opts
  end,
}
</file>

<file path="lua/plugins/spec/crates.lua">
---@type NvPluginSpec
return {
  "saecki/crates.nvim",
  event = { "BufRead Cargo.toml" },
  tag = "stable",
  opts = function(_, opts)
    local crates = require "crates"

    vim.keymap.set("n", "<leader>cu", function()
      crates.upgrade_all_crates()
    end, { desc = "Update crates" })

    local options = {
      completion = {
        cmp = {
          enabled = true,
        },
      },
    }

    opts = vim.tbl_deep_extend("force", opts or {}, options)
    return opts
  end,
}
</file>

<file path="lua/plugins/spec/dappython.lua">
---@type NvPluginSpec
return {
  "mfussenegger/nvim-dap-python",
  ft = "python",
  dependencies = {
    { "mfussenegger/nvim-dap" },
    { "rcarriga/nvim-dap-ui" },
  },
  config = function()
    local dap_py = require "dap-python"
    local path = "~/.local/share/nvim/mason/packages/debugpy/venv/bin/python"

    dap_py.setup(path)

    vim.keymap.set("n", "<leader>pdr", function()
      dap_py.test_method()
    end, { desc = "Run Python debug" })
  end,
}
</file>

<file path="lua/plugins/spec/dapui.lua">
---@type NvPluginSpec
return {
  "rcarriga/nvim-dap-ui",
  event = "LspAttach",
  dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
  opts = {},
  config = function()
    local map = vim.keymap.set
    local dap = require "dap"
    local dapui = require "dapui"
    local widgets = require "dap.ui.widgets"
    local sidebar = widgets.sidebar(widgets.scopes)

    dapui.setup()

    dap.listeners.after.event_initialized["dapui_config"] = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated["dapui_config"] = function()
      dapui.close()
    end
    dap.listeners.before.event_exited["dapui_config"] = function()
      dapui.close()
    end

    map("n", "<leader>db", "<cmd>DapToggleBreakpoint<CR>", { desc = "DAP Toggle breakpoint" })
    map("n", "<leader>dt", function()
      sidebar.toggle()
    end, { desc = "DAP Toggle sidebar" })
  end,
}
</file>

<file path="lua/plugins/spec/dapvirtualtext.lua">
---@type NvPluginSpec
return {
  "theHamsta/nvim-dap-virtual-text",
  event = "LspAttach",
  config = function(_, opts)
    require("nvim-dap-virtual-text").setup()
  end,
}
</file>

<file path="lua/plugins/spec/debug.lua">
-- debug.lua
--
-- Shows how to use the DAP plugin to debug your code.
--
-- Primarily focused on configuring the debugger for Go, but can
-- be extended to other languages as well. That's why it's called
-- kickstart.nvim and not kitchen-sink.nvim ;)

return {
  -- NOTE: Yes, you can install new plugins here!
  "mfussenegger/nvim-dap",
  -- NOTE: And you can specify dependencies as well
  dependencies = {
    -- Creates a beautiful debugger UI
    "rcarriga/nvim-dap-ui",

    -- Required dependency for nvim-dap-ui
    "nvim-neotest/nvim-nio",

    -- Installs the debug adapters for you
    "mason-org/mason.nvim",
    "jay-babu/mason-nvim-dap.nvim",

    -- Add your own debuggers here
    "leoluz/nvim-dap-go",
  },
  keys = {
    -- Basic debugging keymaps, feel free to change to your liking!
    {
      "<F5>",
      function()
        require("dap").continue()
      end,
      desc = "Debug: Start/Continue",
    },
    {
      "<F1>",
      function()
        require("dap").step_into()
      end,
      desc = "Debug: Step Into",
    },
    {
      "<F2>",
      function()
        require("dap").step_over()
      end,
      desc = "Debug: Step Over",
    },
    {
      "<F3>",
      function()
        require("dap").step_out()
      end,
      desc = "Debug: Step Out",
    },
    {
      "<leader>b",
      function()
        require("dap").toggle_breakpoint()
      end,
      desc = "Debug: Toggle Breakpoint",
    },
    {
      "<leader>B",
      function()
        require("dap").set_breakpoint(vim.fn.input "Breakpoint condition: ")
      end,
      desc = "Debug: Set Breakpoint",
    },
    -- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
    {
      "<F7>",
      function()
        require("dapui").toggle()
      end,
      desc = "Debug: See last session result.",
    },
  },
  config = function()
    local dap = require "dap"
    local dapui = require "dapui"

    require("mason-nvim-dap").setup {
      -- Makes a best effort to setup the various debuggers with
      -- reasonable debug configurations
      automatic_installation = true,

      -- You can provide additional configuration to the handlers,
      -- see mason-nvim-dap README for more information
      handlers = {},

      -- You'll need to check that you have the required things installed
      -- online, please don't ask me how to install them :)
      ensure_installed = {
        -- Update this to ensure that you have the debuggers for the langs you want
        "delve",
      },
    }

    -- Dap UI setup
    -- For more information, see |:help nvim-dap-ui|
    dapui.setup {
      -- Set icons to characters that are more likely to work in every terminal.
      --    Feel free to remove or use ones that you like more! :)
      --    Don't feel like these are good choices.
      icons = { expanded = "▾", collapsed = "▸", current_frame = "*" },
      controls = {
        icons = {
          pause = "⏸",
          play = "▶",
          step_into = "⏎",
          step_over = "⏭",
          step_out = "⏮",
          step_back = "b",
          run_last = "▶▶",
          terminate = "⏹",
          disconnect = "⏏",
        },
      },
    }

    -- Change breakpoint icons
    -- vim.api.nvim_set_hl(0, 'DapBreak', { fg = '#e51400' })
    -- vim.api.nvim_set_hl(0, 'DapStop', { fg = '#ffcc00' })
    -- local breakpoint_icons = vim.g.have_nerd_font
    --     and { Breakpoint = '', BreakpointCondition = '', BreakpointRejected = '', LogPoint = '', Stopped = '' }
    --   or { Breakpoint = '●', BreakpointCondition = '⊜', BreakpointRejected = '⊘', LogPoint = '◆', Stopped = '⭔' }
    -- for type, icon in pairs(breakpoint_icons) do
    --   local tp = 'Dap' .. type
    --   local hl = (type == 'Stopped') and 'DapStop' or 'DapBreak'
    --   vim.fn.sign_define(tp, { text = icon, texthl = hl, numhl = hl })
    -- end

    dap.listeners.after.event_initialized["dapui_config"] = dapui.open
    dap.listeners.before.event_terminated["dapui_config"] = dapui.close
    dap.listeners.before.event_exited["dapui_config"] = dapui.close

    -- Install golang specific config
    require("dap-go").setup {
      delve = {
        -- On Windows delve must be run attached or it crashes.
        -- See https://github.com/leoluz/nvim-dap-go/blob/main/README.md#configuring
        detached = vim.fn.has "win32" == 0,
      },
    }
  end,
}
</file>

<file path="lua/plugins/spec/diffview.lua">
---@type NvPluginSpec
return {
  "sindrets/diffview.nvim",
  cmd = { "DiffviewOpen", "DiffviewClose" },
  init = function()
    local map = vim.keymap.set
    map("n", "<leader>dv", "<cmd>DiffviewOpen<CR>", { desc = "Diffview open" })
    map("n", "<leader>dc", "<cmd>DiffviewClose<CR>", { desc = "Diffview close" })
  end,
  config = true,
}
</file>

<file path="lua/plugins/spec/dressing.lua">
---@type NvPluginSpec
return {
  -- enabled = false,
  "stevearc/dressing.nvim",
  event = "UIEnter",
}
</file>

<file path="lua/plugins/spec/dropbar.lua">
---@type NvPluginSpec
return {
  "Bekaboo/dropbar.nvim",
  lazy = false,
  dependencies = {
    "nvim-telescope/telescope-fzf-native.nvim",
  },
}
</file>

<file path="lua/plugins/spec/edgy.lua">
---@type NvPluginSpec
return {
  "folke/edgy.nvim",
  event = "VeryLazy",
  init = function()
    vim.opt.laststatus = 3
    vim.opt.splitkeep = "screen"
  end,
  opts = {
    right = {
      { ft = "codecompanion", title = "Code Companion Chat", size = { width = 0.45 } },
      { ft = "jsplayground", title = "JS Playground", size = { width = 0.45 } },
    },
  },
}
</file>

<file path="lua/plugins/spec/fugitive.lua">
---@type NvPluginSpec
return {
  "tpope/vim-fugitive",
  event = "VeryLazy",
  dependencies = {
    "tpope/vim-rhubarb",
    "tpope/vim-obsession",
    "tpope/vim-unimpaired",
  },
}
</file>

<file path="lua/plugins/spec/gitsigns copy.lua">
---@type NvPluginSpec
return {
  "lewis6991/gitsigns.nvim",
  dependencies = "sindrets/diffview.nvim",
  ---@class Gitsigns.Config
  opts = {
    preview_config = {
      border = "rounded",
    },
    on_attach = function(bufnr)
      local gs = require "gitsigns"
      local map = require("gale.utils").buf_map

      map(bufnr, "n", "<leader>td", gs.toggle_deleted, { desc = "Gitsigns toggle deleted" })
      map(bufnr, "n", "<leader>hr", gs.reset_hunk, { desc = "Gitsigns reset hunk" })
      map(bufnr, "n", "<leader>hs", gs.stage_hunk, { desc = "Gitsigns stage hunk" })
      map(bufnr, "n", "<leader>hu", gs.undo_stage_hunk, { desc = "Gitsigns undo stage hunk" })
      map(bufnr, "n", "<leader>hS", gs.stage_buffer, { desc = "Gitsigns stage buffer" })
      map(bufnr, "n", "<leader>hR", gs.reset_buffer, { desc = "Gitsigns reset buffer" })
      map(bufnr, "n", "<leader>hh", gs.preview_hunk, { desc = "Gitsigns preview hunk" })
      map(bufnr, { "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", { desc = "Gitsigns select hunk" })

      map(bufnr, "n", "<leader>hn", function()
        if vim.wo.diff then
          vim.cmd.normal { "<leader>hn", bang = true }
        else
          gs.nav_hunk "next"
        end
      end, { desc = "Gitsigns next hunk" })

      map(bufnr, "n", "<leader>hb", function()
        if vim.wo.diff then
          vim.cmd.normal { "<leader>hp", bang = true }
        else
          gs.nav_hunk "prev"
        end
      end, { desc = "Gitsigns previous hunk" })

      map(bufnr, "n", "<leader>bl", function()
        gs.blame_line { full = true }
      end, { desc = "Gitsigns blame line" })
    end,
  },
}
</file>

<file path="lua/plugins/spec/gitsigns.lua">
-- Adds git related signs to the gutter, as well as utilities for managing changes
-- NOTE: gitsigns is already included in init.lua but contains only the base
-- config. This will add also the recommended keymaps.

return {
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      on_attach = function(bufnr)
        local gitsigns = require "gitsigns"

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map("n", "]c", function()
          if vim.wo.diff then
            vim.cmd.normal { "]c", bang = true }
          else
            gitsigns.nav_hunk "next"
          end
        end, { desc = "Jump to next git [c]hange" })

        map("n", "[c", function()
          if vim.wo.diff then
            vim.cmd.normal { "[c", bang = true }
          else
            gitsigns.nav_hunk "prev"
          end
        end, { desc = "Jump to previous git [c]hange" })

        -- Actions
        -- visual mode
        map("v", "<leader>hs", function()
          gitsigns.stage_hunk { vim.fn.line ".", vim.fn.line "v" }
        end, { desc = "git [s]tage hunk" })
        map("v", "<leader>hr", function()
          gitsigns.reset_hunk { vim.fn.line ".", vim.fn.line "v" }
        end, { desc = "git [r]eset hunk" })
        -- normal mode
        map("n", "<leader>hs", gitsigns.stage_hunk, { desc = "git [s]tage hunk" })
        map("n", "<leader>hr", gitsigns.reset_hunk, { desc = "git [r]eset hunk" })
        map("n", "<leader>hS", gitsigns.stage_buffer, { desc = "git [S]tage buffer" })
        map("n", "<leader>hu", gitsigns.stage_hunk, { desc = "git [u]ndo stage hunk" })
        map("n", "<leader>hR", gitsigns.reset_buffer, { desc = "git [R]eset buffer" })
        map("n", "<leader>hp", gitsigns.preview_hunk, { desc = "git [p]review hunk" })
        map("n", "<leader>hb", gitsigns.blame_line, { desc = "git [b]lame line" })
        map("n", "<leader>hd", gitsigns.diffthis, { desc = "git [d]iff against index" })
        map("n", "<leader>hD", function()
          gitsigns.diffthis "@"
        end, { desc = "git [D]iff against last commit" })
        -- Toggles
        map("n", "<leader>tb", gitsigns.toggle_current_line_blame, { desc = "[T]oggle git show [b]lame line" })
        map("n", "<leader>tD", gitsigns.preview_hunk_inline, { desc = "[T]oggle git show [D]eleted" })
      end,
    },
  },
}
</file>

<file path="lua/plugins/spec/gleam.lua">
---@type NvPluginSpec
return {
  "gleam-lang/gleam.vim",
  ft = "gleam",
}
</file>

<file path="lua/plugins/spec/gotopreview.lua">
---@type NvPluginSpec
return {
  "rmagatti/goto-preview",
  event = "LspAttach",
  init = function()
    local gtp = require "goto-preview"

    vim.keymap.set("n", "<leader>q", function()
      gtp.dismiss_preview(0)
    end, { desc = "Close current definition preview" })
  end,
  config = function()
    require("goto-preview").setup {
      default_mappings = true,
    }
  end,
}
</file>

<file path="lua/plugins/spec/grugfar.lua">
---@type NvPluginSpec
return {
  "MagicDuck/grug-far.nvim",
  cmd = "GrugFar",
  config = function()
    local map = vim.keymap.set

    require("grug-far").setup {}

    local is_grugfar_open = function()
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        local buf_name = vim.api.nvim_get_option_value("filetype", { buf = buf })
        if buf_name and buf_name == "grug-far" then
          return true
        end
      end
      return false
    end

    local toggle_grugfar = function()
      local open = is_grugfar_open()
      if open then
        require "grug-far/actions/close"()
      else
        vim.cmd "GrugFar"
      end
    end

    map("n", "<leader>gr", function()
      toggle_grugfar()
    end, { desc = "Toggle GrugFar" })
  end,
}
</file>

<file path="lua/plugins/spec/harpoon.lua">
---@type NvPluginSpec
return {
  "ThePrimeagen/harpoon",
  event = "BufEnter",
  branch = "harpoon2",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local utils = require "gale.utils"
    local map = vim.keymap.set
    local harpoon = require "harpoon"

    harpoon:setup {}

    map("n", "<A-q>", function()
      harpoon:list():select(1)
    end, { desc = "Harpoon Go to 1st buffer" })
    map("n", "<A-w>", function()
      harpoon:list():select(2)
    end, { desc = "Harpoon Go to 2nd buffer" })
    map("n", "<A-e>", function()
      harpoon:list():select(3)
    end, { desc = "Harpoon Go to 3rd buffer" })
    map("n", "<A-r>", function()
      harpoon:list():select(4)
    end, { desc = "Harpoon Go to 4th buffer" })
    map("n", "<A-t>", function()
      harpoon:list():select(5)
    end, { desc = "Harpoon Go to 5th buffer" })
    map("n", "<A-y>", function()
      harpoon:list():select(6)
    end, { desc = "Harpoon Go to 6th buffer" })
    map("n", "<A-a>", function()
      harpoon:list():add()
    end, { desc = "Harpoon Add buffer" })
    map("n", "<A-d>", function()
      harpoon:list():remove()
    end, { desc = "Harpoon Remove buffer" })
    map("n", "<A-m>", utils.harpoon_menu, { desc = "Harpoon Open menu" })
    map("n", "<A-,>", function()
      harpoon:list():prev()
    end, { desc = "Harpoon Go to prev buffer" })
    map("n", "<A-.>", function()
      harpoon:list():next()
    end, { desc = "Harpoon Go to next buffer" })

    vim.cmd [[ command! RunHarpoon lua require("gale.utils").harpoon_menu() ]]
  end,
}
</file>

<file path="lua/plugins/spec/helpview.lua">
---@type NvPluginSpec
return {
  "OXY2DEV/helpview.nvim",
  lazy = false,
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
  },
}
</file>

<file path="lua/plugins/spec/hop.lua">
---@type NvPluginSpec
return {
  "smoka7/hop.nvim",
  cmd = { "HopWord", "HopLine", "HopLineStart", "HopWordCurrentLine" },
  init = function()
    local map = vim.keymap.set
    map("n", "<leader><leader>w", "<cmd>HopWord<CR>", { desc = "Hint all words" })
    map("n", "<leader><leader>t", "<cmd>HopNodes<CR>", { desc = "Hint Tree" })
    map("n", "<leader><leader>c", "<cmd>HopLineStart<CR>", { desc = "Hint Columns" })
    map("n", "<leader><leader>l", "<cmd>HopWordCurrentLine<CR>", { desc = "Hint Line" })
  end,
  opts = { keys = "etovxqpdygfblzhckisuran" },
  config = function(_, opts)
    local hop_cache = vim.g.base46_cache .. "hop"
    if vim.uv.fs_stat(hop_cache) then
      dofile(hop_cache)
    end
    require("hop").setup(opts)
  end,
}
</file>

<file path="lua/plugins/spec/indentline.lua">
return {
  { -- Add indentation guides even on blank lines
    "lukas-reineke/indent-blankline.nvim",
    -- Enable `lukas-reineke/indent-blankline.nvim`
    -- See `:help ibl`
    main = "ibl",
    opts = {},
  },
}
</file>

<file path="lua/plugins/spec/linter.lua">
return {

  { -- Linting
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local lint = require "lint"
      lint.linters_by_ft = {
        markdown = { "markdownlint" },
      }

      -- To allow other plugins to add linters to require('lint').linters_by_ft,
      -- instead set linters_by_ft like this:
      -- lint.linters_by_ft = lint.linters_by_ft or {}
      -- lint.linters_by_ft['markdown'] = { 'markdownlint' }
      --
      -- However, note that this will enable a set of default linters,
      -- which will cause errors unless these tools are available:
      -- {
      --   clojure = { "clj-kondo" },
      --   dockerfile = { "hadolint" },
      --   inko = { "inko" },
      --   janet = { "janet" },
      --   json = { "jsonlint" },
      --   markdown = { "vale" },
      --   rst = { "vale" },
      --   ruby = { "ruby" },
      --   terraform = { "tflint" },
      --   text = { "vale" }
      -- }
      --
      -- You can disable the default linters by setting their filetypes to nil:
      -- lint.linters_by_ft['clojure'] = nil
      -- lint.linters_by_ft['dockerfile'] = nil
      -- lint.linters_by_ft['inko'] = nil
      -- lint.linters_by_ft['janet'] = nil
      -- lint.linters_by_ft['json'] = nil
      -- lint.linters_by_ft['markdown'] = nil
      -- lint.linters_by_ft['rst'] = nil
      -- lint.linters_by_ft['ruby'] = nil
      -- lint.linters_by_ft['terraform'] = nil
      -- lint.linters_by_ft['text'] = nil

      -- Create autocommand which carries out the actual linting
      -- on the specified events.
      local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
      vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
        group = lint_augroup,
        callback = function()
          -- Only run the linter in buffers that you can modify in order to
          -- avoid superfluous noise, notably within the handy LSP pop-ups that
          -- describe the hovered symbol using Markdown.
          if vim.bo.modifiable then
            lint.try_lint()
          end
        end,
      })
    end,
  },
}
</file>

<file path="lua/plugins/spec/lspendenhints.lua">
return {
  "chrisgrieser/nvim-lsp-endhints",
  event = "LspAttach",
  opts = {},
}
</file>

<file path="lua/plugins/spec/lspsignature.lua">
---@type NvPluginSpec
return {
  enabled = false,
  "ray-x/lsp_signature.nvim",
  event = "LspAttach",
  config = function()
    require("lsp_signature").setup()
  end,
}
</file>

<file path="lua/plugins/spec/markview.lua">
---@type NvPluginSpec
return {
  "OXY2DEV/markview.nvim",
  lazy = false,
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },
  opts = function(_, opts)
    local presets = require "markview.presets"

    ---@type markview.configuration
    ---@diagnostic disable-next-line
    local new_opts = {
      preview = {
        modes = { "i", "n", "v", "vs", "V", "Vs", "no", "c" },
        hybrid_modes = { "i" },
        ---@diagnostic disable-next-line
        callbacks = {
          on_enable = function(_, win)
            -- https://github.com/OXY2DEV/markview.nvim/issues/75
            -- vim.wo[win].wrap = false

            -- https://segmentfault.com/q/1010000000532491
            vim.wo[win].conceallevel = 2
            vim.wo[win].concealcursor = "nivc"
          end,
        },
      },
      markdown = {
        headings = presets.headings.arrowed,
        tables = {
          use_virt_lines = true,
        },
      },
      highlight_groups = "dynamic",
      checkboxes = presets.checkboxes.nerd,
      ---@diagnostic disable-next-line
      markdown_inline = {
        enable = true,
        ---@diagnostic disable-next-line
        tags = {
          enable = true,
          default = {
            conceal = true,
            ---@type string?
            hl = nil,
          },
        },
        entities = {
          enable = true,
          hl = nil,
        },
      },
    }

    opts = vim.tbl_deep_extend("force", new_opts, opts or {})
    return opts
  end,
}
</file>

<file path="lua/plugins/spec/matchup.lua">
---@type NvPluginSpec
return {
  "andymass/vim-matchup",
  event = "LspAttach",
  config = function()
    vim.g.matchup_matchparen_offscreen = { method = "popup" }
  end,
}
</file>

<file path="lua/plugins/spec/mdpreview.lua">
---@type NvPluginSpec
return {
  "iamcco/markdown-preview.nvim",
  ft = { "markdown" },
  cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
  build = function()
    require("lazy").load { plugins = { "markdown-preview.nvim" } }
    vim.fn["mkdp#util#install"]()
  end,
  init = function()
    vim.keymap.set("n", "<leader>mp", "<cmd>MarkdownPreviewToggle<CR>", { desc = "Toggle Markdown Preview" })
  end,
}
</file>

<file path="lua/plugins/spec/multicursor.lua">
return {
  "jake-stewart/multicursor.nvim",
  enabled = false,
  branch = "1.0",
  config = function(_, opts)
    local mc = require "multicursor-nvim"
    mc.setup(opts)

    local map = require("gale.utils").glb_map

    map({ "n", "v" }, "<up>", function()
      mc.lineAddCursor(-1)
    end, { desc = "Multicursor add cursor above main cursor." })

    map({ "n", "v" }, "<down>", function()
      mc.lineAddCursor(1)
    end, { desc = "Multicursor add cursor below main cursor." })

    map({ "n", "v" }, "<leader><up>", function()
      mc.lineSkipCursor(-1)
    end, { desc = "Multicursor skip cursor above main cursor." })

    map({ "n", "v" }, "<leader><down>", function()
      mc.lineSkipCursor(1)
    end, { desc = "Multicursor skip cursor below main cursor." })

    map({ "n", "v" }, "<leader>n", function()
      mc.matchAddCursor(1)
    end, { desc = "Multicursor add cursor below main cursor by matching word/selection." })

    map({ "n", "v" }, "<leader>s", function()
      mc.matchSkipCursor(1)
    end, { desc = "Multicursor skip cursor below main cursor by matching word/selection." })

    map({ "n", "v" }, "<leader>N", function()
      mc.matchAddCursor(-1)
    end, { desc = "Multicursor add cursor above main cursor by matching word/selection." })

    map({ "n", "v" }, "<leader>S", function()
      mc.matchSkipCursor(-1)
    end, { desc = "Multicursor skip cursor above main cursor by matching word/selection." })

    -- You can also add cursors with any motion you prefer:
    -- set("n", "<right>", function()
    --     mc.addCursor("w")
    -- end)
    -- set("n", "<leader><right>", function()
    --     mc.skipCursor("w")
    -- end)

    map({ "n", "v" }, "<leader>A", mc.matchAllAddCursors, { desc = "Multicursor add all matches in document." })
    map({ "n", "v" }, "<left>", mc.nextCursor, { desc = "Multicursor rotate the main cursor to the left." })
    map({ "n", "v" }, "<right>", mc.prevCursor, { desc = "Multicursor rotate the main cursor to the right." })
    map({ "n", "v" }, "<leader>x", mc.deleteCursor, { desc = "Multicursor delete main cursor." })
    map("n", "<c-leftmouse>", mc.handleMouse, { desc = "Multicursor add/remove cursors with mouse." })
    -- Easy way to add and remove cursors using the main cursor.
    map({ "n", "v" }, "<c-q>", mc.toggleCursor, { desc = "Multicursor toggle cursors." })
    map({ "n", "v" }, "<leader><c-q>", mc.duplicateCursors, { desc = "Multicursor duplicate cursors." })

    map("n", "<esc>", function()
      if not mc.cursorsEnabled() then
        mc.enableCursors()
      elseif mc.hasCursors() then
        mc.clearCursors()
      else
        -- Default <esc> handler.
      end
    end)

    map("v", "<leader>a", mc.alignCursors, { desc = "Multicursor align cursor columns." })
    map("v", "S", mc.splitCursors, { desc = "Multicursor split visual selections by regex." })
    map("v", "I", mc.insertVisual, { desc = "Multicursor insert for each line of visual selections." })
    map("v", "A", mc.appendVisual, { desc = "Multicursor append for each line of visual selections." })
    map("v", "M", mc.matchCursors, { desc = "Multicursor match new cursors within visual selections by regex." })

    map("v", "<leader>t", function()
      mc.transposeCursors(1)
    end, { desc = "Multicursor rotate visual selection contents to the right." })

    map("v", "<leader>T", function()
      mc.transposeCursors(-1)
    end, { desc = "Multicursor rotate visual selection contents to the left." })

    local hl = vim.api.nvim_set_hl
    hl(0, "MultiCursorCursor", { link = "Cursor" })
    hl(0, "MultiCursorVisual", { link = "Visual" })
    hl(0, "MultiCursorSign", { link = "SignColumn" })
    hl(0, "MultiCursorDisabledCursor", { link = "Visual" })
    hl(0, "MultiCursorDisabledVisual", { link = "Visual" })
    hl(0, "MultiCursorDisabledSign", { link = "SignColumn" })
  end,
}
</file>

<file path="lua/plugins/spec/mylorem.lua">
return {
  "elvxk/mylorem.nvim",
  lazy = false,
  config = function()
    require("mylorem").setup {
      luasnip = true,
      ultisnips = false,
      vsnip = false,
      default = true,
    }
  end,
}
</file>

<file path="lua/plugins/spec/neogit.lua">
---@type NvPluginSpec
return {
  "NeogitOrg/neogit",
  event = "VeryLazy",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "sindrets/diffview.nvim",
    "nvim-telescope/telescope.nvim",
  },
  init = function()
    local map = vim.keymap.set
    map("n", "<leader>gg", "<cmd>Neogit<CR>", { desc = "Neogit Open" })
  end,
  config = function(_, opts)
    require("neogit").setup(opts)

    local augroup = vim.api.nvim_create_augroup
    local autocmd = vim.api.nvim_create_autocmd
    autocmd("BufEnter", {
      desc = "Disable statuscol in Neogit* buffers.",
      pattern = "NeogitStatus",
      group = augroup("DisableStatuscol", { clear = true }),
      callback = function()
        vim.schedule(function()
          vim.o.statuscolumn = "%!v:lua.require('statuscol').get_statuscol_string()"
        end)
      end,
    })
  end,
}
</file>

<file path="lua/plugins/spec/noice.lua">
return {
  "folke/noice.nvim",
  event = "VeryLazy",
  dependencies = { "MunifTanjim/nui.nvim" },
  ---@module "noice"
  opts = {
    cmdline = {
      enabled = false,
    },
    messages = {
      enabled = false,
    },
    popupmenu = {
      enabled = false,
    },
    notify = {
      enabled = false,
    },
    lsp = {
      override = {
        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
        ["vim.lsp.util.stylize_markdown"] = true,
        ["cmp.entry.get_documentation"] = true,
      },
      hover = {
        enabled = true,
        ---@type NoiceViewOptions
        opts = {
          size = {
            max_width = vim.api.nvim_win_get_width(0) - 6,
          },
        },
      },
      signature = {
        enabled = true,
        ---@type NoiceViewOptions
        opts = {
          size = {
            max_width = vim.api.nvim_win_get_width(0) - 6,
          },
        },
      },
      progress = {
        enabled = false,
      },
      message = {
        enabled = false,
      },
    },
    presets = {
      lsp_doc_border = true,
    },
  },
}
</file>

<file path="lua/plugins/spec/obsidian.lua">
---@type NvPluginSpec
return {
  "epwalsh/obsidian.nvim",
  version = "*",
  event = {
    "BufReadPre " .. vim.fn.expand "~" .. "/notes/**.md",
    "BufNewFile " .. vim.fn.expand "~" .. "/notes/**.md",
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "hrsh7th/nvim-cmp",
    "nvim-telescope/telescope.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  opts = {
    workspaces = {
      {
        name = "learning",
        path = "~/notes/learning",
      },
      {
        name = "personal",
        path = "~/notes/personal",
      },
      {
        name = "work",
        path = "~/notes/work",
      },
    },
  },
}
</file>

<file path="lua/plugins/spec/oil.lua">
---@type NvPluginSpec
return {
  "stevearc/oil.nvim",
  event = "VeryLazy",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = function(_, opts)
    local autocmd = vim.api.nvim_create_autocmd
    local augroup = vim.api.nvim_create_augroup
    local oil = require "oil"
    local util = require "oil.util"
    local utils = require "gale.utils"
    local map = utils.glb_map
    local buf_map = utils.buf_map

    _G.oil_details_expanded = false
    _G.get_oil_winbar = function()
      local dir = oil.get_current_dir()
      if dir then
        return "%#OilWinbar#" .. vim.fn.fnamemodify(dir, ":~")
      else
        return "%#OilWinbar#" .. vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf())
      end
    end

    -- Workaround to issue with oil-vcs-status when toggling too quickly
    local debounced_close = utils.debounce(function()
      vim.g.oil_is_open = false
      oil.close()
    end, 100)

    _G.oil_is_open = false
    local toggle_oil = function()
      if util.is_oil_bufnr(vim.api.nvim_get_current_buf()) and vim.g.oil_is_open then
        debounced_close()
      else
        vim.g.oil_is_open = true
        oil.open()
      end
    end

    -- helper function to parse output
    local function parse_output(proc)
      local result = proc:wait()
      local ret = {}
      if result.code == 0 then
        for line in vim.gsplit(result.stdout, "\n", { plain = true, trimempty = true }) do
          -- Remove trailing slash
          line = line:gsub("/$", "")
          ret[line] = true
        end
      end
      return ret
    end

    -- build git status cache
    local function new_git_status()
      return setmetatable({}, {
        __index = function(self, key)
          local ignore_proc = vim.system(
            { "git", "ls-files", "--ignored", "--exclude-standard", "--others", "--directory" },
            {
              cwd = key,
              text = true,
            }
          )
          local tracked_proc = vim.system({ "git", "ls-tree", "HEAD", "--name-only" }, {
            cwd = key,
            text = true,
          })
          local ret = {
            ignored = parse_output(ignore_proc),
            tracked = parse_output(tracked_proc),
          }

          rawset(self, key, ret)
          return ret
        end,
      })
    end

    local git_status = new_git_status()

    -- Clear git status cache on refresh
    local refresh = require("oil.actions").refresh
    local orig_refresh = refresh.callback
    refresh.callback = function(...)
      git_status = new_git_status()
      orig_refresh(...)
    end

    autocmd("FileType", {
      desc = "Disable Oil toggler in telescope buffers.",
      pattern = "Telescope*",
      group = augroup("OilTelescope", { clear = true }),
      callback = function(event)
        buf_map(event.buf, "n", "<leader>e", "<nop>")
        buf_map(event.buf, "n", "<C-e>", "<nop>")
      end,
    })

    ---@type oil.SetupOpts
    local new_opts = {
      default_file_explorer = true,
      delete_to_trash = true,
      watch_for_changes = true,
      cleanup_delay_ms = 0,
      win_options = {
        winbar = "%!v:lua.get_oil_winbar()",
        signcolumn = "yes:1",
      },
      view_options = {
        is_hidden_file = function(name, bufnr)
          local dir = oil.get_current_dir(bufnr)
          local is_dotfile = vim.startswith(name, ".") and name ~= ".."
          -- if no local directory (e.g. for ssh connections), just hide dotfiles
          if not dir then
            return is_dotfile
          end
          -- dotfiles are considered hidden unless tracked
          if is_dotfile then
            return not git_status[dir].tracked[name]
          else
            -- Check if file is gitignored
            return git_status[dir].ignored[name]
          end
        end,
      },
      keymaps = {
        ["g?"] = "actions.show_help",
        ["<CR>"] = "actions.select",
        ["<Tab>"] = "actions.select",
        ["<C-s>"] = false,
        ["<C-v>"] = { "actions.select", opts = { vertical = true }, desc = "Open the entry in a vertical split" },
        ["<C-h>"] = { "actions.select", opts = { horizontal = true }, desc = "Open the entry in a horizontal split" },
        ["<C-t>"] = { "actions.select", opts = { tab = true }, desc = "Open the entry in new tab" },
        ["<C-p>"] = "actions.preview",
        ["<C-l>"] = "actions.refresh",
        ["<C-c>"] = false,
        ["q"] = "actions.close",
        ["-"] = "actions.parent",
        ["<S-Tab>"] = "actions.parent",
        ["_"] = "actions.open_cwd",
        ["`"] = "actions.cd",
        ["~"] = { "actions.cd", opts = { scope = "tab" }, desc = ":tcd to the current oil directory" },
        ["gs"] = "actions.change_sort",
        ["gx"] = "actions.open_external",
        ["I"] = "actions.toggle_hidden",
        ["g\\"] = "actions.toggle_trash",
        ["<leader>de"] = {
          callback = function()
            vim.g.oil_details_expanded = not vim.g.oil_details_expanded
            if vim.g.oil_details_expanded then
              oil.set_columns { "icon", "permissions", "size", "mtime" }
            else
              oil.set_columns { "icon" }
            end
          end,
          desc = "Toggle file detail view",
        },
      },
    }

    map("n", "<leader>e", function()
      toggle_oil()
    end, { desc = "Open Oil file explorer" })

    -- Alternative mapping for those who prefer Ctrl
    map("n", "<C-e>", function()
      toggle_oil()
    end, { desc = "Open Oil file explorer" })

    opts = vim.tbl_deep_extend("force", opts, new_opts)
    return opts
  end,
}
</file>

<file path="lua/plugins/spec/oilvcsstatus.lua">
return {
  "SirZenith/oil-vcs-status",
  event = "VeryLazy",
  dependencies = { "stevearc/oil.nvim" },
  config = true,
  opts = function(_, opts)
    local status_const = require "oil-vcs-status.constant.status"
    local StatusType = status_const.StatusType

    local new_opts = {
      status_symbol = {
        [StatusType.Added] = "",
        [StatusType.Copied] = "",
        [StatusType.Deleted] = "",
        [StatusType.Ignored] = "",
        [StatusType.Modified] = "",
        [StatusType.Renamed] = "",
        [StatusType.TypeChanged] = "",
        [StatusType.Unmodified] = " ",
        [StatusType.Unmerged] = "",
        [StatusType.Untracked] = "",
        [StatusType.External] = "",

        [StatusType.UpstreamAdded] = "",
        [StatusType.UpstreamCopied] = "",
        [StatusType.UpstreamDeleted] = "",
        [StatusType.UpstreamIgnored] = " ",
        [StatusType.UpstreamModified] = "",
        [StatusType.UpstreamRenamed] = "",
        [StatusType.UpstreamTypeChanged] = "",
        [StatusType.UpstreamUnmodified] = " ",
        [StatusType.UpstreamUnmerged] = "",
        [StatusType.UpstreamUntracked] = " ",
        [StatusType.UpstreamExternal] = "",
      },
      status_hl_group = {
        [StatusType.Added] = "DiffviewStatusAdded",
        [StatusType.Copied] = "DiffviewNormal",
        [StatusType.Deleted] = "DiffviewStatusDeleted",
        [StatusType.Ignored] = "DiffviewNonText",
        [StatusType.Modified] = "Normal",
        [StatusType.Renamed] = "DiffviewFolderSign",
        [StatusType.TypeChanged] = "DiffModified",
        [StatusType.Unmodified] = "Normal",
        [StatusType.Unmerged] = "diffOldFile",
        [StatusType.Untracked] = "DiffviewFolderSign",
        [StatusType.External] = "diffOldFile",

        [StatusType.UpstreamAdded] = "DiffAdd",
        [StatusType.UpstreamCopied] = "DiffAdd",
        [StatusType.UpstreamDeleted] = "DiffAdd",
        [StatusType.UpstreamIgnored] = "DiffAdd",
        [StatusType.UpstreamModified] = "DiffAdd",
        [StatusType.UpstreamRenamed] = "DiffAdd",
        [StatusType.UpstreamTypeChanged] = "DiffAdd",
        [StatusType.UpstreamUnmodified] = "DiffAdd",
        [StatusType.UpstreamUnmerged] = "DiffAdd",
        [StatusType.UpstreamUntracked] = "DiffAdd",
        [StatusType.UpstreamExternal] = "DiffAdd",
      },
    }

    opts = vim.tbl_deep_extend("force", opts, new_opts)
    return opts
  end,
}
</file>

<file path="lua/plugins/spec/oneliners.lua">
return {
  { -- This helps with php/html for indentation
    "captbaritone/better-indent-support-for-php-with-html",
  },
  { -- This helps with ssh tunneling and copying to clipboard
    "ojroques/vim-oscyank",
  },
  { -- This generates docblocks
    "kkoomen/vim-doge",
    build = ":call doge#install()",
  },
  { -- Git plugin
    "tpope/vim-fugitive",
  },
  { -- Show historical versions of the file locally
    "mbbill/undotree",
  },
  { -- Show CSS Colors
    "brenoprata10/nvim-highlight-colors",
    config = function()
      require("nvim-highlight-colors").setup {}
    end,
  },
}
</file>

<file path="lua/plugins/spec/outline.lua">
---@type NvPluginSpec
return {
  "hedyhli/outline.nvim",
  cmd = "Outline",
  init = function()
    vim.keymap.set("n", "<leader>oo", "<cmd>Outline<CR>", { desc = "Toggle Outline" })
  end,
  config = function()
    require("outline").setup {}
  end,
}
</file>

<file path="lua/plugins/spec/precognition.lua">
---@type NvPluginSpec
return {
  "tris203/precognition.nvim",
  event = "VeryLazy",
  init = function()
    vim.keymap.set("n", "<leader>pc", "<cmd>Precognition toggle<CR>", { desc = "Precognition toggle" })
  end,
  opts = {
    startVisible = false,
    showBlankVirtLine = false,
    highlightColor = { link = "@variable.parameter" },
    hints = {
      Caret = { text = "^", prio = 2 },
      Dollar = { text = "$", prio = 1 },
      MatchingPair = { text = "%", prio = 5 },
      Zero = { text = "0", prio = 1 },
      w = { text = "w", prio = 10 },
      b = { text = "b", prio = 9 },
      e = { text = "e", prio = 8 },
      W = { text = "W", prio = 7 },
      B = { text = "B", prio = 6 },
      E = { text = "E", prio = 5 },
    },
    gutterHints = {
      G = { text = "G", prio = 10 },
      gg = { text = "gg", prio = 9 },
      PrevParagraph = { text = "{", prio = 8 },
      NextParagraph = { text = "}", prio = 8 },
    },
  },
  config = function(_, opts)
    require("precognition").setup(opts)
  end,
}
</file>

<file path="lua/plugins/spec/rainbowdelimiters.lua">
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
</file>

<file path="lua/plugins/spec/regexplainer.lua">
---@type NvPluginSpec
return {
  "bennypowers/nvim-regexplainer",
  event = "BufEnter",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "MunifTanjim/nui.nvim",
  },
  config = function()
    require("regexplainer").setup()
  end,
}
</file>

<file path="lua/plugins/spec/rustaceanvim.lua">
---@type NvPluginSpec
return {
  "mrcjkb/rustaceanvim",
  lazy = false,
  version = "^5",
  config = function()
    vim.g.rustaceanvim = {
      -- Plugin configuration
      tools = {
        float_win_config = {
          border = "rounded",
        },
      },
      -- LSP configuration
      server = {
        capabilities = require("nvchad.configs.lspconfig").capabilities,
        on_attach = function(_, bufnr)
          local map = vim.keymap.set
          map("n", "K", "<cmd>lua vim.cmd.RustLsp({ 'hover', 'actions' })<CR>", { buffer = bufnr, desc = "Rust Hover" })
          map(
            "n",
            "<C-Space>",
            "<cmd>lua vim.cmd.RustLsp({ 'completion' })<CR>",
            { buffer = bufnr, desc = "Rust Completion" }
          )
          map(
            "n",
            "<leader>ca",
            "<cmd>lua vim.cmd.RustLsp('codeAction')<CR>",
            { buffer = bufnr, desc = "Rust Code actions" }
          )
        end,
        default_settings = {
          -- rust-analyzer language server configuration
          ["rust-analyzer"] = {
            -- Performance and reliability settings
            cargo = {
              loadOutDirsFromCheck = true,
              runBuildScripts = true,
              allFeatures = true,
            },
            -- Enhanced diagnostics
            check = {
              command = "clippy",
              extraArgs = { "--all", "--", "-W", "clippy::all" },
            },
            -- Completion and inlay hints
            completion = {
              postfix = {
                enable = false, -- Disable postfix completions as they can be distracting
              },
            },
            inlayHints = {
              bindingModeHints = {
                enable = false,
              },
              chainingHints = {
                enable = true,
              },
              closingBraceHints = {
                enable = true,
                minLines = 25,
              },
              closureReturnTypeHints = {
                enable = "never",
              },
              lifetimeElisionHints = {
                enable = "never",
                useParameterNames = false,
              },
              maxLength = 25,
              parameterHints = {
                enable = true,
              },
              reborrowHints = {
                enable = "never",
              },
              renderColons = true,
              typeHints = {
                enable = true,
                hideClosureInitialization = false,
                hideNamedConstructor = false,
              },
            },
            -- Import and workspace management
            imports = {
              granularity = {
                group = "module",
              },
              prefix = "self",
            },
            -- Lens settings
            lens = {
              enable = true,
            },
            -- Proc macro support
            procMacro = {
              enable = true,
              ignored = {
                ["async-trait"] = { "async_trait" },
                ["napi-derive"] = { "napi" },
                ["async-recursion"] = { "async_recursion" },
              },
            },
            -- Workspace and project settings
            rustfmt = {
              extraArgs = {},
              overrideCommand = nil,
              rangeFormatting = {
                enable = false,
              },
            },
          },
        },
      },
      -- DAP configuration
      dap = {},
    }
  end,
}
</file>

<file path="lua/plugins/spec/screenkey.lua">
---@type NvPluginSpec
return {
  "NStefan002/screenkey.nvim",
  cmd = "Screenkey",
  version = "*",
  config = true,
}
</file>

<file path="lua/plugins/spec/scrolleof.lua">
---@type NvPluginSpec
return {
  "Aasim-A/scrollEOF.nvim",
  event = { "CursorMoved", "WinScrolled" },
  opts = {},
  config = function()
    require("scrollEOF").setup()
  end,
}
</file>

<file path="lua/plugins/spec/showkeys.lua">
return {
  "nvchad/showkeys",
  cmd = { "ShowkeysToggle" },
  opts = {
    show_count = true,
  },
}
</file>

<file path="lua/plugins/spec/statuscol.lua">
return {
  "luukvbaal/statuscol.nvim",
  lazy = false,
  config = function()
    local builtin = require "statuscol.builtin"

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "*",
      group = vim.api.nvim_create_augroup("SmarterFoldColumn", { clear = true }),
      callback = function(event)
        if vim.bo[event.buf].buftype == "help" then
          vim.opt_local.foldcolumn = "0"
        end
      end,
    })

    require("statuscol").setup {
      bt_ignore = { "terminal", "help", "nofile" },
      ft_ignore = { "oil" },
      relculright = true,
      segments = {
        { text = { "%s" }, foldclosed = true, click = "v:lua.ScSa" },
        {
          text = { builtin.foldfunc, "  " },
          condition = { builtin.not_empty, true, builtin.not_empty },
          foldclosed = true,
          click = "v:lua.ScFa",
        },
        { text = { builtin.lnumfunc, " " }, foldclosed = true, click = "v:lua.ScLa" },
      },
    }
  end,
}
</file>

<file path="lua/plugins/spec/supermaven.lua">
return {
  "supermaven-inc/supermaven-nvim",
  event = "LspAttach",
  opts = {
    keymaps = {
      accept_suggestion = "<Tab>",
      clear_suggestion = "<C-x>",
      accept_word = "<C-y>",
    },
    disable_keymaps = false,
    log_level = "warn",
    dsable_inline_completion = false,
  },
}
</file>

<file path="lua/plugins/spec/telescope.lua">
return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  config = function()
    local actions = require "telescope.actions"
    require("telescope").setup {
      defaults = {
        mappings = {
          i = {
            ["<C-k>"] = actions.move_selection_previous, -- move to prev result
            ["<C-j>"] = actions.move_selection_next, -- move to next result
            ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist, -- send selected to quickfixlist
          },
        },
      },
    }

    local builtin = require "telescope.builtin"
    vim.keymap.set("n", "<leader>ff", builtin.find_files, {})
    vim.keymap.set("n", "<leader>fo", builtin.oldfiles, {})
    vim.keymap.set("n", "<leader>fq", builtin.quickfix, {})
    vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Telescope help tags" })
    vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope buffers" })

    -- Rip grep + Fzf
    vim.keymap.set("n", "<leader>fg", function()
      builtin.grep_string { search = vim.fn.input "Grep > " }
    end)

    -- Find instance instance of current view being included
    vim.keymap.set("n", "<leader>fc", function()
      local filename_without_extension = vim.fn.expand "%:t:r"
      builtin.grep_string { search = filename_without_extension }
    end, { desc = "Find current file: " })

    -- Grep current string (for when gd doesn't work)
    vim.keymap.set("n", "<leader>fs", function()
      builtin.grep_string {}
    end, { desc = "Find current string: " })

    -- find files in vim config
    vim.keymap.set("n", "<leader>fi", function()
      builtin.find_files { cwd = "~/.config/nvim/" }
    end)
  end,
}
</file>

<file path="lua/plugins/spec/tinycodeaction.lua">
return {
  "rachartier/tiny-code-action.nvim",
  event = "LspAttach",
  dependencies = {
    { "nvim-lua/plenary.nvim" },
    { "nvim-telescope/telescope.nvim" },
  },
  config = function()
    local map = require("gale.utils").glb_map

    map({ "n", "v" }, "<leader>ca", function()
      require("tiny-code-action").code_action()
    end, { desc = "Tiny code action" })

    require("tiny-code-action").setup()
  end,
}
</file>

<file path="lua/plugins/spec/tinyinlinediagnostic.lua">
---@type NvPluginSpec
return {
  "rachartier/tiny-inline-diagnostic.nvim",
  event = "VeryLazy",
  config = function()
    require("tiny-inline-diagnostic").setup()
  end,
}
</file>

<file path="lua/plugins/spec/todocomments.lua">
---@type NvPluginSpec
return {
  "folke/todo-comments.nvim",
  dependencies = "nvim-lua/plenary.nvim",
  event = "VeryLazy",
  config = function()
    require("todo-comments").setup {
      keywords = {
        GROUP = { icon = " ", color = "hint" },
        HERE = { icon = " ", color = "here" },
      },
      colors = { here = "#fdf5a4" },
      highlight = { multiline = true },
    }
  end,
}
</file>

<file path="lua/plugins/spec/treesitter.lua">
return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
    config = function()
      local configs = require "nvim-treesitter.configs"
      ---@diagnostic disable-next-line: missing-fields
      configs.setup {
        textobjects = {
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              ["af"] = "@function.outer",
              ["if"] = "@function.inner",
            },
          },
        },
        -- enable syntax highlighting
        highlight = {
          enable = true,
        },
        -- enable indentation
        indent = { enable = true },
        -- enable autotagging (w/ nvim-ts-autotag plugin)
        autotag = { enable = true },
        -- ensure these language parsers are installed
        ensure_installed = {
          "json",
          "python",
          "javascript",
          "query",
          "typescript",
          "tsx",
          "php",
          "yaml",
          "html",
          "css",
          "markdown",
          "markdown_inline",
          "bash",
          "lua",
          "vim",
          "vimdoc",
          "c",
          "dockerfile",
          "helm",
          "just",
          "gitignore",
          "gitattributes",
          "git_config",
          "astro",
          "go",
          "gomod",
          "gosum",
          "gotmpl",
          "gowork",
          "rust",
          "terraform",
          "hcl",
          "xml",
          "zig",
        },
        -- auto install above language parsers
        auto_install = false,
      }
    end,
  },
}
</file>

<file path="lua/plugins/spec/treesittertextobjects.lua">
---@type NvPluginSpec
return {
  "nvim-treesitter/nvim-treesitter-textobjects",
}
</file>

<file path="lua/plugins/spec/trouble.lua">
---@type NvPluginSpec
return {
  "folke/trouble.nvim",
  opts = {},
  cmd = "Trouble",
  keys = {
    {
      "<leader>tt",
      "<cmd>Trouble diagnostics toggle<cr>",
      desc = "Diagnostics (Trouble)",
    },
    {
      "<leader>tb",
      "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
      desc = "Buffer Diagnostics (Trouble)",
    },
    {
      "<leader>to",
      "<cmd>Trouble symbols toggle focus=false<cr>",
      desc = "Symbols (Trouble)",
    },
    {
      "<leader>tL",
      "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
      desc = "LSP Definitions / references / ... (Trouble)",
    },
    {
      "<leader>tl",
      "<cmd>Trouble loclist toggle<cr>",
      desc = "Location List (Trouble)",
    },
    {
      "<leader>tq",
      "<cmd>Trouble qflist toggle<cr>",
      desc = "Quickfix List (Trouble)",
    },
  },
}
</file>

<file path="lua/plugins/spec/tsautotag.lua">
local status_ok, auto_tag = pcall(require, "nvim-treesitter.configs")
if not status_ok then
  return
end

---@type NvPluginSpec
return {
  "windwp/nvim-ts-autotag",
  -- https://github.com/windwp/nvim-ts-autotag?tab=readme-ov-file#a-note-on-lazy-loading
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    ---@diagnostic disable-next-line
    auto_tag.setup {
      autotag = {
        enable = true,
      },
    }
  end,
}
</file>

<file path="lua/plugins/spec/tscontextcommentstring.lua">
---@diagnostic disable: miss-field

---@type NvPluginSpec
return {
  "JoosepAlviste/nvim-ts-context-commentstring",
  ft = {
    "astro",
    "html",
    "javascript",
    "typescript",
    "javascriptreact",
    "typescriptreact",
    "svelte",
    "vue",
    "tsx",
    "jsx",
    "rescript",
    "xml",
    "php",
    "markdown",
    "glimmer",
    "handlebars",
    "hbs",
  },
  config = function()
    ---@diagnostic disable-next-line
    require("ts_context_commentstring").setup {
      enable_autocmd = false,
    }
  end,
}
</file>

<file path="lua/plugins/spec/undotree.lua">
---@type NvPluginSpec
return {
  "mbbill/undotree",
  cmd = "UndotreeToggle",
  init = function()
    vim.keymap.set("n", "<leader>ut", "<cmd>UndotreeToggle<CR>", { desc = "UndoTree toggler" })
  end,
}
</file>

<file path="lua/plugins/spec/vimastro.lua">
---@type NvPluginSpec
return {
  "wuelnerdotexe/vim-astro",
  ft = "astro",
  config = function()
    vim.g.astro_typescript = "enable"
  end,
}
</file>

<file path="lua/plugins/spec/vimilluminate.lua">
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
</file>

<file path="lua/plugins/spec/vimvisualmulti.lua">
return {
  "mg979/vim-visual-multi",
  cmd = {
    "VMap",
    "VNew",
    "VNewShell",
    "VS",
    "VSCode",
    "VSDebug",
    "VSDebugger",
    "VSTerminal",
    "VSTerminalOpen",
    "VSTerminalSend",
    "VSTerminalSendRaw",
    "VSTerminalToggle",
    "VSTerminalToggleSplit",
    "VSTerminalVSCode",
    "VSTerminalWindows",
    "VToggle",
    "VToggleLine",
    "VToggleRange",
    "VW",
    "VWSplit",
  },
}
</file>

<file path="lua/plugins/spec/zen-mode.lua">
---@type NvPluginSpec
return {
  "folke/zen-mode.nvim",
  dependencies = { "folke/twilight.nvim" },
  cmd = "ZenMode",
}
</file>

<file path="lua/plugins/init.lua">
return {
  { import = "plugins.local.binarypeek" },
  { import = "plugins.local.popurri" },
  { import = "plugins.spec.autopairs" },
  { import = "plugins.spec.better-escape" },
  { import = "plugins.spec.ccc" },
  { import = "plugins.spec.cdproject" },
  { import = "plugins.spec.codesnap" },
  { import = "plugins.spec.comment" },
  { import = "plugins.spec.crates" },
  { import = "plugins.spec.dappython" },
  { import = "plugins.spec.dapui" },
  { import = "plugins.spec.dapvirtualtext" },
  { import = "plugins.spec.debug" },
  { import = "plugins.spec.diffview" },
  { import = "plugins.spec.dressing" },
  { import = "plugins.spec.dropbar" },
  { import = "plugins.spec.edgy" },
  { import = "plugins.spec.fugitive" },
  { import = "plugins.spec.gitsigns" },
  { import = "plugins.spec.gleam" },
  { import = "plugins.spec.gotopreview" },
  { import = "plugins.spec.grugfar" },
  { import = "plugins.spec.harpoon" },
  { import = "plugins.spec.helpview" },
  { import = "plugins.spec.hop" },
  { import = "plugins.spec.indentline" },
  { import = "plugins.spec.linter" },
  { import = "plugins.spec.lspendenhints" },
  { import = "plugins.spec.lspsignature" },
  { import = "plugins.spec.markview" },
  { import = "plugins.spec.matchup" },
  { import = "plugins.spec.mdpreview" },
  { import = "plugins.spec.multicursor" },
  { import = "plugins.spec.mylorem" },
  { import = "plugins.spec.neogit" },
  { import = "plugins.spec.noice" },
  { import = "plugins.spec.obsidian" },
  { import = "plugins.spec.oil" },
  { import = "plugins.spec.oilvcsstatus" },
  { import = "plugins.spec.oneliners" },
  { import = "plugins.spec.outline" },
  { import = "plugins.spec.precognition" },
  { import = "plugins.spec.rainbowdelimiters" },
  { import = "plugins.spec.regexplainer" },
  { import = "plugins.spec.rustaceanvim" },
  { import = "plugins.spec.screenkey" },
  { import = "plugins.spec.scrolleof" },
  { import = "plugins.spec.showkeys" },
  { import = "plugins.spec.statuscol" },
  { import = "plugins.spec.supermaven" },
  { import = "plugins.spec.telescope" },
  { import = "plugins.spec.tinycodeaction" },
  { import = "plugins.spec.tinyinlinediagnostic" },
  { import = "plugins.spec.todocomments" },
  { import = "plugins.spec.treesitter" },
  { import = "plugins.spec.treesittertextobjects" },
  { import = "plugins.spec.trouble" },
  { import = "plugins.spec.tsautotag" },
  { import = "plugins.spec.tscontextcommentstring" },
  { import = "plugins.spec.undotree" },
  { import = "plugins.spec.vimastro" },
  { import = "plugins.spec.vimilluminate" },
  { import = "plugins.spec.vimvisualmulti" },
  { import = "plugins.spec.zen-mode" },
}
</file>

<file path="lua/autocmds.lua">
require "nvchad.autocmds"
</file>

<file path="lua/bootstrap.lua">
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
</file>

<file path="lua/chadrc.lua">
-- https://github.com/NvChad/ui/blob/v2.5/lua/nvconfig.lua

---@type ChadrcConfig
local M = {}
local aux = require "gale.chadrc_aux"
local modules = aux.modules
local themes_customs = aux.themes_customs

M.base46 = {
  transparency = true,
  theme = "decay",
  theme_toggle = { "decay", "decay" },
  integrations = {
    "blankline",
    "cmp",
    "codeactionmenu",
    "dap",
    "devicons",
    "hop",
    "lsp",
    "markview",
    "mason",
    "neogit",
    "notify",
    "nvimtree",
    "rainbowdelimiters",
    "semantic_tokens",
    "todo",
    "whichkey",
  },
}

M.base46.hl_override = {
  DevIconMd = { fg = "#FFFFFF", bg = "NONE" },
  FloatTitle = { link = "FloatBorder" },
  CursorLine = { bg = "black2" },
  CursorLineNr = { bold = true },
  CmpBorder = { link = "FloatBorder" },
  CmpDocBorder = { link = "FloatBorder" },
  TelescopeBorder = { link = "FloatBorder" },
  TelescopePromptBorder = { link = "FloatBorder" },
  NeogitDiffContext = { bg = "#171B21" },
  NeogitDiffContextCursor = { bg = "black2" },
  NeogitDiffContextHighlight = { link = "NeogitDiffContext" },
  TbBufOffModified = { fg = { "green", "black", 50 } },
  FoldColumn = { link = "FloatBorder" },
  Comment = { italic = true },
  ["@comment"] = { link = "Comment" },
  ["@keyword"] = { italic = true },
  ["@markup.heading"] = { fg = "NONE", bg = "NONE" },
}

M.base46.hl_add = {
  YankVisual = { bg = "lightbg" },
  DevIconToml = { fg = "#9C4221", bg = "NONE" },
  Border = { link = "FloatBorder" },
  St_HarpoonInactive = { link = "StText" },
  St_HarpoonActive = { link = "St_LspHints" },
  St_GitBranch = { fg = "baby_pink", bg = M.base46.transparency and "NONE" or "statusline_bg" },
  St_Oil = { fg = "grey_fg", bg = M.base46.transparency and "NONE" or "statusline_bg" },
  GitSignsCurrentLineBlame = { link = "Comment" },
  MarkviewLayer2 = { bg = "#171B21" },
  MarkviewCode = { link = "MarkviewLayer2" },
  HelpviewCode = { link = "MarkviewLayer2" },
  HelpviewInlineCode = { link = "MarkviewInlineCode" },
  HelpviewCodeLanguage = { link = "MarkviewCode" },
  OilWinbar = { fg = "vibrant_green", bold = true },
  CodeActionSignHl = { fg = "#F9E2AF" },
  ["@number.luadoc"] = { fg = "Comment" },
  ["@markup.quote.markdown"] = { bg = "NONE" },
  ["@markup.raw.block.markdown"] = { link = "MarkviewLayer2" },
}

local theme_customs = themes_customs[M.base46.theme]
M.base46 = theme_customs and vim.tbl_deep_extend("force", M.base46, theme_customs) or M.base46

M.ui = {
  cmp = {
    style = "default",
  },
  statusline = {
    theme = "vscode_colored",
    order = {
      "mode",
      "tint",
      "filename",
      "modified",
      "tint",
      "git_custom",
      "%=",
      "lsp_msg",
      "%=",
      "diagnostics",
      "lspx",
      "harpoon",
      "word_count",
      "separator",
      "oil_dir_cwd",
      "cwd",
      "stop",
    },
    modules = {
      hack = modules.statusline.hack,
      filename = modules.statusline.filename,
      harpoon = modules.statusline.harpoon,
      git_custom = modules.statusline.git_custom,
      modified = modules.statusline.modified,
      separator = modules.statusline.separator,
      word_count = modules.statusline.word_count,
      oil_dir_cwd = modules.statusline.oil_dir_cwd,
      stop = modules.statusline.force_stop,
      tint = modules.statusline.tint,
      lspx = modules.lspx,
    },
  },

  tabufline = {
    order = { "buffers", "tabs", "btns" },
  },

  telescope = { style = "bordered" },
}

M.cheatsheet = {
  excluded_groups = { "_" },
}

M.colorify = {
  enabled = true,
  mode = "virtual",
  virt_text = "󱓻 ",
  highlight = { hex = true, lspvars = true },
}

M.lsp = {
  signature = false,
}

M.term = {
  float = {
    border = "rounded",
    height = 0.5,
    width = 0.58,
    col = 0.2,
    row = 0.2,
  },
  sizes = {},
}

return M
</file>

<file path="lua/mappings.lua">
local utils = require "gale.utils"
local map = utils.glb_map

map("n", "z-", "z^") -- Remap z^ into z- for convenience
map("n", "g-", "g;") -- Remap g; into g- for convenience
map("n", ";", ":", { desc = "General enter CMD mode" })
map("i", "jk", "<ESC>", { desc = "General exit insert mode" })
map("n", "<leader>yf", "<cmd>%y+<CR>", { desc = "General copy file content" })
map({ "n", "i" }, "<C-s>", "<cmd>w<CR>", { desc = "General save file" })
map("n", "<Esc>", "<cmd>noh<CR>", { desc = "General clear search highlights" })
map("n", "<leader>cs", "<cmd><CR>", { desc = "General clear statusline" })
map("n", "<leader><F4>", "<cmd>stop<CR>", { desc = "Genaral stop NVIM" })
map("n", "<leader>cm", "<cmd>mes clear<CR>", { desc = "General clear messages" })
-- https://github.com/neovim/neovim/issues/2048
map("i", "<A-BS>", "<C-w>", { desc = "General remove word" })

map("n", "<leader>ol", function()
  vim.ui.open(vim.fn.expand "%:p:h")
end, { desc = "General open file location in file explorer" })

-- Allow moving the cursor through wrapped lines with j, k, <Up> and <Down>
map("n", "j", 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', { expr = true })
map("n", "k", 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', { expr = true })
map("n", "<Up>", 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', { expr = true })
map("n", "<Down>", 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', { expr = true })

-- Buffer motions
map("i", "<C-b>", "<ESC>^i", { desc = "Go to beginning of line" })
map("i", "<C-e>", "<End>", { desc = "Go to end of line" })
map("i", "<C-A-h>", "<Left>", { desc = "Go to left" })
map("i", "<C-A-l>", "<Right>", { desc = "Go to right" })
map("i", "<C-A-j>", "<Down>", { desc = "Go down" })
map("i", "<C-A-k>", "<Up>", { desc = "Go up" })
map("n", "<leader>gm", "<cmd>exe 'normal! ' . line('$')/2 . 'G'<CR>", { desc = "Go to middle of the file" })

-- Move lines up/down
map("n", "<A-Down>", ":m .+1<CR>", { desc = "Move line down" })
map("n", "<A-j>", ":m .+1<CR>", { desc = "Move line down" })
map("n", "<A-Up>", ":m .-2<CR>", { desc = "Move line up" })
map("n", "<A-k>", ":m .-2<CR>", { desc = "Move line up" })
map("i", "<A-Down>", "<Esc>:m .+1<CR>==gi", { desc = "Move line down" })
map("i", "<A-j>", "<Esc>:m .+1<CR>==gi", { desc = "Move line down" })
map("i", "<A-Up>", "<Esc>:m .-2<CR>==gi", { desc = "Move line up" })
map("i", "<A-k>", "<Esc>:m .-2<CR>==gi", { desc = "Move line up" })
map("v", "<A-Down>", ":m '>+1<CR>gv=gv", { desc = "Move line down" })
map("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move line down" })
map("v", "<A-Up>", ":m '<-2<CR>gv=gv", { desc = "Move line up" })
map("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move line up" })

-- Switch buffers
map("n", "<C-h>", "<C-w>h", { desc = "Buffer switch left" })
map("n", "<C-l>", "<C-w>l", { desc = "Buffer switch right" })
map("n", "<C-j>", "<C-w>j", { desc = "Buffer switch down" })
map("n", "<C-k>", "<C-w>k", { desc = "Buffer switch up" })

-- Quick resize pane
map("n", "<C-A-h>", "5<C-w>>", { desc = "Window increase width by 5" })
map("n", "<C-A-l>", "5<C-w><", { desc = "Window decrease width by 5" })
map("n", "<C-A-k>", "5<C-w>+", { desc = "Window increase height by 5" })
map("n", "<C-A-j>", "5<C-w>-", { desc = "Window decrease height by 5" })

-- Togglers
map("n", "<leader>n", "<cmd>set nu!<CR>", { desc = "Toggle line number" })
map("n", "<leader>rn", "<cmd>set rnu!<CR>", { desc = "Toggle relative number" })
map("n", "<leader>ih", "<cmd>ToggleInlayHints<CR>", { desc = "Toggle inlay hints" })
map("n", "<leader>ch", "<cmd>NvCheatsheet<CR>", { desc = "Toggle nvcheatsheet" })

-- LSP
map("n", "<leader>ds", vim.diagnostic.setloclist, { desc = "LSP diagnostic loclist" })

-- Minty
map("n", "<leader>cp", function()
  require("minty.huefy").open()
end, { desc = "Open color picker" })

-- NvChad
map("n", "<leader>th", function()
  require("nvchad.themes").open { style = "flat" }
end, { desc = "Open theme picker" })

-- NvMenu
--[[ local menus = utils.menus
map({ "n", "v" }, "<C-t>", function()
  require("menu").open(menus.main)
end, { desc = "Open NvChad menu" })

map({ "n", "v" }, "<RightMouse>", function()
  vim.cmd.exec '"normal! \\<RightMouse>"'
  require("menu").open(menus.main, { mouse = true })
end, { desc = "Open NvChad menu" }) ]]

-- Term
local term = require "nvchad.term"

map("t", "<Esc><Esc>", "<C-\\><C-N>", { desc = "Term escape terminal mode" })

map({ "n", "t" }, "<A-v>", function()
  term.toggle { pos = "vsp", id = "vtoggleTerm" }
end, { desc = "Term toggle vertical split" })

map({ "n", "t" }, "<A-h>", function()
  term.toggle { pos = "sp", id = "htoggleTerm" }
end, { desc = "Term toggle horizontal split" })

map({ "n", "t" }, "<C-A-l>", function()
  term.toggle {
    pos = "sp",
    id = "htoggleTermLoc",
    cmd = "cd " .. vim.fn.expand "%:p:h",
  }
end, { desc = "Term toggle horizontal split in buffer location" })

map({ "n", "t" }, "<C-A-h>", function()
  term.new {
    pos = "sp",
    id = "hnewTerm",
  }
end, { desc = "Term toggle horizontal split in buffer location" })

map({ "n", "t" }, "<A-i>", function()
  term.toggle { pos = "float", id = "floatTerm" }
end, { desc = "Term toggle floating" })

map({ "n", "t" }, "<A-S-i>", function()
  term.toggle {
    pos = "float",
    id = "floatTermLoc",
    cmd = "cd " .. vim.fn.expand "%:p:h",
  }
end, { desc = "Term toggle floating in buffer location" })

-- TreeSitter
map({ "n", "v" }, "<leader>it", function()
  utils.toggle_inspect_tree()
end, { desc = "TreeSitter toggle inspect tree" })

map("n", "<leader>ii", "<cmd>Inspect<CR>", { desc = "TreeSitter inspect under cursor" })

--- Tabufline
local tabufline = require "nvchad.tabufline"

map("n", "<Tab>", function()
  tabufline.next()
end, { desc = "Buffer go to next" })

map("n", "<S-Tab>", function()
  tabufline.prev()
end, { desc = "Buffer go to prev" })

map("n", "<leader>bn", "<cmd>enew<CR>", { desc = "Buffer new" })
map("n", "<leader>bh", "<cmd>split | enew<CR>", { desc = "Buffer new horizontal split" })
map("n", "<leader>bv", "<cmd>vsplit | enew<CR>", { desc = "Buffer new vertical split" })

map("n", "<leader>x", function()
  tabufline.close_buffer()
end, { desc = "Buffer close" })

map("n", "<A-Left>", function()
  tabufline.move_buf(-1)
end, { desc = "Tabufline move buffer to the left" })

map("n", "<A-Right>", function()
  tabufline.move_buf(1)
end, { desc = "Tabufline move buffer to the right" })

map("n", "<A-|>", "<cmd>TabuflineToggle<CR>", { desc = "Tabufline toggle visibility" })

for i = 1, 9 do
  map("n", "<A-" .. i .. ">", i .. "gt", { desc = "Tab go to tab " .. i })
end

-- Utils
map("n", "gh", function()
  utils.go_to_github_link()
end, { desc = "Go to GitHub link generated from string" })

map(
  "n",
  "<leader>rl",
  "<cmd>s/[a-zA-Z]/\\=nr2char((char2nr(submatch(0)) - (char2nr(submatch(0)) >= 97 ? 97 : 65) + 13) % 26 + (char2nr(submatch(0)) >= 97 ? 97 : 65))/g<CR>",
  { desc = "_ Mum and dad were having fun" }
)

map("n", "<leader>rf", function()
  vim.cmd [[%s/[a-zA-Z]/\=nr2char((char2nr(submatch(0)) - (char2nr(submatch(0)) >= 97 ? 97 : 65) + 13) % 26 + (char2nr(submatch(0)) >= 97 ? 97 : 65))/g]]
end, { desc = "_ Mum and dad were having fun" })
</file>

<file path="lua/options.lua">
require "nvchad.options"

local custom = {
  g = {
    dap_virtual_text = true,
    bookmark_sign = "",
    skip_ts_context_commentstring_module = true,
    tabufline_visible = true,
    showtabline = 1,
  },
  opt = {
    encoding = "utf-8",
    fileencoding = "utf-8",
    clipboard = "unnamedplus",
    -- Folds
    foldenable = true,
    foldmethod = "expr",
    foldexpr = "v:lua.vim.treesitter.foldexpr()",
    foldcolumn = "1",
    foldtext = "",
    foldlevel = 99,
    foldlevelstart = 5,
    foldnestmax = 5,
    fillchars = { eob = " ", fold = " ", foldopen = "", foldsep = " ", foldclose = "", lastline = " " },
    -- Prevent issues with some language servers
    backup = false,
    swapfile = false,
    -- Always show minimum n lines after/before current line
    scrolloff = 10,
    -- True color support
    termguicolors = true,
    emoji = false,
    relativenumber = true,
    -- Line break/wrap behaviours
    wrap = true,
    linebreak = true,
    textwidth = 0,
    -- wrapmargin = 0,
    colorcolumn = "+1",
    -- Indentation values
    tabstop = 2,
    shiftwidth = 0, -- 0 forces same value as tabstop
    expandtab = true,
    autoindent = true,
    cursorline = true,
    cursorlineopt = "both",
    inccommand = "split",
    ignorecase = true,
    updatetime = 100,
    lazyredraw = false,
  },
}

-- Set custom options with safety checks
for i, opts in pairs(custom) do
  for k, v in pairs(opts) do
    local success, err = pcall(function()
      vim[i][k] = v
    end)
    if not success then
      vim.notify("Failed to set option " .. i .. "." .. k .. ": " .. err, vim.log.levels.WARN)
    end
  end
end

-- Set special options that need append operations
vim.opt.iskeyword:append { "_", "@", ".", "-" }
vim.opt.path:append { "**", "lua", "src" }
</file>

<file path="themes/catppuccin-frape.lua">
---@class Base46Table
---Credits to original port author: [BK](https://github.com/BrunoKrugel)

local M = {}
M.base_30 = {
  white = "#D9E0EE",
  darker_black = "#313346",
  black = "#313346", --  nvim bg
  black2 = "#3B3D54",
  one_bg = "#2D2C3C", -- real bg of onedark
  one_bg2 = "#38364A",
  one_bg3 = "#424057",
  grey = "#75799E",
  grey_fg = "#8386A8",
  grey_fg2 = "#7C80A3",
  light_grey = "#605F6F",
  red = "#F38BA8",
  baby_pink = "#FFA5C3",
  pink = "#F5C2E7",
  line = "#383747", -- for lines like vertsplit
  green = "#A6E3A1",
  vibrant_green = "#A5C989",
  nord_blue = "#8BC2F0",
  blue = "#89B4FA",
  yellow = "#F9E2AF",
  sun = "#FFE9B6",
  purple = "#CBA6F7",
  dark_purple = "#B697E1",
  teal = "#B5E8E0",
  orange = "#F8BD96",
  cyan = "#89DCEB",
  statusline_bg = "#313346",
  lightbg = "#2F2E3E",
  pmenu_bg = "#A6E3A1",
  folder_bg = "#74C7EC",
  lavender = "#B4BEFE",
}

M.base_16 = {
  base00 = "#313346",
  base01 = "#282737",
  base02 = "#2F2E3E",
  base03 = "#383747",
  base04 = "#414050",
  base05 = "#BFC6D4",
  base06 = "#CCD3E1",
  base07 = "#D9E0EE",
  base08 = "#F38BA8",
  base09 = "#F8BD96",
  base0A = "#FAE3B0",
  base0B = "#A5C989",
  base0C = "#89DCEB",
  base0D = "#89B4FA",
  base0E = "#CBA6F7",
  base0F = "#F38BA8",
}

M.polish_hl = {
  treesitter = {
    -- ["@type"] = { fg = M.base_30.purple },
    -- ["@variable"] = { fg = M.base_30.lavender },
    ["@variable.builtin"] = { fg = M.base_30.red },
    ["@function.builtin"] = { fg = M.base_30.cyan },
    ["Function"] = { fg = M.base_30.blue },
    ["@function"] = { fg = M.base_30.blue },
    ["@keyword"] = { fg = M.base_30.pink },
    ["@property"] = { fg = M.base_30.cyan },
    ["@type.builtin"] = { fg = M.base_30.purple },
    ["@variable"] = { fg = M.base_30.sun },
  },
}

M.type = "dark"

return M
</file>

</files>
