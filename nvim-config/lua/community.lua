-- AstroCommunity: import any community modules here
-- We import this file in `lazy_setup.lua` before the `plugins/` folder.
-- This guarantees that the specs are processed before any user plugins.

---@type LazySpec
return {
  "AstroNvim/astrocommunity",

  -- Language Packs (includes LSP, treesitter, formatters, linters)
  { import = "astrocommunity.pack.lua" },
  { import = "astrocommunity.pack.go" },
  { import = "astrocommunity.pack.rust" },
  { import = "astrocommunity.pack.typescript" },
  -- Python: split across base (debug/venv/neotest) + basedpyright (LSP) + ruff (linter/formatter).
  -- Replaces the deprecated `astrocommunity.pack.python-ruff` aggregate.
  { import = "astrocommunity.pack.python.base" },
  { import = "astrocommunity.pack.python.basedpyright" },
  { import = "astrocommunity.pack.python.ruff" },
  { import = "astrocommunity.pack.terraform" },
  { import = "astrocommunity.pack.yaml" },
  { import = "astrocommunity.pack.docker" },
  { import = "astrocommunity.pack.helm" },
  { import = "astrocommunity.pack.bash" },
  { import = "astrocommunity.pack.json" },
  { import = "astrocommunity.pack.toml" },
  { import = "astrocommunity.pack.markdown" },
  { import = "astrocommunity.pack.just" }, -- Justfile support

  -- Editing enhancements
  { import = "astrocommunity.editing-support.rainbow-delimiters-nvim" },
  { import = "astrocommunity.editing-support.todo-comments-nvim" },

  -- Git integration: gitsigns (AstroNvim default) provides inline blame via
  -- `current_line_blame`; vim-fugitive (in plugins/user.lua) handles power-user `:Git` ops.

  -- Motion
  { import = "astrocommunity.motion.flash-nvim" },

  -- Diagnostics
  { import = "astrocommunity.diagnostics.trouble-nvim" },
  { import = "astrocommunity.colorscheme.tokyonight-nvim" },

  -- Note: kanagawa colorscheme configured in plugins/user.lua with custom opts
}
