local function on_attach(_, bufnr)
  local map = function(lhs, rhs, desc)
    vim.keymap.set("n", lhs, rhs, { buffer = bufnr, desc = desc, silent = true })
  end
  map("gd",        vim.lsp.buf.definition,     "Go to definition")
  map("gD",        vim.lsp.buf.declaration,    "Go to declaration")
  map("gr",        vim.lsp.buf.references,     "References")
  map("gI",        vim.lsp.buf.implementation, "Go to implementation")
  map("K",         vim.lsp.buf.hover,          "Hover docs")
  map("<leader>ca", vim.lsp.buf.code_action,   "Code action")
  map("<leader>rn", vim.lsp.buf.rename,        "Rename symbol")
  map("[d",        vim.diagnostic.goto_prev,   "Prev diagnostic")
  map("]d",        vim.diagnostic.goto_next,   "Next diagnostic")
  map("<leader>d", vim.diagnostic.open_float,  "Line diagnostics")
end

local function make_capabilities()
  local ok, cmp_lsp = pcall(require, "cmp_nvim_lsp")
  if ok then
    return cmp_lsp.default_capabilities()
  end
  return vim.lsp.protocol.make_client_capabilities()
end

return {
  {
    "nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    load = function(name) vim.cmd.packadd(name) end,
    after = function()
      local nixCats = require("nixCats")
      local caps = make_capabilities()

      -- Global defaults for all servers
      vim.lsp.config("*", {
        capabilities = caps,
      })

      -- Per-server configuration (nvim 0.12+ API)
      vim.lsp.config("nixd", {
        settings = {
          nixd = {
            nixos = {
              expr = nixCats.extra("nixdExtras.nixosConfig"),
            },
            options = {
              home_manager = {
                expr = nixCats.extra("nixdExtras.hmConfig"),
              },
            },
          },
        },
      })

      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
          },
        },
      })

      vim.lsp.config("ts_ls", {})
      vim.lsp.config("pyright", {})

      vim.lsp.config("tinymist", {
        settings = {
          exportPdf = "onSave",
          outputPath = "$dir/$name.pdf",
        },
      })

      -- Enable all servers
      vim.lsp.enable({ "nixd", "lua_ls", "ts_ls", "pyright", "tinymist" })

      -- Attach keymaps via autocmd
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          on_attach(vim.lsp.get_client_by_id(args.data.client_id), args.buf)
        end,
      })

      vim.diagnostic.config({
        virtual_text = { spacing = 4, prefix = "●" },
        severity_sort = true,
        signs = true,
        underline = true,
        update_in_insert = false,
      })
    end,
  },
}
