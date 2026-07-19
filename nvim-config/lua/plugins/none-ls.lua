return {
  {
    "nvimtools/none-ls.nvim",
    enabled = true,
  },
  {
    "jay-babu/mason-null-ls.nvim",
    opts = function(_, opts)
      opts.handlers = opts.handlers or {}
      opts.handlers.vale = function()
        local null_ls = require "null-ls"
        null_ls.register(null_ls.builtins.diagnostics.vale.with {
          condition = function(utils) return utils.root_has_file ".vale.ini" end,
        })
      end
    end,
  },
}
