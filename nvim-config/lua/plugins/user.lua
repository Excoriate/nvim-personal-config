-- User plugins (inspired by orhun/dotfiles with DevOps additions)

---@type LazySpec
return {
  -- Kanagawa colorscheme (enhanced syntax highlighting + transparent)
  {
    "rebelot/kanagawa.nvim",
    priority = 1000,
    opts = {
      compile = true, -- faster startup via cached highlights
      transparent = true,
      theme = "wave", -- wave (default), dragon (darker), lotus (light)
      background = {
        dark = "wave",
        light = "lotus",
      },
      -- Enhanced syntax highlighting
      dimInactive = false, -- dim inactive windows
      terminalColors = true, -- terminal colors match theme
      colors = {
        theme = {
          all = {
            ui = {
              bg_gutter = "none",
            },
          },
        },
        -- Boost palette contrast for better syntax differentiation
        palette = {
          -- Slightly brighter semantic colors
          sumiInk0 = "#16161D", -- darker background for contrast
          fujiWhite = "#DCD7BA", -- slightly warmer foreground
        },
      },
      overrides = function(colors)
        local theme = colors.theme
        local palette = colors.palette
        return {
          -- Transparent floating windows
          NormalFloat = { bg = "none" },
          FloatBorder = { bg = "none" },
          FloatTitle = { bg = "none" },
          -- Telescope
          TelescopeBorder = { bg = "none" },
          TelescopeNormal = { bg = "none" },
          -- Pmenu (completion menu)
          Pmenu = { fg = theme.ui.shade0, bg = theme.ui.bg_p1 },
          PmenuSel = { fg = "none", bg = theme.ui.bg_p2 },
          PmenuSbar = { bg = theme.ui.bg_m1 },
          PmenuThumb = { bg = theme.ui.bg_p2 },

          -- Enhanced TreeSitter highlighting
          ["@variable"] = { fg = palette.fujiWhite },
          ["@variable.builtin"] = { fg = palette.oniViolet, italic = true },
          ["@variable.parameter"] = { fg = palette.surimiOrange, italic = true },
          ["@variable.member"] = { fg = palette.carpYellow },
          ["@constant"] = { fg = palette.surimiOrange },
          ["@constant.builtin"] = { fg = palette.sakuraPink, bold = true },
          ["@function"] = { fg = palette.crystalBlue },
          ["@function.builtin"] = { fg = palette.peachRed },
          ["@function.call"] = { fg = palette.crystalBlue },
          ["@function.method"] = { fg = palette.crystalBlue },
          ["@function.method.call"] = { fg = palette.crystalBlue },
          ["@constructor"] = { fg = palette.waveAqua2 },
          ["@keyword"] = { fg = palette.oniViolet, bold = true },
          ["@keyword.function"] = { fg = palette.oniViolet, bold = true },
          ["@keyword.return"] = { fg = palette.peachRed, bold = true },
          ["@keyword.operator"] = { fg = palette.sakuraPink },
          ["@operator"] = { fg = palette.boatYellow2 },
          ["@type"] = { fg = palette.waveAqua2 },
          ["@type.builtin"] = { fg = palette.waveAqua2, italic = true },
          ["@string"] = { fg = palette.springGreen },
          ["@string.escape"] = { fg = palette.springBlue, bold = true },
          ["@string.regex"] = { fg = palette.boatYellow2 },
          ["@number"] = { fg = palette.sakuraPink },
          ["@boolean"] = { fg = palette.surimiOrange, bold = true },
          ["@comment"] = { fg = palette.fujiGray, italic = true },
          ["@comment.todo"] = { fg = palette.roninYellow, bold = true },
          ["@punctuation.bracket"] = { fg = palette.springViolet2 },
          ["@punctuation.delimiter"] = { fg = palette.springViolet2 },
          ["@tag"] = { fg = palette.peachRed },
          ["@tag.attribute"] = { fg = palette.waveAqua2 },
          ["@tag.delimiter"] = { fg = palette.springViolet2 },

          -- LSP semantic tokens (layered on TreeSitter)
          ["@lsp.type.comment"] = { link = "@comment" },
          ["@lsp.type.enum"] = { fg = palette.waveAqua2 },
          ["@lsp.type.enumMember"] = { fg = palette.surimiOrange },
          ["@lsp.type.interface"] = { fg = palette.carpYellow, italic = true },
          ["@lsp.type.keyword"] = { link = "@keyword" },
          ["@lsp.type.namespace"] = { fg = palette.surimiOrange },
          ["@lsp.type.parameter"] = { link = "@variable.parameter" },
          ["@lsp.type.property"] = { link = "@variable.member" },
          ["@lsp.type.variable"] = {}, -- use treesitter
          ["@lsp.type.macro"] = { fg = palette.peachRed },
          ["@lsp.type.method"] = { link = "@function.method" },
          ["@lsp.type.function"] = { link = "@function" },
          ["@lsp.type.type"] = { link = "@type" },
          ["@lsp.type.typeParameter"] = { fg = palette.waveAqua2, italic = true },
          ["@lsp.mod.deprecated"] = { strikethrough = true },
          ["@lsp.mod.readonly"] = { italic = true },
          ["@lsp.mod.defaultLibrary"] = { bold = true },

          -- Diagnostic underlines (better visibility)
          DiagnosticUnderlineError = { undercurl = true, sp = palette.samuraiRed },
          DiagnosticUnderlineWarn = { undercurl = true, sp = palette.roninYellow },
          DiagnosticUnderlineInfo = { undercurl = true, sp = palette.dragonBlue },
          DiagnosticUnderlineHint = { undercurl = true, sp = palette.waveAqua1 },
        }
      end,
    },
  },

  -- Rust: Cargo.toml dependency management
  {
    "saecki/crates.nvim",
    event = { "BufRead Cargo.toml" },
    opts = {
      lsp = {
        enabled = true,
        completion = true,
      },
    },
  },

  {
    "stevearc/aerial.nvim",
    enabled = false,
  },

  -- Signature help is provided by blink.cmp (AstroNvim v5+ default); lsp_signature.nvim
  -- removed to eliminate redundancy and reduce LspAttach handler stack.

  -- Git conflict resolution (keymaps in astrocore.lua)
  {
    "akinsho/git-conflict.nvim",
    version = "*",
    event = "BufReadPre",
    opts = {
      default_mappings = false, -- using astrocore.lua keymaps instead
      highlights = {
        incoming = "DiffAdd",
        current = "DiffText",
      },
    },
  },

  -- Generate GitHub/GitLab permalinks
  {
    "ruifm/gitlinker.nvim",
    dependencies = "nvim-lua/plenary.nvim",
    event = "BufRead",
    opts = {},
  },

  -- Zen mode handled by snacks.zen below; <Leader>z mapping registered there.

  -- Markdown preview
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = "markdown",
    build = function() vim.fn["mkdp#util#install"]() end,
    keys = {
      { "<Leader>mp", "<cmd>MarkdownPreviewToggle<cr>", desc = "Markdown Preview" },
    },
  },

  -- Color highlighting handled by nvim-highlight-colors (AstroNvim v5+ default;
  -- Tailwind-aware, LSP-color-info-aware). nvim-colorizer removed to eliminate
  -- duplicate highlight passes on every BufReadPost / BufNewFile.

  -- Better quickfix
  {
    "kevinhwang91/nvim-bqf",
    ft = "qf",
    opts = {},
  },

  -- Terraform doc viewer (opens terraform docs in browser)
  {
    "ANGkeith/telescope-terraform-doc.nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },
    keys = {
      {
        "<Leader>ftd",
        function()
          require("telescope").load_extension "terraform_doc"
          vim.cmd "Telescope terraform_doc"
        end,
        desc = "Terraform Docs",
      },
    },
  },

  -- Go: additional tools
  {
    "olexsmir/gopher.nvim",
    ft = "go",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {},
  },

  -- Rust: the AstroCommunity pack delegates rust-analyzer ownership to rustup.
  -- Resolve through rustup explicitly so a stale Mason shim cannot shadow it.
  {
    "mrcjkb/rustaceanvim",
    opts = function(_, opts)
      local rustup = vim.fn.expand "$HOME/.cargo/bin/rustup"
      if vim.fn.executable(rustup) == 0 then rustup = "rustup" end
      opts.server = opts.server or {}
      opts.server.cmd = { rustup, "run", "stable", "rust-analyzer" }
    end,
  },

  -- GitHub Copilot (optional - uncomment if desired)
  -- { "github/copilot.vim" },

  -- Smear cursor animation (from orhun's config)
  -- In vscode-neovim / Cursor, this plugin's extmarks often render as a solid
  -- horizontal bar (e.g. black) because VS Code owns the editor surface.
  {
    "sphamba/smear-cursor.nvim",
    enabled = function() return not vim.g.vscode end,
    opts = {
      stiffness = 0.8,
      trailing_stiffness = 0.5,
      distance_stop_animating = 0.5,
      hide_target_hack = false,
      smear_between_buffers = true,
      smear_between_neighbor_lines = true,
      legacy_computing_symbols_support = false,
    },
  },

  -- Fugitive for git operations
  {
    "tpope/vim-fugitive",
    cmd = { "Git", "G", "Gdiffsplit", "Gvdiffsplit", "Gread", "Gwrite", "Ggrep", "GMove", "GDelete", "GBrowse" },
    keys = {
      { "<Leader>gs", "<cmd>Git<cr>", desc = "Git Status (Fugitive)" },
      { "<Leader>gd", "<cmd>Gdiffsplit<cr>", desc = "Git Diff Split" },
      { "<Leader>gb", "<cmd>Git blame<cr>", desc = "Git Blame" },
    },
  },

  -- Snacks: consolidated UI/UX modules. AstroNvim v5+ ships snacks as a default dep;
  -- this spec deep-merges our module selections on top of the framework defaults.
  --
  -- Wired:
  --   dashboard  -> custom ASCII boot screen
  --   bigfile    -> auto-disable heavy features on >1.5MB files (perf safeguard)
  --   bufdelete  -> :Bdelete that preserves window layout
  --   image      -> EXPLICITLY DISABLED (avoids gs/tectonic/kitty checkhealth errors;
  --                                       re-enable when ghostscript + kitty are installed)
  --   input      -> binds vim.ui.input  (fixes checkhealth "not set to Snacks.input")
  --   notifier   -> in-buffer notifications (replaces nvim-notify)
  --   picker     -> binds vim.ui.select via ui_select = true
  --   quickfile  -> defer plugins until first real file load (-startup time)
  --   scroll     -> smooth scroll
  --   words      -> LSP/treesitter word-references highlight (replaces vim-illuminate)
  --   zen        -> :lua Snacks.zen() — replaces folke/zen-mode (mapping below)
  {
    "folke/snacks.nvim",
    -- Load eagerly: input + picker.ui_select must replace vim.ui.* BEFORE the first
    -- prompt fires. Without lazy=false the snacks override races against AstroNvim's
    -- default vim.ui handlers and :checkhealth reports "vim.ui.input not set to Snacks.input".
    priority = 1000,
    lazy = false,
    keys = {
      { "<Leader>z", function() require("snacks").zen() end, desc = "Zen mode" },
      { "<Leader>Z", function() require("snacks").zen.zoom() end, desc = "Zen zoom" },
      { "<Leader>bD", function() require("snacks").bufdelete() end, desc = "Delete buffer (keep layout)" },
      { "<Leader>n", function() require("snacks").notifier.show_history() end, desc = "Notification history" },
      { "<Leader>.", function() require("snacks").scratch() end, desc = "Toggle scratch buffer" },
    },
    opts = {
      bigfile = { enabled = true, size = 1.5 * 1024 * 1024 },
      bufdelete = { enabled = true },
      image = { enabled = false }, -- avoid gs/tectonic/kitty health errors
      input = { enabled = true },
      notifier = {
        enabled = true,
        timeout = 3000,
        style = "compact",
      },
      picker = { ui_select = true },
      quickfile = { enabled = true },
      scratch = { enabled = true },
      scroll = { enabled = true },
      words = { enabled = true, debounce = 200 },
      zen = {
        enabled = true,
        win = {
          width = 120,
          backdrop = { transparent = true, blend = 40 },
        },
      },
      dashboard = {
        enabled = #vim.api.nvim_list_uis() > 0,
        preset = {
          header = table.concat({
            " █████  ███████ ████████ ██████   ██████ ",
            "██   ██ ██         ██    ██   ██ ██    ██",
            "███████ ███████    ██    ██████  ██    ██",
            "██   ██      ██    ██    ██   ██ ██    ██",
            "██   ██ ███████    ██    ██   ██  ██████ ",
            "",
            "███    ██ ██    ██ ██ ███    ███",
            "████   ██ ██    ██ ██ ████  ████",
            "██ ██  ██ ██    ██ ██ ██ ████ ██",
            "██  ██ ██  ██  ██  ██ ██  ██  ██",
            "██   ████   ████   ██ ██      ██",
          }, "\n"),
        },
      },
    },
  },

  -- Extend LuaSnip with JS/TS snippets
  {
    "L3MON4D3/LuaSnip",
    dependencies = { "tpope/vim-repeat" },
    config = function(plugin, opts)
      require "astronvim.plugins.configs.luasnip"(plugin, opts)
      local luasnip = require "luasnip"
      luasnip.filetype_extend("javascript", { "javascriptreact" })
      luasnip.filetype_extend("typescript", { "typescriptreact" })
    end,
  },
}
