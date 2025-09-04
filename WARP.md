# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Repository Overview

This is a personal Neovim configuration repository built with Lua. The repository is currently in a template/starter state with robust tooling infrastructure in place, ready for actual configuration development.

## Development Commands

### Code Formatting
```bashbash
# Format all Lua files using StyLua
stylua .

# Check formatting without making changes
stylua --check .

# Format specific file
stylua path/to/file.lua
```

### CI/Testing
```bashbash
# Run the same formatting check as CI
stylua --check .

# The CI pipeline runs automatically on push/PR to main branch
```

### Script Utilities
```bashbash
# Run the lazy import generator script (when plugin structure exists)
nvim --headless -c "luafile scripts/update-lazy-imports.lua" -c "qa"

# Run the runtime path grep utility (for debugging Neovim paths)
nvim --headless -c "luafile scripts/grep_runtimepath.lua" -c "qa"
```

## Architecture & Structure

### Current State
The repository follows a standard Neovim configuration structure but is currently empty of actual configuration files:

```text
├── lua/
│   ├── core/       # Core settings (planned)
│   ├── plugins/    # Plugin configurations (planned) 
│   └── utils/      # Utility functions (planned)
├── init.lua        # Entry point (planned)
└── scripts/        # Development utilities (exists)
```

### Plugin Management Strategy
Based on the utility scripts, this configuration is designed to use:
- **lazy.nvim** as the plugin manager (evidenced by `lazy-lock.json` in .gitignore)
- Modular plugin organization in `lua/plugins/` subdirectories:
  - `lua/plugins/local/` - Local plugin configurations
  - `lua/plugins/spec/` - Plugin specifications  
  - `lua/plugins/override/` - Plugin overrides
- Automatic import generation via `scripts/update-lazy-imports.lua`

### Development Utilities

#### Import Generator (`scripts/update-lazy-imports.lua`)
- Automatically generates `lua/plugins/init.lua` with imports from plugin subdirectories
- Scans `local/`, `spec/`, and `override/` directories
- Creates lazy.nvim-compatible import statements
- Reverses import order for proper loading sequence

#### Runtime Path Grep (`scripts/grep_runtimepath.lua`)  
- Searches across all Neovim runtime paths for specific terms
- Uses ripgrep (`rg`) for fast searching
- Populates quickfix list with results
- Useful for debugging plugin conflicts or finding configuration locations

### Code Quality Standards

#### StyLua Configuration (`.stylua.toml`)
```tomltoml
column_width = 120
line_endings = "Unix"
indent_type = "Spaces" 
indent_width = 2
quote_style = "AutoPreferDouble"
call_parentheses = "None"
```

#### VS Code Integration
- Configured for Neovim/Lua development in `.vscode/settings.json`
- Auto-formatting on save with StyLua
- Lua language server configuration with Neovim globals
- Proper file associations and workspace settings

## Installation & Setup

### Initial Installation
```bashbash
# Clone to Neovim config directory
git clone https://github.com/alextorresruiz/nvim-personal-config.git ~/.config/nvim

# Or clone elsewhere and symlink
git clone https://github.com/alextorresruiz/nvim-personal-config.git ~/nvim-config
ln -s ~/nvim-config ~/.config/nvim
```

### Development Setup
1. Ensure StyLua is installed for formatting
2. Configure VS Code with the provided settings for optimal development experience
3. Use the utility scripts when developing plugin configurations

## Important Files to Understand

- **`.gitignore`**: Excludes lazy.nvim lock file, packer compiled files, and backup files
- **`scripts/update-lazy-imports.lua`**: Core utility for managing plugin imports
- **`.stylua.toml`**: Code formatting rules matching the project style
- **`.vscode/settings.json`**: Complete VS Code setup for Neovim Lua development

## Security Considerations

- Environment files (`.env`) are ignored by git
- No sensitive configuration should be committed
- Plugin lock files are ignored to avoid conflicts between different systems

## CI/CD Pipeline

The repository uses GitHub Actions for:
- **Lua formatting check**: Ensures all Lua code follows StyLua standards
- **Automated on**: Push and pull requests to main branch
- **Blocking**: PRs cannot merge if formatting check fails

## Next Steps for Development

When ready to build the actual configuration:
1. Create `init.lua` as the main entry point
2. Build out the `lua/core/` directory with base Neovim settings
3. Add plugin configurations in the modular `lua/plugins/` structure
4. Use `scripts/update-lazy-imports.lua` to maintain clean imports
5. Follow the established code style and formatting standards
