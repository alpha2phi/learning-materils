local M = {}

local lsputils = require "config.lsp.utils"

function M.config(install_server)
  return {
    -- https://github.com/golang/tools/blob/master/gopls/doc/settings.md
    experimentalPostfixCompletions = true,
    analyses = { unusedparams = true, unreachable = false },
    codelenses = { generate = true, gc_details = true, test = true, tidy = true },
    usePlaceholders = true,
    completeUnimported = true,
    staticcheck = true,
    matcher = "fuzzy",
    experimentalDiagnosticsDelay = "500ms",
    symbolMatcher = "fuzzy",
    gofumpt = true,
    buildFlags = { "-tags", "integration" },
    capabilities = lsputils.get_capabilities(),
    on_attach = lsputils.lsp_attach,
    on_init = lsputils.lsp_init,
    on_exit = lsputils.lsp_exit,
    flags = { debounce_text_changes = 150 },
    cmd = installed_server._default_options.cmd,
  }
end

function M.setup(install_server)
  lsputils.setup_server("gopls", M.config(install_server))
end

return M
