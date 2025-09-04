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
