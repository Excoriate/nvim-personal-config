require("lazy").setup({
  {
    "AstroNvim/AstroNvim",
    version = "^6", -- Pin AstroNvim semver-major v6 for reproducibility (set to nil for nightly)
    import = "astronvim.plugins",
    opts = {
      mapleader = " ",
      maplocalleader = ",",
      icons_enabled = true,
      pin_plugins = nil,
      update_notifications = true,
    },
  },
  { import = "community" },
  { import = "plugins" },
} --[[@as LazySpec]], {
  -- Configure any other `lazy.nvim` configuration options here
  install = { colorscheme = { "kanagawa", "astrotheme", "habamax" } },
  ui = { backdrop = 100 },
  -- Disable luarocks integration; no plugins in this config require it.
  -- Silences ":checkhealth lazy" luarocks/hererocks ERROR rows.
  rocks = { enabled = false },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "zipPlugin",
        "matchit",
        "matchparen",
      },
    },
  },
} --[[@as LazyConfig]])
