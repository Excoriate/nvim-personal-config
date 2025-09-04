-- LSP Verification Script
-- Run this with :luafile test_lsp_files/verify_lsp.lua

local M = {}

-- Function to check if a language server is attached
function M.check_lsp_status()
  local clients = vim.lsp.get_clients()
  if #clients == 0 then
    print "❌ No LSP clients attached"
    return false
  end

  print "✅ LSP Status:"
  for _, client in ipairs(clients) do
    print(string.format("  - %s (id: %d)", client.name, client.id))
  end
  return true
end

-- Function to test autocompletion capabilities
function M.check_completion()
  local ok, cmp = pcall(require, "cmp")
  if not ok then
    print "❌ nvim-cmp not available"
    return false
  end

  print "✅ Autocompletion:"
  print "  - nvim-cmp is loaded"

  local sources = cmp.get_config().sources
  if sources and #sources > 0 then
    print "  - Completion sources configured:"
    for _, source in ipairs(sources) do
      if source.name then
        print(string.format("    • %s", source.name))
      end
    end
  end

  return true
end

-- Function to test LSP features for current buffer
function M.test_current_buffer()
  local filetype = vim.bo.filetype
  print(string.format("📄 Testing buffer: %s (filetype: %s)", vim.fn.expand "%:t", filetype))

  local clients = vim.lsp.get_clients { bufnr = 0 }
  if #clients == 0 then
    print "❌ No LSP client attached to current buffer"
    return false
  end

  print "✅ LSP Features available:"
  local client = clients[1]

  -- Check server capabilities
  local capabilities = client.server_capabilities
  if capabilities.completionProvider then
    print "  ✅ Autocompletion"
  end
  if capabilities.hoverProvider then
    print "  ✅ Hover information (K key)"
  end
  if capabilities.definitionProvider then
    print "  ✅ Go to definition (gd key)"
  end
  if capabilities.referencesProvider then
    print "  ✅ Find references"
  end
  if capabilities.documentFormattingProvider then
    print "  ✅ Document formatting"
  end
  if capabilities.codeActionProvider then
    print "  ✅ Code actions"
  end
  if capabilities.renameProvider then
    print "  ✅ Symbol renaming"
  end

  -- Language-specific checks
  if filetype == "go" and client.name == "gopls" then
    print "  ✅ Go-specific: gofumpt, inlay hints, code lenses"
  elseif filetype == "python" and client.name == "pyright" then
    print "  ✅ Python-specific: type checking, import resolution"
  elseif filetype == "typescript" and client.name == "ts_ls" then
    print "  ✅ TypeScript-specific: inlay hints, type checking"
  elseif filetype == "rust" and client.name == "rust-analyzer" then
    print "  ✅ Rust-specific: macro expansion, trait resolution"
  end

  return true
end

-- Function to run all verifications
function M.run_all_checks()
  print "🔍 LSP Configuration Verification"
  print "================================"

  M.check_lsp_status()
  print()
  M.check_completion()
  print()
  M.test_current_buffer()
  print()

  print "📋 Quick Test Instructions:"
  print "1. Open test files: :edit test_lsp_files/test.go"
  print "2. Test autocompletion: Type 'fmt.' and press <Tab> or <C-Space>"
  print "3. Test hover: Place cursor on a function and press 'K'"
  print "4. Test go-to-definition: Place cursor on a function and press 'gd'"
  print "5. Test diagnostics: Look for error/warning highlights"
  print "6. Test code actions: Press <leader>ca on highlighted code"
  print()
  print "🎯 Language Server Requirements:"
  print "- Go: gopls (install: go install golang.org/x/tools/gopls@latest)"
  print "- Python: pyright (install: npm install -g pyright)"
  print "- TypeScript: ts_ls (install: npm install -g typescript-language-server)"
  print "- Rust: rust-analyzer (install: rustup component add rust-analyzer)"
  print()
  print "📦 Auto-install with Mason: :Mason"
end

-- Make functions available globally for easy access
_G.verify_lsp = M

-- Auto-run if this file is sourced
M.run_all_checks()

return M
