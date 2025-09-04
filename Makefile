#!/usr/bin/env make

# Neovim Configuration - Development Makefile
# This Makefile ensures consistent Lua formatting and linting
# using the same tools as the CI workflow (.github/workflows/ci.yml)

# Variables
LUA_DIR := nvchad-config
STYLUA_CONFIG := .stylua.toml
LUA_VERSION := 5.4

# Ensure stylua is installed
.PHONY: check-stylua
check-stylua:
	@which stylua > /dev/null || { \
		echo "❌ stylua not found. Install it with:"; \
		echo "   cargo install stylua"; \
		echo "   # or brew install stylua"; \
		echo "   # or download from https://github.com/JohnnyMorganz/StyLua/releases"; \
		exit 1; \
	}

# Ensure lua is available for syntax checking
.PHONY: check-lua
check-lua:
	@which lua$(LUA_VERSION) > /dev/null || which lua > /dev/null || { \
		echo "❌ Lua not found. Install it with:"; \
		echo "   # Ubuntu/Debian: sudo apt-get install lua$(LUA_VERSION)"; \
		echo "   # macOS: brew install lua"; \
		exit 1; \
	}

# Format all Lua files using stylua with .stylua.toml config
.PHONY: format
format: check-stylua
	@echo "🔧 Formatting Lua files with stylua..."
	@stylua $(LUA_DIR)/
	@echo "✅ Formatting complete!"

# Check if files need formatting (same as CI workflow)
.PHONY: format-check  
format-check: check-stylua
	@echo "🔍 Checking Lua file formatting..."
	@stylua --check $(LUA_DIR)/ || { \
		echo "❌ Formatting issues found. Run 'make format' to fix them."; \
		exit 1; \
	}
	@echo "✅ All files are properly formatted!"

# Validate Lua syntax (same as CI workflow)
.PHONY: lint
lint: check-lua
	@echo "🔍 Checking Lua syntax..."
	@LUA_CMD=$$(which lua$(LUA_VERSION) 2>/dev/null || which lua); \
	find $(LUA_DIR)/ -name "*.lua" -print0 | while IFS= read -r -d '' file; do \
		echo "  Checking: $$file"; \
		$$LUA_CMD -l "$$file" 2>&1 || { \
			echo "❌ Syntax error in: $$file"; \
			exit 1; \
		}; \
	done
	@echo "✅ All Lua files have valid syntax!"

# Run all checks (format check + syntax validation) 
.PHONY: check
check: format-check lint
	@echo "✅ All checks passed!"

# Fix formatting and validate everything
.PHONY: fix
fix: format lint
	@echo "✅ Files formatted and validated!"

# CI simulation - exactly what the workflow does
.PHONY: ci
ci: check
	@echo "✅ CI checks passed! Ready for commit."

# Show help
.PHONY: help
help:
	@echo "📋 Available commands:"
	@echo ""
	@echo "  make format        - Format all Lua files using stylua"
	@echo "  make format-check  - Check if files need formatting (CI check)"
	@echo "  make lint          - Validate Lua syntax (CI check)" 
	@echo "  make check         - Run all checks (format-check + lint)"
	@echo "  make fix           - Fix formatting and validate syntax"
	@echo "  make ci            - Simulate CI workflow checks"
	@echo "  make help          - Show this help message"
	@echo ""
	@echo "🔧 Requirements:"
	@echo "  - stylua (cargo install stylua)"
	@echo "  - lua$(LUA_VERSION) or lua"
	@echo ""
	@echo "📄 Configuration:"
	@echo "  - Stylua config: $(STYLUA_CONFIG)"
	@echo "  - Target directory: $(LUA_DIR)/"

# Default target
.DEFAULT_GOAL := help