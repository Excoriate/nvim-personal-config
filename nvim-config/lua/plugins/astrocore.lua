-- AstroCore provides a central place to modify mappings, vim options, autocommands, and more!
-- Configuration documentation can be found with `:h astrocore`
-- DX enhancements inspired by orhun/dotfiles

---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    -- Configure core features of AstroNvim
    features = {
      large_buf = { size = 1024 * 256, lines = 10000 }, -- disable features for large files
      autopairs = true,
      cmp = true,
      diagnostics = { virtual_text = true, virtual_lines = false },
      highlighturl = true,
      notifications = true,
    },
    -- Diagnostics configuration
    diagnostics = {
      virtual_text = true,
      underline = true,
      update_in_insert = false,
      severity_sort = true,
    },
    -- Filetypes
    filetypes = {
      extension = {
        -- Terraform/Terragrunt
        tf = "terraform",
        tfvars = "terraform-vars",
        hcl = "hcl",
        -- Markdown
        md = "markdown",
        mdx = "markdown",
        -- Config
        toml = "toml",
        -- AWS
        cf = "yaml.cloudformation",
        cfn = "yaml.cloudformation",
      },
      filename = {
        -- Terragrunt
        ["terragrunt.hcl"] = "hcl",
        [".terragrunt-version"] = "text",
        -- Just
        ["Justfile"] = "just",
        ["justfile"] = "just",
        [".justfile"] = "just",
        -- Make
        ["Makefile"] = "make",
        ["makefile"] = "make",
        ["GNUmakefile"] = "make",
        -- Taskfile
        ["Taskfile.yml"] = "yaml.taskfile",
        ["Taskfile.yaml"] = "yaml.taskfile",
        ["taskfile.yml"] = "yaml.taskfile",
        -- Docker
        ["Dockerfile"] = "dockerfile",
        ["dockerfile"] = "dockerfile",
        ["Containerfile"] = "dockerfile",
        [".dockerignore"] = "gitignore",
        ["compose.yml"] = "yaml.docker-compose",
        ["compose.yaml"] = "yaml.docker-compose",
        ["docker-compose.yml"] = "yaml.docker-compose",
        ["docker-compose.yaml"] = "yaml.docker-compose",
        -- Node/Bun
        [".nvmrc"] = "text",
        [".node-version"] = "text",
        ["package.json"] = "json",
        ["tsconfig.json"] = "jsonc",
        ["bunfig.toml"] = "toml",
        -- Python/UV
        ["pyproject.toml"] = "toml",
        ["setup.py"] = "python",
        ["setup.cfg"] = "ini",
        ["requirements.txt"] = "requirements",
        [".python-version"] = "text",
        ["uv.lock"] = "toml",
        -- Azure DevOps
        ["azure-pipelines.yml"] = "yaml.azure-pipelines",
        ["azure-pipelines.yaml"] = "yaml.azure-pipelines",
        -- AWS
        ["template.yml"] = "yaml.cloudformation",
        ["template.yaml"] = "yaml.cloudformation",
        -- Kubernetes
        ["kustomization.yaml"] = "yaml",
        ["kustomization.yml"] = "yaml",
        -- Helm
        ["Chart.yaml"] = "yaml.helm",
        ["values.yaml"] = "yaml.helm",
      },
      pattern = {
        -- Terraform
        [".*%.tf%..*"] = "terraform",
        [".*%.tfvars"] = "terraform-vars",
        -- Azure DevOps
        [".*%.azure%-pipelines.*%.ya?ml"] = "yaml.azure-pipelines",
        [".*/pipelines/.*%.ya?ml"] = "yaml.azure-pipelines",
        [".*/ci/.*%.ya?ml"] = "yaml.azure-pipelines",
        -- Kubernetes
        [".*%.k8s%.ya?ml"] = "yaml.kubernetes",
        [".*/k8s/.*%.ya?ml"] = "yaml.kubernetes",
        [".*/kubernetes/.*%.ya?ml"] = "yaml.kubernetes",
        [".*/manifests/.*%.ya?ml"] = "yaml.kubernetes",
        -- Docker
        ["Dockerfile%..*"] = "dockerfile",
        [".*%.dockerfile"] = "dockerfile",
        -- CloudFormation
        [".*%.cf%.ya?ml"] = "yaml.cloudformation",
        [".*/cloudformation/.*%.ya?ml"] = "yaml.cloudformation",
      },
    },
    -- Vim options
    options = {
      opt = {
        relativenumber = true,
        number = true,
        spell = false,
        signcolumn = "auto",
        wrap = false,
        smartcase = true, -- smart case in search
        ignorecase = true, -- ignore case in search
        modifiable = true,
        autoread = true, -- auto reload files changed outside vim
        scrolloff = 8, -- keep 8 lines above/below cursor
        sidescrolloff = 8, -- keep 8 columns left/right of cursor
        cursorline = true, -- highlight current line
        termguicolors = true,
        undofile = true, -- persistent undo
        updatetime = 250, -- faster completion
        timeoutlen = 300, -- faster which-key popup
        splitbelow = true, -- horizontal splits go below
        splitright = true, -- vertical splits go right
      },
      g = {
        autoformat_enabled = true,
        cmp_enabled = true,
        autopairs_enabled = true,
        diagnostics_enabled = true,
        diagnostics_mode = 3, -- 0=off, 1=status, 2=virtual off, 3=all
        status_diagnostics_enabled = true,
        inlay_hints_enabled = true,
        lsp_handlers_enabled = true,
        icons_enabled = true,
        ui_notifications_enabled = true,
      },
    },
    -- Key mappings
    mappings = {
      n = {
        -- Buffer navigation (H/L like orhun)
        L = {
          function() require("astrocore.buffer").nav(vim.v.count1) end,
          desc = "Next buffer",
        },
        H = {
          function() require("astrocore.buffer").nav(-vim.v.count1) end,
          desc = "Previous buffer",
        },
        -- Also keep bracket mappings
        ["]b"] = { function() require("astrocore.buffer").nav(vim.v.count1) end, desc = "Next buffer" },
        ["[b"] = { function() require("astrocore.buffer").nav(-vim.v.count1) end, desc = "Previous buffer" },

        -- Buffer close from tabline
        ["<Leader>bd"] = {
          function()
            require("astroui.status.heirline").buffer_picker(
              function(bufnr) require("astrocore.buffer").close(bufnr) end
            )
          end,
          desc = "Close buffer from tabline",
        },

        -- Quick save. <C-s> requires `stty -ixon` in your shell rc on POSIX terminals
        -- (otherwise the terminal eats it as XOFF/flow-control). Provide <Leader>w as
        -- a portable fallback.
        ["<C-S>"] = false, -- same terminal keycode as <C-s>; disable inherited force-write mapping
        ["<C-s>"] = { ":w!<cr>", desc = "Save file" },
        ["<Leader>w"] = { ":w<cr>", desc = "Save file (portable)" },
        -- :confirm prompts on unsaved buffers — replaces dangerous ":qa!" data-loss path.
        ["<C-Q>"] = false, -- same terminal keycode as <C-q>; disable inherited force-quit mapping
        ["<C-q>"] = { ":confirm qa<cr>", desc = "Quit all (prompts on unsaved)" },

        -- Clear search highlight
        ["<Esc>"] = { ":nohl<cr>", desc = "Clear highlight" },

        -- Scroll with centering (keeps cursor centered)
        ["<C-d>"] = { "<C-d>zz", desc = "Scroll down (centered)" },
        ["<C-u>"] = { "<C-u>zz", desc = "Scroll up (centered)" },

        -- Search results centered
        ["n"] = { "nzzzv", desc = "Next search result (centered)" },
        ["N"] = { "Nzzzv", desc = "Prev search result (centered)" },

        -- Toggle word wrap
        ["<A-z>"] = { ":set wrap!<cr>", desc = "Toggle word wrap" },

        -- Terminal toggle
        ["<C-\\>"] = { ":ToggleTerm direction=horizontal size=15<cr>", desc = "Toggle terminal" },

        -- Reload config
        ["<Leader>r"] = { ":AstroReload<cr>", desc = "Reload AstroNvim" },

        -- Git conflict navigation (safe — not vim operators)
        ["[x"] = { ":GitConflictPrevConflict<cr>", desc = "Prev Git conflict" },
        ["]x"] = { ":GitConflictNextConflict<cr>", desc = "Next Git conflict" },
        ["<Leader>gx"] = { ":GitConflictListQf<cr>", desc = "List Git conflicts" },
        -- Conflict choose-ours/theirs/both/none under <Leader>gc* to avoid SHADOWING
        -- vim's foundational change-operators: `co` (no-op), `ct{char}` (change-til),
        -- `cb` (change-back-word). Top-level co/ct/cb were a latent file-mangle path
        -- across every buffer — buffer-scoped under <Leader>gc* now.
        ["<Leader>gco"] = { ":GitConflictChooseOurs<cr>", desc = "Conflict: choose ours" },
        ["<Leader>gct"] = { ":GitConflictChooseTheirs<cr>", desc = "Conflict: choose theirs" },
        ["<Leader>gcb"] = { ":GitConflictChooseBoth<cr>", desc = "Conflict: choose both" },
        ["<Leader>gc0"] = { ":GitConflictChooseNone<cr>", desc = "Conflict: choose none" },

        -- Quick access
        ["<Leader>gg"] = { ":Git<cr>", desc = "Git status (Fugitive)" },

        -- Neo-tree focus (quick return to tree)
        ["\\"] = { "<cmd>Neotree focus<cr>", desc = "Focus Neo-tree" },
        ["<Leader>e"] = { "<cmd>Neotree toggle<cr>", desc = "Toggle Neo-tree" },

        -- Window navigation handled by smart-splits.nvim (AstroNvim default; tmux-aware).
        -- It owns <C-h/j/k/l>; explicit <C-w>{hjkl} here would shadow it and trip
        -- the `:checkhealth astrocore` "Conflicting mappings" check.

        -- Resize windows with arrows
        ["<C-Up>"] = { ":resize -2<cr>", desc = "Resize window up" },
        ["<C-Down>"] = { ":resize +2<cr>", desc = "Resize window down" },
        ["<C-Left>"] = { ":vertical resize -2<cr>", desc = "Resize window left" },
        ["<C-Right>"] = { ":vertical resize +2<cr>", desc = "Resize window right" },

        -- Move lines up/down
        ["<A-j>"] = { ":m .+1<cr>==", desc = "Move line down" },
        ["<A-k>"] = { ":m .-2<cr>==", desc = "Move line up" },

        -- Quickfix navigation
        ["[q"] = { ":cprev<cr>", desc = "Prev quickfix" },
        ["]q"] = { ":cnext<cr>", desc = "Next quickfix" },
        ["[Q"] = { ":cfirst<cr>", desc = "First quickfix" },
        ["]Q"] = { ":clast<cr>", desc = "Last quickfix" },
      },
      i = {
        -- Quick save from insert mode
        ["<C-s>"] = { "<Esc>:w!<cr>", desc = "Save file" },

        -- Move lines in insert mode
        ["<A-j>"] = { "<Esc>:m .+1<cr>==gi", desc = "Move line down" },
        ["<A-k>"] = { "<Esc>:m .-2<cr>==gi", desc = "Move line up" },
      },
      v = {
        -- Paste without replacing register
        ["<Leader>p"] = { '"0p', desc = "Paste (keep register)" },

        -- Move selected lines
        ["<A-j>"] = { ":m '>+1<cr>gv=gv", desc = "Move selection down" },
        ["<A-k>"] = { ":m '<-2<cr>gv=gv", desc = "Move selection up" },

        -- Stay in visual mode when indenting
        ["<"] = { "<gv", desc = "Indent left" },
        [">"] = { ">gv", desc = "Indent right" },

        -- Search and replace in selection
        ["<C-r>"] = { '"hy:%s/<C-r>h//gc<left><left><left>', desc = "Replace selection" },
      },
      t = {
        -- Exit terminal mode
        ["<C-\\>"] = { "<C-\\><C-n>", desc = "Exit terminal mode" },
        ["<Esc><Esc>"] = { "<C-\\><C-n>", desc = "Exit terminal mode" },

        -- Terminal window navigation handled by smart-splits.nvim (same as normal mode).
      },
      x = {
        -- Better paste in visual mode (don't replace register)
        ["p"] = { '"_dP', desc = "Paste (don't replace register)" },
      },
    },
  },
}
