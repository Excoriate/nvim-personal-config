-- AstroLSP configuration for DevOps and development
-- Configuration documentation: `:h astrolsp`

---@type LazySpec
return {
  "AstroNvim/astrolsp",
  dependencies = { "mason-org/mason.nvim" },
  ---@type AstroLSPOpts
  opts = {
    -- Enable the product server set synchronously during AstroFile. Mason's
    -- deferred automatic enablement runs after FileType and misses the first buffer.
    servers = {
      "azure_pipelines_ls",
      "basedpyright",
      "bashls",
      "docker_compose_language_service",
      "dockerls",
      "gopls",
      "helm_ls",
      "jsonls",
      "lua_ls",
      "marksman",
      "taplo",
      "terraformls",
      "vtsls",
      "yamlls",
    },
    features = {
      codelens = true,
      inlay_hints = true, -- enabled for Go, Rust, TypeScript
      semantic_tokens = true,
    },
    formatting = {
      format_on_save = {
        enabled = true,
        allow_filetypes = {
          "go",
          "rust",
          "typescript",
          "javascript",
          "lua",
          "terraform",
          "json",
          "toml",
          "sh",
          "bash",
          -- INTENTIONALLY EXCLUDED:
          --   markdown: collapses tables, reflows paragraphs, breaks soft-break (two
          --             trailing spaces = line break in commonmark). Use :Format on demand.
          --   yaml:     collapses anchors/aliases (breaks Helm/Kustomize); some yamlls
          --             formatters reorder keys. Use :Format on demand.
        },
        ignore_filetypes = {
          -- Helm template filetype is variously detected as `helm`, `yaml.helm`,
          -- or `gotmpl`. Exclude all three to keep `{{ .Values }}` placeholders intact.
          "helm",
          "yaml.helm",
          "gotmpl",
        },
      },
      disabled = {
        -- prefer dedicated formatters over LSP formatting
        "ts_ls", -- use prettier instead
        "jsonls", -- use prettier/jq instead
      },
      timeout_ms = 3000, -- longer timeout for terraform-ls
    },
    ---@diagnostic disable: missing-fields
    config = {
      -- NOTE: gopls / rust_analyzer / ts_ls intentionally NOT configured here.
      --   - gopls is owned by astrocommunity.pack.go (comprehensive defaults,
      --     including analyses + hints + usePlaceholders). Duplicating ANY key
      --     here raises ":LSP[gopls]: Invalid settings: duplicate value for X".
      --   - rust_analyzer is owned by astrocommunity.pack.rust via rustaceanvim,
      --     which ignores astrolsp.config entirely.
      --   - ts_ls comes from astrocommunity.pack.typescript with sane inlay-hints.
      -- Override individual sub-keys here only with `vim.tbl_deep_extend` semantics
      -- AND explicit knowledge of what the community pack already sets.
      --
      azure_pipelines_ls = {
        filetypes = { "yaml.azure-pipelines" },
      },
      helm_ls = {
        filetypes = { "helm", "yaml.helm" },
      },
      -- Terraform LS supports Terraform configuration and variable files only.
      terraformls = {
        cmd = { "terraform-ls", "serve" },
        filetypes = { "terraform", "terraform-vars" },
      },
      -- YAML with comprehensive schema support
      yamlls = {
        filetypes = {
          "yaml",
          "yaml.cloudformation",
          "yaml.docker-compose",
          "yaml.gitlab",
          "yaml.kubernetes",
          "yaml.taskfile",
        },
        settings = {
          yaml = {
            schemaStore = {
              enable = true,
              url = "https://www.schemastore.org/api/json/catalog.json",
            },
            schemas = {
              -- GitHub Actions
              ["https://json.schemastore.org/github-workflow.json"] = ".github/workflows/*.{yml,yaml}",
              ["https://json.schemastore.org/github-action.json"] = "action.{yml,yaml}",

              -- Azure DevOps Pipelines
              ["https://raw.githubusercontent.com/microsoft/azure-pipelines-vscode/main/service-schema.json"] = {
                "azure-pipelines.{yml,yaml}",
                ".azure-pipelines/*.{yml,yaml}",
                "pipelines/*.{yml,yaml}",
                "*pipeline*.{yml,yaml}",
                "ci/*.{yml,yaml}",
                "cd/*.{yml,yaml}",
              },

              -- Kubernetes
              kubernetes = {
                "*.k8s.{yml,yaml}",
                "k8s/*.{yml,yaml}",
                "kubernetes/*.{yml,yaml}",
                "manifests/*.{yml,yaml}",
                "deploy/*.{yml,yaml}",
              },
              ["https://json.schemastore.org/kustomization.json"] = "kustomization.{yml,yaml}",
              ["https://json.schemastore.org/chart.json"] = "Chart.{yml,yaml}",

              -- Docker Compose
              ["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"] = {
                "{docker-compose,compose}*.{yml,yaml}",
                "docker-compose/*.{yml,yaml}",
              },

              -- Taskfile
              ["https://json.schemastore.org/taskfile.json"] = {
                "Taskfile*.{yml,yaml}",
                "taskfile*.{yml,yaml}",
              },

              -- AWS CloudFormation
              ["https://raw.githubusercontent.com/awslabs/goformation/master/schema/cloudformation.schema.json"] = {
                "*.cf.{yml,yaml}",
                "cloudformation/*.{yml,yaml}",
                "cfn/*.{yml,yaml}",
                "template.{yml,yaml}",
              },

              -- Ansible
              ["https://raw.githubusercontent.com/ansible/ansible-lint/main/src/ansiblelint/schemas/ansible.json#/$defs/playbook"] = {
                "playbook*.{yml,yaml}",
                "ansible/*.{yml,yaml}",
              },

              -- GitLab CI
              ["https://gitlab.com/gitlab-org/gitlab/-/raw/master/app/assets/javascripts/editor/schema/ci.json"] = ".gitlab-ci.{yml,yaml}",

              -- Dependabot
              ["https://json.schemastore.org/dependabot-2.0.json"] = ".github/dependabot.{yml,yaml}",

              -- Renovate
              ["https://docs.renovatebot.com/renovate-schema.json"] = {
                "renovate.json",
                ".renovaterc",
                ".renovaterc.json",
              },
            },
            validate = true,
            completion = true,
            hover = true,
            format = { enable = true },
          },
        },
      },
      -- TOML (for pyproject.toml, Cargo.toml, etc.)
      taplo = {
        -- Taplo 0.10.0 fetches its broken compiled catalog before client settings arrive.
        -- Suppress workspaceFolders until a release containing taplo#866 is available.
        workspace_folders = vim.NIL,
        root_dir = function(bufnr, on_dir)
          local filename = vim.api.nvim_buf_get_name(bufnr)
          on_dir(filename ~= "" and vim.fs.dirname(filename) or vim.uv.cwd())
        end,
        cmd_env = { RUST_LOG = "error" },
        settings = {
          evenBetterToml = {
            formatter = {
              alignEntries = false,
              indentTables = true,
            },
            schema = {
              enabled = false,
              catalogs = {},
            },
          },
        },
      },
    },
    -- keymaps on LSP attach
    mappings = {
      n = {
        gD = {
          function() vim.lsp.buf.declaration() end,
          desc = "Declaration of current symbol",
          cond = "textDocument/declaration",
        },
        ["<Leader>uY"] = {
          function() require("astrolsp.toggles").buffer_semantic_tokens() end,
          desc = "Toggle LSP semantic highlight (buffer)",
          cond = function(client)
            return client.supports_method "textDocument/semanticTokens/full" and vim.lsp.semantic_tokens ~= nil
          end,
        },
        -- Terraform specific
        ["<Leader>ti"] = {
          function() vim.cmd "!terraform init" end,
          desc = "Terraform Init",
          cond = function() return vim.bo.filetype == "terraform" end,
        },
        ["<Leader>tv"] = {
          function() vim.cmd "!terraform validate" end,
          desc = "Terraform Validate",
          cond = function() return vim.bo.filetype == "terraform" end,
        },
        ["<Leader>tp"] = {
          function() vim.cmd "!terraform plan" end,
          desc = "Terraform Plan",
          cond = function() return vim.bo.filetype == "terraform" end,
        },
      },
    },
    -- codelens: use AstroNvim defaults — skips deprecated vim.lsp.codelens.refresh on Nvim 0.12+
    -- when vim.lsp.codelens.enable exists (see _astrolsp_autocmds.lua).
  },
}
