---
title: "Gale Custom Configurations"
description: "Documentation for custom configurations in the lua/gale/ directory."
version: "1.0"
status: "stable"
category: "reference"
updated: "2025-09-04"
authors: ["Alex Torres"]
related: []
---

# Gale Custom Configurations

This file documents the custom configurations found in the `lua/gale/` directory.

## `aliases.lua`

- **Purpose:** Defines custom command aliases.
- **Configuration:**
  - `tcdp`: Alias for `CdProjectTab`.
  - Workarounds for common typos: `qa` for `Qa`, `q` for `Q`, etc.

## `autocmds.lua`

- **Purpose:** Defines custom autocommands for various events.
- **Configuration:**
  - Unattaches `vtsls` if `denols` is detected for the buffer.
  - Sets a custom `conceallevel` for Markdown files.
  - Redraws the status line when an LSP attaches.
  - Prevents `<Tab>` and `<S-Tab>` from switching buffers in certain filetypes.
  - Fixes the `z-index` for `NvCheatsheet`.
  - Prevents auto-commenting on new lines.
  - Adds support for `.mdx` files.
  - Auto-resizes panes when the Neovim window is resized.
  - Highlights the yanked text on yank.
  - Disables diagnostics in insert and visual modes, and in `node_modules`.
  - Removes trailing whitespaces on save.
  - Defines windows to be closed with `q`.
  - Prevents weird snippet jumping behavior.
  - Automatically updates changed files.
  - Shows a notification on file change.
  - Enables line numbers in the Telescope previewer.
  - Prevents the left mouse click from exiting insert mode in terminal buffers.

## `chadrc_aux.lua`

- **Purpose:** Provides auxiliary configurations for `chadrc`.
- **Configuration:**
  - Custom theme highlight overrides for `bearded-arc` and `eldritch` themes.
  - Custom status line modules for Harpoon, Git, LSP, and word count.

## `filetypes.lua`

- **Purpose:** Defines custom filetype associations.
- **Configuration:**
  - Associates `.jsonl` files with the `json` filetype.
  - Unattaches `jsonls` from `.jsonl` buffers.

## `globals.lua`

- **Purpose:** Defines global functions and variables.
- **Configuration:**
  - `_G.__toggle_contextual`: A function to toggle comments with context awareness.
  - `_G.switch`: A switch/case function.

## `linux.lua`

- **Purpose:** Provides Linux-specific configurations.
- **Configuration:**
  - Sets up the clipboard for Linux systems, attempting to install `xclip` if not found.

## `lsp.lua`

- **Purpose:** Provides custom LSP configurations.
- **Configuration:**
  - A custom `on_attach` function with keymaps for various LSP actions.
  - A function to generate a new `on_attach` function that combines the default and custom behaviors.
  - Disables semantic tokens if the client supports them.
  - Custom LSP capabilities.
  - Inlay hint settings for `vtsls`.

## `telescope.lua`

- **Purpose:** Provides custom Telescope pickers.
- **Configuration:**
  - Custom pickers for files, grep, and buffers with a custom layout and entry maker.

## `types.lua`

- **Purpose:** Defines types for `lazydev.nvim`.
- **Configuration:**
  - Adds `luvit-meta`, `nvchad_types`, and `wezterm-types` to the library.

## `usercmds.lua`

- **Purpose:** Defines custom user commands.
- **Configuration:**
  - `CombineLists`/`MergeLists`: Combines two lists separated by an empty line.
  - `WipeReg`: Clears all registers.
  - `ToggleWordCount`: Toggles the word count mode between line and buffer.
  - `TabuflineToggle`: Toggles the visibility of the tabufline.
  - `SrcPlugins`: Updates the plugin imports.
  - `SrcFile`: Sources the current file.
  - `TabbyStart`/`TabbyStop`: Starts and stops the TabbyML docker container.
  - `ToggleInlayHints`: Toggles inlay hints in the current buffer.
  - `DiagnosticsVirtualTextToggle`: Toggles inline diagnostics.
  - `DiagnosticsToggle`: Toggles diagnostics.
  - `DapUIToggle`: Toggles the DAP UI.
  - `UpdateAll`: Batch updates Mason, Treesitter, and Lazy.
  - `FormatToggle`: Toggles format on save.
  - `FormatFile`: Formats the current file.
  - `FormatProject`: Formats the entire project.
  - `VerifyLSP`: Verifies the LSP configuration.

## `utils.lua`

- **Purpose:** Provides utility functions.
- **Configuration:**
  - `add_alias`: Adds a command alias.
  - `is_tbl`: Checks if a value is a table.
  - `glb_map`/`buf_map`: Creates global and buffer-local keymaps.
  - `del_map`: Deletes a keymap.
  - `toggle_inspect_tree`: Toggles the Treesitter inspection tree.
  - `go_to_github_link`: Opens the GitHub link for the plugin under the cursor.
  - `format_file`: Formats a file using `conform`.
  - `code_action_listener`: A listener for code actions.
  - `handle_copy`/`handle_paste`: Functions to handle copy and paste.
  - `menus`: A table of menus.
  - `word_iterator`/`count_with_exclude`/`count_words_in_line`/`count_words_in_buffer`: Word counting utilities.
  - `clear_registers`: Clears all registers.
  - `harpoon_menu`: Toggles the Harpoon menu.
  - `debounce`: Debounces a function.
  - `combine_lists`: Combines two lists.

## `vim.lua`

- **Purpose:** Defines custom Vim functions.
- **Configuration:**
  - `LspHealthCheck`: A wrapper around `LspInfo`.
  - `RunNeogit`: A wrapper to open Neogit.
  - `RunHarpoon`: A wrapper to open the Harpoon menu.
  - `OilDirCWD`: A wrapper to open Oil in the current working directory.

## `wezterm.lua`

- **Purpose:** Provides WezTerm-specific configurations.
- **Configuration:**
  - Loads `wezterm-types` if the terminal is WezTerm.

## `wsl.lua`

- **Purpose:** Provides WSL-specific configurations.
- **Configuration:**
  - Sets up the clipboard for WSL.

---

This documentation is auto-generated. For more details, please refer to the individual configuration files.