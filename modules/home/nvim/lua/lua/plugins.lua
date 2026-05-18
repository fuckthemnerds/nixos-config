local plugins = {}

local function merge(mod)
  if type(mod) == "table" then
    for _, p in ipairs(mod) do
      table.insert(plugins, p)
    end
  end
end

merge(require("plugins.completion"))
merge(require("plugins.editor"))
merge(require("plugins.lsp"))
merge(require("plugins.ui"))

return plugins
