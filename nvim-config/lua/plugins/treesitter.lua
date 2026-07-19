---@type LazySpec
return {
  "AstroNvim/astrocore",
  opts = function(_, opts)
    vim.treesitter.language.register("json", "jsonc")
    vim.treesitter.language.register("javascript", "javascriptreact")
    vim.treesitter.language.register("tsx", "typescriptreact")
    vim.treesitter.language.register("terraform", "terraform-vars")
    vim.treesitter.language.register("yaml", {
      "yaml.azure-pipelines",
      "yaml.cloudformation",
      "yaml.docker-compose",
      "yaml.helm",
      "yaml.kubernetes",
      "yaml.taskfile",
    })
    opts.treesitter = opts.treesitter or {}
    opts.treesitter.auto_install = false
    opts.treesitter.ensure_installed = {
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
    }
  end,
}
