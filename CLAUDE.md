# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a sophisticated NeoVim personal configuration repository built on top of NvChad v2.5, featuring advanced modularity and comprehensive development tooling. The configuration demonstrates enterprise-level practices applied to personal development environments.

## Architecture

### Core Structure

The repository follows a **modular, layered architecture** with clear separation of concerns:

```text
nvchad-config/
├── lua/
│   ├── gale/               # Custom module namespace (domain-driven design)
│   │   ├── autocmds.lua    # Event-driven automation (6400 bytes)
│   │   ├── utils.lua       # Utility functions (10801 bytes)
│   │   ├── lsp.lua         # LSP customizations
│   │   ├── telescope.lua   # Custom telescope pickers
│   │   └── [platform]/    # Platform-specific configs (linux.lua, wsl.lua, wezterm.lua)
│   ├── plugins/
│   │   ├── local/          # Experimental/disabled plugins
│   │   └── spec/           # Production-ready plugin configurations (64 plugins)
│   └── [core configs]      # chadrc.lua, options.lua, mappings.lua
├── scripts/                # Development automation tools
└── .cursor/rules/          # Development standards enforcement (10 rules)
```

### Key Architectural Patterns

1. **Configuration as Code**: All settings managed through Lua modules
2. **Lazy Loading Strategy**: Plugins load on specific events/commands for performance
3. **Override Pattern**: Extends NvChad base functionality rather than replacing it
4. **Domain-Driven Modularity**: `gale/` namespace organizes functionality by platform and feature domains
5. **Three-Tier Plugin System**: local → spec → production with automated import generation

## Development Commands

### Essential Commands

```bash
# Lua formatting (REQUIRED before commits)
stylua --check .                    # Verify compliance
stylua .                           # Auto-format all files

# Plugin management
:SrcPlugins                        # Update plugin imports (after adding new plugins)
:UpdateAll                         # Batch update Mason, Treesitter, and Lazy

# Development utilities
:VerifyLSP                         # Verify LSP configuration
:FormatProject                     # Format entire project
:WipeReg                          # Clear all registers

# Debug and inspection
:ToggleInlayHints                 # Toggle LSP inlay hints
:DiagnosticsToggle                # Toggle diagnostics display
```

### Script Automation

```bash
# From repository root
lua scripts/update-lazy-imports.lua    # Generate plugin imports
lua scripts/grep_runtimepath.lua       # Debug runtime path issues
```

## Code Standards

### File Organization

**Cursor Rules**: All cursor rules MUST be in `.cursor/rules/` using kebab-case: `[rule-name].mdc`

**Documentation Structure**:
- Directories: `NN_description` format (e.g., `00_context_engineering`)
- Files: `NN-description.md` format with zero-padded numbers
- ALL documentation requires YAML frontmatter with: `title`, `description`, `version`, `status`, `category`, `updated`, `authors`

**Plugin Organization**:
- New experimental plugins: `plugins/local/[plugin].lua`
- Stable plugins: `plugins/spec/[plugin].lua`
- Run `:SrcPlugins` after adding new plugin files

### Formatting Requirements

**Lua Code** (MANDATORY - verified by StyLua):
- 120 character line limit, 2-space indentation
- Prefer double quotes, omit parentheses for single arguments: `require "module"`
- MUST pass `stylua --check .` validation before commits

**Shell Scripts** (MANDATORY - verified by ShellCheck):
- Use `#!/bin/bash` shebang and Google Shell Style Guide
- 2-space indentation, `function name() {` format
- Always quote variables: `"${variable}"`, use braces: `${var}`
- Include `set -euo pipefail` for error handling

**Markdown**:
- Always specify language for code blocks
- Use proper header hierarchy with hash symbols (never bold/italic for headers)
- Include blank lines between sections and around code blocks
- Use relative paths for cross-document references

### Development Workflow

**Task Management**: For any multi-step task (2+ actions), create structured todo lists using TodoWrite tool before implementation. Mark completed items immediately.

**Quality Gates**:
1. All code must pass respective linters (StyLua, ShellCheck, markdownlint)
2. Plugin configurations must follow established patterns in existing spec files
3. Custom functionality should extend `gale/` namespace modules appropriately
4. Test changes with `:checkhealth` and relevant LSP verification commands

## Project Context

### Plugin Management Philosophy

This configuration uses a **three-tier plugin system**:
1. **Local plugins** (`plugins/local/`): Experimental, often disabled plugins for testing
2. **Spec plugins** (`plugins/spec/`): 64 production-ready, actively used plugins
3. **Automated imports**: `scripts/update-lazy-imports.lua` maintains the import list in `plugins/init.lua`

### Custom Module System

The `gale/` namespace provides domain-specific functionality:
- **Platform modules**: `linux.lua`, `wsl.lua`, `wezterm.lua` for environment-specific configs  
- **Feature modules**: `lsp.lua`, `telescope.lua` for enhanced functionality
- **Utility modules**: `utils.lua` (10801 bytes), `globals.lua` for cross-cutting concerns
- **Automation**: `autocmds.lua` (6400 bytes) for extensive event-driven behavior

### UI Customization

- Base theme: NvChad with custom themes in `themes/` directory
- Custom statusline modules for Harpoon, Git status, LSP info, word count
- Transparency-aware design with theme-specific customizations
- Custom modules in `gale/chadrc_aux.lua` for advanced UI composition

## Important Notes

- This is a **personal configuration** - contributing guidelines should respect the personal nature while maintaining code quality
- The configuration includes platform-specific modules for Linux, WSL, and WezTerm environments
- Extensive automation through autocommands handles LSP integration, file management, and user experience enhancements
- All cursor rules in `.cursor/rules/` are actively enforced and should be consulted for detailed standards
- Plugin specifications demonstrate lazy loading best practices with event-driven loading and careful dependency management