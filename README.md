# b4.nvim

This is a simple wrapper around [b4](https://b4.docs.kernel.org/), so you don't have to
leave neovim to use it. It creates the `:B4` command which runs `b4` in a terminal
inside neovim. The `:B4 prep --edit-cover` and `:B4 prep --edit-deps` commands create a
buffer with the relevant content instead.

NOTE: For now, only the [branch-description](https://b4.docs.kernel.org/en/latest/contributor/prep.html) strategy is supported.

## Installation

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
return {
  "rbmarliere/b4.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  cmd = { "B4" },
  opts = {
    log_level = "info",
    window = {
      new_tab = false, -- the B4 windows are created as new tabs
      layout = {       -- otherwise, "layout" is passed down to nvim_open_win()
        split = "below",
      },
    },
  },
  -- Suggested mappings
  keys = {
    {
      "<Leader>bc",
      ":B4 prep --auto-to-cc<CR>:B4 prep --check<CR>:B4 prep --check-deps<CR>:B4 trailers --update<CR>",
      desc = "b4 prep --auto-to-cc; b4 prep --check; b4 prep --check-deps; b4 trailers --update",
    },
    { "<Leader>bpc", ":B4 prep --edit-cover<CR>", desc = "b4 prep --edit-cover" },
    { "<Leader>bpd", ":B4 prep --edit-deps<CR>", desc = "b4 prep --edit-deps" },
    { "<Leader>bpe", ":B4 prep --enroll<CR>", desc = "b4 prep --enroll" },
    { "<Leader>bs", ":B4 send --reflect", desc = "b4 send --reflect" },
    { "<Leader>bS", ":B4 shazam ", desc = "b4 shazam" },
  },
}
```
