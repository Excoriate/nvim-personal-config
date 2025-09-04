# My Neovim Configuration

![License](https://img.shields.io/github/license/alextorresruiz/nvim-personal-config)
![Last Commit](https://img.shields.io/github/last-commit/alextorresruiz/nvim-personal-config)

> My personal Neovim configuration, crafted with Lua, and built on top of NvChad.

## ✨ Features

-   **Plugin Manager:** [lazy.nvim](https://github.com/folke/lazy.nvim)
-   **UI:** [NvChad](https://nvchad.com/) with a custom theme.
-   **LSP:** [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) for language server configuration.
-   **Formatting:** [conform.nvim](https://github.com/stevearc/conform.nvim) with [stylua](https://github.com/JohnnyMorganz/StyLua) for Lua.
-   **And more...**

## 🚀 Getting Started

To use this configuration, clone this repository to your Neovim configuration directory:

```bash
```bash
git clone https://github.com/alextorresruiz/nvim-personal-config.git ~/.config/nvim
```
```

## 📂 Structure

The configuration is organized as follows:

```text
nvchad-config
├── lua
│   ├── autocmds.lua
│   ├── bootstrap.lua
│   ├── chadrc.lua
│   ├── configs
│   │   ├── conform.lua
│   │   ├── lazy.lua
│   │   └── lspconfig.lua
│   ├── gale
│   │   ├── aliases.lua
│   │   ├── autocmds.lua
│   │   ├── chadrc_aux.lua
│   │   ├── filetypes.lua
│   │   ├── globals.lua
│   │   ├── linux.lua
│   │   ├── lsp.lua
│   │   ├── telescope.lua
│   │   ├── types.lua
│   │   ├── usercmds.lua
│   │   ├── utils.lua
│   │   ├── vim.lua
│   │   ├── wezterm.lua
│   │   └── wsl.lua
│   ├── mappings.lua
│   ├── options.lua
│   └── plugins
│       ├── init.lua
│       ├── local
│       └── spec
├── test_lsp_files
└── themes
```

## Plugins

This file provides an overview of the plugins used in this Neovim configuration, their purpose, and their configuration.

### Local Plugins

#### `binarypeek.lua`

- **Plugin:** `mgastonportillo/binary-peek.nvim`
- **Description:** A plugin to peek into binary files.
- **Status:** Disabled.
- **Configuration:**
  - Loaded on the `VeryLazy` event.
  - Keymaps:
    - `<leader>bs`: Starts BinaryPeek.
    - `<leader>bx`: Aborts BinaryPeek.

#### `popurri.lua`

- **Plugin:** `mgastonportillo/popurri.nvim`
- **Description:** A collection of utilities.
- **Status:** Disabled.
- **Configuration:**
  - Loaded on the `Popurri` command.
  - Keymap: `<leader>pp` toggles Popurri.
  - Default query is set to `args`.

### Spec Plugins

#### `autopairs.lua`

- **Plugin:** `windwp/nvim-autopairs`
- **Description:** Inserts pairs of brackets, parentheses, quotes, etc. automatically.
- **Configuration:**
  - Loaded on the `InsertEnter` event.

#### `better-escape.lua`

- **Plugin:** `max397574/better-escape.nvim`
- **Description:** Provides a better escape sequence from insert mode.
- **Configuration:**
  - Loaded on the `InsertEnter` event.

#### `ccc.lua`

- **Plugin:** `uga-rosa/ccc.nvim`
- **Description:** A color picker and converter.
- **Configuration:**
  - Loaded on the `CccPick`, `CccConvert`, or `CccHighlighterToggle` commands.
  - Keymaps:
    - `cc`: Converts color space.
    - `ch`: Toggles the color highlighter.
  - Highlighter is not auto-enabled and uses LSP.

#### `cdproject.lua`

- **Plugin:** `LintaoAmons/cd-project.nvim`
- **Description:** Helps to change directory to the project root.
- **Configuration:**
  - Loaded on the `VimEnter` event.
  - Uses Telescope for the project picker.

#### `codesnap.lua`

- **Plugin:** `mistricky/codesnap.nvim`
- **Description:** Creates beautiful screenshots of your code.
- **Configuration:**
  - Loaded on the `LspAttach` event.
  - Keymaps:
    - `<leader>cc`: Saves a snapshot of the selected code to the clipboard.
    - `<leader>cs`: Saves a snapshot of the selected code to `~/Pictures`.

#### `comment.lua`

- **Plugin:** `numToStr/Comment.nvim`
- **Description:** A commenting plugin that supports line and block comments.
- **Configuration:**
  - Depends on `JoosepAlviste/nvim-ts-context-commentstring`.
  - Keymaps:
    - `<leader>_`: Toggles a block comment in a single line.
    - `<leader>/`: Toggles a line comment.
    - `<leader>/` (visual mode): Toggles a comment with context awareness.

#### `crates.lua`

- **Plugin:** `saecki/crates.nvim`
- **Description:** Helps manage crates in `Cargo.toml` files.
- **Configuration:**
  - Loaded when a `Cargo.toml` file is read.
  - Keymap: `<leader>cu` upgrades all crates.

#### `dappython.lua`

- **Plugin:** `mfussenegger/nvim-dap-python`
- **Description:** A debug adapter for Python.
- **Configuration:**
  - Loaded on Python files.
  - Depends on `mfussenegger/nvim-dap` and `rcarriga/nvim-dap-ui`.
  - Keymap: `<leader>pdr` runs the Python debugger.

#### `dapui.lua`

- **Plugin:** `rcarriga/nvim-dap-ui`
- **Description:** A UI for the debug adapter protocol.
- **Configuration:**
  - Loaded on the `LspAttach` event.
  - Keymaps:
    - `<leader>db`: Toggles a breakpoint.
    - `<leader>dt`: Toggles the DAP UI sidebar.

#### `dapvirtualtext.lua`

- **Plugin:** `theHamsta/nvim-dap-virtual-text`
- **Description:** Shows virtual text for debugging.
- **Configuration:**
  - Loaded on the `LspAttach` event.

## Custom Configurations

This file documents the custom configurations found in the `lua/gale/` directory.

### `aliases.lua`

- **Purpose:** Defines custom command aliases.
- **Configuration:**
  - `tcdp`: Alias for `CdProjectTab`.
  - Workarounds for common typos: `qa` for `Qa`, `q` for `Q`, etc.

### `autocmds.lua`

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

### `chadrc_aux.lua`

- **Purpose:** Provides auxiliary configurations for `chadrc`.
- **Configuration:**
  - Custom theme highlight overrides for `bearded-arc` and `eldritch` themes.
  - Custom status line modules for Harpoon, Git, LSP, and word count.

### `filetypes.lua`

- **Purpose:** Defines custom filetype associations.
- **Configuration:**
  - Associates `.jsonl` files with the `json` filetype.
  - Unattaches `jsonls` from `.jsonl` buffers.

### `globals.lua`

- **Purpose:** Defines global functions and variables.
- **Configuration:**
  - `_G.__toggle_contextual`: A function to toggle comments with context awareness.
  - `_G.switch`: A switch/case function.

### `linux.lua`

- **Purpose:** Provides Linux-specific configurations.
- **Configuration:**
  - Sets up the clipboard for Linux systems, attempting to install `xclip` if not found.

### `lsp.lua`

- **Purpose:** Provides custom LSP configurations.
- **Configuration:**
  - A custom `on_attach` function with keymaps for various LSP actions.
  - A function to generate a new `on_attach` function that combines the default and custom behaviors.
  - Disables semantic tokens if the client supports them.
  - Custom LSP capabilities.
  - Inlay hint settings for `vtsls`.

### `telescope.lua`

- **Purpose:** Provides custom Telescope pickers.
- **Configuration:**
  - Custom pickers for files, grep, and buffers with a custom layout and entry maker.

### `types.lua`

- **Purpose:** Defines types for `lazydev.nvim`.
- **Configuration:**
  - Adds `luvit-meta`, `nvchad_types`, and `wezterm-types` to the library.

### `usercmds.lua`

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

### `utils.lua`

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

### `vim.lua`

- **Purpose:** Defines custom Vim functions.
- **Configuration:**
  - `LspHealthCheck`: A wrapper around `LspInfo`.
  - `RunNeogit`: A wrapper to open Neogit.
  - `RunHarpoon`: A wrapper to open the Harpoon menu.
  - `OilDirCWD`: A wrapper to open Oil in the current working directory.

### `wezterm.lua`

- **Purpose:** Provides WezTerm-specific configurations.
- **Configuration:**
  - Loads `wezterm-types` if the terminal is WezTerm.

### `wsl.lua`

- **Purpose:** Provides WSL-specific configurations.
- **Configuration:**
  - Sets up the clipboard for WSL.

## 🤝 Contributing

As this is a personal configuration, I am not actively seeking contributions. However, if you have any suggestions or find any issues, feel free to open an issue.

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Credits

-   [Neovim](https://neovim.io/)
-   [Lua](https://www.lua.org/)
-   [NvChad](https://nvchad.com/)
-   ... and all the amazing plugin authors!
