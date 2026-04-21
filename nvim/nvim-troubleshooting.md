# Troubleshooting Notes for Neovim Setup

- Check generate health of Neovim setup. `:checkhealth`
- Update Treesitter. `:TSUpdate`
- Check LSP installation. `:Mason`
- Fix broken icons
  - Download [nerdfix](https://github.com/loichyan/nerdfix) binary and unpack in home directory.
  - Run `nerdfix check <path/to/file>` to check broken icons in a file
  - Run `nerdfix fix <path/to/file>` to fix broken icons in a file

## Neovim 0.12.1 Notes

- Config uses `vim.uv` (replaces deprecated `vim.loop`)
- `vim.diagnostic.config()` signs are configured via the modern `text` table (legacy `sign_define` removed)
- `completeopt` includes `popup` for LSP completion item previews
- Diagnostic toggle uses the current `vim.diagnostic.enable(enable)` API
- Built-in LSP mappings: `grt` → type definition, `grx` → run codelens
- `:checkhealth vim.lsp` available to inspect active LSP features per buffer
