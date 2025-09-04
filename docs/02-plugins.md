---
title: "Plugin Documentation"
description: "Overview of the plugins used in this Neovim configuration, their purpose, and their configuration."
version: "1.0"
status: "stable"
category: "reference"
updated: "2025-09-04"
authors: ["Alex Torres"]
related: []
---

# Plugin Documentation

This file provides an overview of the plugins used in this Neovim configuration, their purpose, and their configuration.

## Local Plugins

### `binarypeek.lua`

- **Plugin:** `mgastonportillo/binary-peek.nvim`
- **Description:** A plugin to peek into binary files.
- **Status:** Disabled.
- **Configuration:**
  - Loaded on the `VeryLazy` event.
  - Keymaps:
    - `<leader>bs`: Starts BinaryPeek.
    - `<leader>bx`: Aborts BinaryPeek.

### `popurri.lua`

- **Plugin:** `mgastonportillo/popurri.nvim`
- **Description:** A collection of utilities.
- **Status:** Disabled.
- **Configuration:**
  - Loaded on the `Popurri` command.
  - Keymap: `<leader>pp` toggles Popurri.
  - Default query is set to `args`.

## Spec Plugins

### `autopairs.lua`

- **Plugin:** `windwp/nvim-autopairs`
- **Description:** Inserts pairs of brackets, parentheses, quotes, etc. automatically.
- **Configuration:**
  - Loaded on the `InsertEnter` event.

### `better-escape.lua`

- **Plugin:** `max397574/better-escape.nvim`
- **Description:** Provides a better escape sequence from insert mode.
- **Configuration:**
  - Loaded on the `InsertEnter` event.

### `ccc.lua`

- **Plugin:** `uga-rosa/ccc.nvim`
- **Description:** A color picker and converter.
- **Configuration:**
  - Loaded on the `CccPick`, `CccConvert`, or `CccHighlighterToggle` commands.
  - Keymaps:
    - `cc`: Converts color space.
    - `ch`: Toggles the color highlighter.
  - Highlighter is not auto-enabled and uses LSP.

### `cdproject.lua`

- **Plugin:** `LintaoAmons/cd-project.nvim`
- **Description:** Helps to change directory to the project root.
- **Configuration:**
  - Loaded on the `VimEnter` event.
  - Uses Telescope for the project picker.

### `codesnap.lua`

- **Plugin:** `mistricky/codesnap.nvim`
- **Description:** Creates beautiful screenshots of your code.
- **Configuration:**
  - Loaded on the `LspAttach` event.
  - Keymaps:
    - `<leader>cc`: Saves a snapshot of the selected code to the clipboard.
    - `<leader>cs`: Saves a snapshot of the selected code to `~/Pictures`.

### `comment.lua`

- **Plugin:** `numToStr/Comment.nvim`
- **Description:** A commenting plugin that supports line and block comments.
- **Configuration:**
  - Depends on `JoosepAlviste/nvim-ts-context-commentstring`.
  - Keymaps:
    - `<leader>_`: Toggles a block comment in a single line.
    - `<leader>/`: Toggles a line comment.
    - `<leader>/` (visual mode): Toggles a comment with context awareness.

### `crates.lua`

- **Plugin:** `saecki/crates.nvim`
- **Description:** Helps manage crates in `Cargo.toml` files.
- **Configuration:**
  - Loaded when a `Cargo.toml` file is read.
  - Keymap: `<leader>cu` upgrades all crates.

### `dappython.lua`

- **Plugin:** `mfussenegger/nvim-dap-python`
- **Description:** A debug adapter for Python.
- **Configuration:**
  - Loaded on Python files.
  - Depends on `mfussenegger/nvim-dap` and `rcarriga/nvim-dap-ui`.
  - Keymap: `<leader>pdr` runs the Python debugger.

### `dapui.lua`

- **Plugin:** `rcarriga/nvim-dap-ui`
- **Description:** A UI for the debug adapter protocol.
- **Configuration:**
  - Loaded on the `LspAttach` event.
  - Keymaps:
    - `<leader>db`: Toggles a breakpoint.
    - `<leader>dt`: Toggles the DAP UI sidebar.

### `dapvirtualtext.lua`

- **Plugin:** `theHamsta/nvim-dap-virtual-text`
- **Description:** Shows virtual text for debugging.
- **Configuration:**
  - Loaded on the `LspAttach` event.

---

This documentation is auto-generated. For more details, please refer to the individual plugin files.