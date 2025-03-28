-- https://b4.docs.kernel.org/en/latest/contributor/overview.html
local opts = { noremap = true }
opts.desc = "b4 prep --enroll"
vim.keymap.set("n", "<Leader>bn", ":!b4 prep --enroll<CR>", opts)
opts.desc = "b4 prep --edit-cover"
vim.keymap.set("n", "<Leader>be", edit_cover, opts)
opts.desc = "b4 prep --auto-to-cc; b4 trailers --update; b4 prep --check"
vim.keymap.set("n", "<Leader>bc", ":!b4 prep --auto-to-cc<CR>:B4UpdateTrailers<CR>:!b4 prep --check<CR>", opts)
opts.desc = "b4 send --reflect"
vim.keymap.set("n", "<Leader>bs", ":B4Send --reflect", opts)
opts.desc = "b4 shazam"
vim.keymap.set("n", "<Leader>ba", ":!b4 shazam ", opts)
