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
