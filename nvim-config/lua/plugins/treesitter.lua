-- nvim-treesitter override: explicit parser allowlist + disable auto-install.
--
-- WHY this is here (was disabled by stock AstroNvim template):
--   nvim-treesitter `main` branch (used by AstroNvim v6) auto-installs parsers on
--   filetype open. The installer hardcodes `mv tree-sitter-X-tmp/tree-sitter-X-master`
--   which fails for parsers whose upstream repo default branch renamed master->main
--   (e.g., `gitignore` from shunsambongi/tree-sitter-gitignore). Failure surfaces as
--   a red `mv: No such file or directory` modal blocking the user's :messages.
--
-- Strategy:
--   - auto_install = false  : no surprise installs on filetype open
--   - ensure_installed = {} : explicit list of parsers we actually need
--   - ignore_install        : defensive deny-list for known-broken upstreams
--
-- Adding a parser later: append to ensure_installed and run :TSUpdate <name>.

---@type LazySpec
return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    auto_install = false,
    ensure_installed = {
      -- The DevOps stack the user works with daily.
      "bash",
      "c",
      "comment",
      "css",
      "diff",
      "dockerfile",
      "git_config",
      "git_rebase",
      "gitattributes",
      "gitcommit",
      "go",
      "gomod",
      "gosum",
      "gowork",
      "hcl",
      "helm",
      "html",
      "javascript",
      "jsdoc",
      "json",
      "json5",
      "jsonc",
      "just",
      "lua",
      "luadoc",
      "luap",
      "make",
      "markdown",
      "markdown_inline",
      "python",
      "query",
      "regex",
      "rust",
      "sql",
      "terraform",
      "toml",
      "tsx",
      "typescript",
      "vim",
      "vimdoc",
      "yaml",
    },
    ignore_install = {
      -- Known-broken auto-install on nvim-treesitter `main` branch (upstream repo
      -- default-branch rename master->main; installer's `mv ...-master` fails).
      "gitignore",
    },
    highlight = { enable = true },
    indent = { enable = true },
  },
}
