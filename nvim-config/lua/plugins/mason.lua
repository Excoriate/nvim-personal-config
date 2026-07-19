-- Customize Mason for DevOps and development tools

---@type LazySpec
return {
  -- use mason-tool-installer for automatically installing Mason packages
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = {
      -- Make sure to use the names found in `:Mason`
      ensure_installed = {
        -- Lua
        "lua-language-server",
        "stylua",

        -- Go
        "gopls",
        "goimports",
        "gofumpt",
        "golangci-lint",
        "delve", -- debugger

        -- Rust (rust-analyzer installed via rustup is preferred)
        -- "rust-analyzer", -- uncomment if not using rustup

        -- TypeScript/JavaScript/Bun/Node
        "typescript-language-server",
        "prettier",
        "eslint_d",
        "biome", -- fast formatter/linter for JS/TS

        -- Terraform/Terragrunt
        "terraform-ls",
        "tflint",

        -- Kubernetes/YAML/Helm
        "yaml-language-server",
        "helm-ls",
        "yamlfmt",
        "yamllint",

        -- Docker
        "dockerfile-language-server",
        "hadolint",
        "docker-compose-language-service",

        -- Shell/Bash
        "bash-language-server",
        "shellcheck",
        "shfmt",

        -- JSON/TOML
        "json-lsp",
        "jq",
        "taplo", -- TOML LSP

        -- Markdown
        "markdownlint",
        "marksman",
        "vale", -- prose linter

        -- Python: basedpyright + ruff supplied by astrocommunity.pack.python.*
        -- (community.lua). Only mypy is added here on top.
        "mypy", -- Python type checker

        -- AWS
        "cfn-lint", -- CloudFormation linter

        -- Make/Justfile
        -- Note: just LSP not in mason, handled via treesitter

        -- General
        "tree-sitter-cli",
        "codespell",
        "actionlint", -- GitHub Actions linter
      },
    },
  },
  {
    "mason-org/mason-lspconfig.nvim",
    opts = {
      automatic_enable = false,
    },
  },
}
