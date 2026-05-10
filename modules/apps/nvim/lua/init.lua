local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = false
opt.smartindent = true
opt.wrap = false
opt.ignorecase = true
opt.smartcase = true
opt.termguicolors = true
opt.scrolloff = 8
opt.signcolumn = "yes"
opt.updatetime = 50
opt.cursorline = true
opt.splitright = true
opt.splitbelow = true
opt.colorcolumn = "80"

vim.g.mapleader = " "
vim.g.maplocalleader = " "

local map = function(mode, lhs, rhs, opts)
  opts = opts or {}
  opts.silent = opts.silent ~= false
  vim.keymap.set(mode, lhs, rhs, opts)
end

map("n", "<leader>e", "<cmd>Oil<CR>", { desc = "Open Oil file manager" })
map("n", "<leader>ff", "<cmd>Telescope find_files<CR>", { desc = "Find files" })
map("n", "<leader>fg", "<cmd>Telescope live_grep<CR>",  { desc = "Live grep" })
map("n", "<leader>fb", "<cmd>Telescope buffers<CR>",    { desc = "Buffers" })

map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")

map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

map("n", "<leader>tp", function()
  local pdf = vim.fn.expand("%:p:r") .. ".pdf"
  os.execute("zathura " .. pdf .. " &")
end, { desc = "Open Typst PDF in Zathura" })

local ok, colors = pcall(require, "stylix_colors")
if ok then
  local palette = {
    base00 = colors.base00, base01 = colors.base01,
    base02 = colors.base02, base03 = colors.base03,
    base04 = colors.base04, base05 = colors.base05,
    base06 = colors.base06, base07 = colors.base07,
    base08 = colors.base08, base09 = colors.base09,
    base0A = colors.base0A, base0B = colors.base0B,
    base0C = colors.base0C, base0D = colors.base0D,
    base0E = colors.base0E, base0F = colors.base0F,
  }
  vim.o.background = "dark"
  local hi = vim.api.nvim_set_hl
  hi(0, "Normal",       { fg = palette.base05, bg = palette.base00 })
  hi(0, "NormalFloat",  { fg = palette.base05, bg = palette.base01 })
  hi(0, "Comment",      { fg = palette.base03, italic = true })
  hi(0, "Constant",     { fg = palette.base09 })
  hi(0, "String",       { fg = palette.base0B })
  hi(0, "Identifier",   { fg = palette.base08 })
  hi(0, "Statement",    { fg = palette.base0E })
  hi(0, "PreProc",      { fg = palette.base0A })
  hi(0, "Type",         { fg = palette.base0A })
  hi(0, "Special",      { fg = palette.base0C })
  hi(0, "Underlined",   { fg = palette.base0D, underline = true })
  hi(0, "Error",        { fg = palette.base08, bold = true })
  hi(0, "Todo",         { fg = palette.base0A, bold = true })
  hi(0, "LineNr",       { fg = palette.base03 })
  hi(0, "CursorLineNr", { fg = palette.base0D, bold = true })
  hi(0, "CursorLine",   { bg = palette.base01 })
  hi(0, "Visual",       { bg = palette.base02 })
  hi(0, "StatusLine",   { fg = palette.base04, bg = palette.base01 })
  hi(0, "Pmenu",        { fg = palette.base05, bg = palette.base01 })
  hi(0, "PmenuSel",     { fg = palette.base00, bg = palette.base0D })
  hi(0, "MatchParen",   { fg = palette.base0C, bold = true })
  hi(0, "Search",       { fg = palette.base00, bg = palette.base0A })
  hi(0, "IncSearch",    { fg = palette.base00, bg = palette.base09 })
  hi(0, "SignColumn",   { bg = palette.base00 })
  hi(0, "ColorColumn",  { bg = palette.base01 })
  hi(0, "FloatBorder",  { fg = palette.base03, bg = palette.base01 })
  hi(0, "WinSeparator", { fg = palette.base02 })

  hi(0, "@variable",         { fg = palette.base05 })
  hi(0, "@function",         { fg = palette.base0D })
  hi(0, "@keyword",          { fg = palette.base0E })
  hi(0, "@string",           { fg = palette.base0B })
  hi(0, "@number",           { fg = palette.base09 })
  hi(0, "@type",             { fg = palette.base0A })
  hi(0, "@constant",         { fg = palette.base09 })
  hi(0, "@parameter",        { fg = palette.base08 })
  hi(0, "@field",            { fg = palette.base08 })
  hi(0, "@property",         { fg = palette.base08 })
  hi(0, "@constructor",      { fg = palette.base0C })
  hi(0, "@operator",         { fg = palette.base05 })
  hi(0, "@punctuation",      { fg = palette.base05 })
  hi(0, "@comment",          { fg = palette.base03, italic = true })
  hi(0, "@namespace",        { fg = palette.base0A })
  hi(0, "@include",          { fg = palette.base0E })

  hi(0, "DiagnosticError",   { fg = palette.base08 })
  hi(0, "DiagnosticWarn",    { fg = palette.base0A })
  hi(0, "DiagnosticInfo",    { fg = palette.base0D })
  hi(0, "DiagnosticHint",    { fg = palette.base0C })

  vim.g.stylix_palette = palette
end

require("lze").load({
  import = "plugins",
})
