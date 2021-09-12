local M = {}

function M.lsp_highlight(client, bufnr)
    if client.resolved_capabilities.document_highlight then
        vim.api.nvim_exec([[
        hi LspReferenceRead cterm=bold ctermbg=red guibg=#282f45
        hi LspReferenceText cterm=bold ctermbg=red guibg=#282f45
        hi LspReferenceWrite cterm=bold ctermbg=red guibg=#282f45
        augroup lsp_document_highlight
        autocmd! * <buffer>
        autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
        autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
        augroup END
        ]], false)
    end

    -- if client.resolved_capabilities.code_lens then
    --     print("code lens")
    --     vim.api.nvim_exec([[
    --     augroup lsp_code_lens
    --     autocmd BufEnter,CursorHold,InsertLeave <buffer> lua vim.lsp.codelens.refresh()
    --     augroup END
    --     ]], false)
    -- end

end

function M.lsp_config(client, bufnr)

    require("lsp_signature").on_attach({
        bind = true,
        handler_opts = {border = "single"}
    })

    local function buf_set_option(...) vim.api.nvim_buf_set_option(...) end
    buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

    -- Key mappings
    local lspkeymappings = require("keymappings")
    lspkeymappings.setup_lsp_mappings()

    -- LSP and DAP menu
    local whichkey = require("config.which-key")
    whichkey.register_lsp(client)
    whichkey.register_dap(client)

    if client.resolved_capabilities.document_formatting then
        vim.cmd("autocmd BufWritePre <Buffer> lua vim.lsp.buf.formatting_sync()")
    end
end

function M.lsp_init(client, bufnr)
    -- LSP init
end

function M.lsp_exit(client, bufnr)
    -- LSP exit
end

function M.lsp_attach(client, bufnr)
    M.lsp_config(client, bufnr)
    M.lsp_highlight(client, bufnr)
end

function M.get_capabilities()

    local capabilities = vim.lsp.protocol.make_client_capabilities()

    -- for nvim-cmp
    capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

    -- Code actions
    capabilities.textDocument.codeAction = {
        dynamicRegistration = true,
        codeActionLiteralSupport = {
            codeActionKind = {
                valueSet = (function()
                    local res = vim.tbl_values(vim.lsp.protocol.CodeActionKind)
                    table.sort(res)
                    return res
                end)()
            }
        }
    }

    capabilities.textDocument.completion.completionItem.snippetSupport = true
    capabilities.textDocument.completion.completionItem.resolveSupport = {
        properties = {"documentation", "detail", "additionalTextEdits"}
    }
    capabilities.experimental = {}
    capabilities.experimental.hoverActions = true

    return capabilities

end

function M.setup_server(server, config)

    local lspconfig = require('lspconfig')
    lspconfig[server].setup(vim.tbl_deep_extend("force", {
        on_attach = M.lsp_attach,
        on_exit = M.lsp_exit,
        on_init = M.lsp_init,
        capabilities = M.get_capabilities(),
        flags = {debounce_text_changes = 150},
        init_options = config
    }, {}))

    local cfg = lspconfig[server]
    if not (cfg and cfg.cmd and vim.fn.executable(cfg.cmd[1]) == 1) then
        print(server .. ": cmd not found: " .. vim.inspect(cfg.cmd))
    end

end







-- Refactoring in progress

function M.WIP()
    -- Language specific key mappings
    require('config.lsp.keymappings')

    -- Language servers
    local servers = {
        pyright = {},
        gopls = {
            -- https://github.com/golang/tools/blob/master/gopls/doc/settings.md
            experimentalPostfixCompletions = true,
            analyses = {unusedparams = true, unreachable = false},
            codelenses = {
                generate = true,
                gc_details = true,
                test = true,
                tidy = true
            },
            usePlaceholders = true,
            completeUnimported = true,
            staticcheck = true,
            matcher = "fuzzy",
            experimentalDiagnosticsDelay = "500ms",
            symbolMatcher = "fuzzy",
            gofumpt = true,
            buildFlags = {"-tags", "integration"}
        },
        tsserver = {},
        vimls = {}
        -- rust_analyzer = {},
    }

    -- local servers = require'lspinstall'.installed_servers()
    -- local coq = require("coq")

    local function setup_servers(lsp_servers)
        for server, config in pairs(lsp_servers) do

            lspconfig[server].setup( -- coq.lsp_ensure_capabilities(
            vim.tbl_deep_extend("force", {
                on_attach = lsp_on_attach,
                -- on_exit = lsp_on_exit,
                -- on_init = lsp_on_init,
                capabilities = capabilities,
                flags = {debounce_text_changes = 150},
                init_options = config
            }, {}))
            -- )

            local cfg = lspconfig[server]
            if not (cfg and cfg.cmd and vim.fn.executable(cfg.cmd[1]) == 1) then
                print(server .. ": cmd not found: " .. vim.inspect(cfg.cmd))
            end
        end
    end

    local function setup_null_ls()
        lspconfig["null-ls"].setup(vim.tbl_deep_extend("force", {
            on_attach = lsp_on_attach,
            capabilities = capabilities,
            flags = {debounce_text_changes = 150}
        }, {}))

        local cfg = lspconfig["null-ls"]
        if not (cfg and cfg.cmd and vim.fn.executable(cfg.cmd[1]) == 1) then
            print("null-ls" .. ": cmd not found: " .. vim.inspect(cfg.cmd))
        end
    end

    local function configure_null_ls()
        local null_ls = require("null-ls")
        local sources = {
            null_ls.builtins.formatting.prettier,
            null_ls.builtins.diagnostics.write_good
                .with({filetypes = {"markdown", "text"}}),
            null_ls.builtins.code_actions.gitsigns,
            null_ls.builtins.formatting.lua_format,
            null_ls.builtins.formatting.isort,
            null_ls.builtins.formatting.black,
            null_ls.builtins.diagnostics.flake8
        }
        null_ls.config({sources = sources})
    end

    setup_servers(servers)
    configure_null_ls()
    setup_null_ls()

    -- rust-tools.nvim
    local function setup_rust_tools()
        -- local tools = {
        --     autoSetHints = true,
        --     runnables = {use_telescope = true},
        --     inlay_hints = {show_parameter_hints = true},
        --     hover_actions = {auto_focus = true}
        -- }
        require('rust-tools').setup({
            -- tools = tools,
            server = {
                on_attach = lsp_on_attach,
                capabilities = capabilities,
                flags = {debounce_text_changes = 150}
            },
            settings = {
                ["rust-analyzer"] = {
                    --         assist = {
                    --             importGranularity = "module",
                    --             importEnforceGranularity = true
                    --         },
                    --         cargo = {loadOutDirsFromCheck = true, allFeatures = true},
                    --         procMacro = {enable = true},
                    --         checkOnSave = {command = "clippy"},
                    --         experimental = {procAttrMacros = true},
                    --         hoverActions = {references = true},
                    --         inlayHints = {
                    --             chainingHints = true,
                    --             maxLength = 40,
                    --             parameterHints = true,
                    --             typeHints = true
                    --         },
                    lens = {methodReferences = true, references = true}
                }
            }
        })
        require('rust-tools-debug').setup()
    end

    pcall(setup_rust_tools)

    vim.lsp.handlers["textDocument/publishDiagnostics"] =
        vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
            virtual_text = true,
            underline = false,
            signs = true,
            update_in_insert = false
        })

    -- local on_references = vim.lsp.handlers["textDocument/references"]
    -- vim.lsp.handlers["textDocument/references"] =
    --     vim.lsp.with(on_references, {
    --         -- loclist = true,
    --         virtual_text = true
    --     })

    -- Send diagnostics to quickfix list
    do
        local method = "textDocument/publishDiagnostics"
        local default_handler = vim.lsp.handlers[method]
        vim.lsp.handlers[method] = function(err, meth, result, client_id, bufnr,
                                            config)
            default_handler(err, meth, result, client_id, bufnr, config)
            local diagnostics = vim.lsp.diagnostic.get_all()
            local qflist = {}
            for buf, diagnostic in pairs(diagnostics) do
                for _, d in ipairs(diagnostic) do
                    d.bufnr = buf
                    d.lnum = d.range.start.line + 1
                    d.col = d.range.start.character + 1
                    d.text = d.message
                    table.insert(qflist, d)
                end
            end
            vim.lsp.util.set_qflist(qflist)
        end
    end
end

return M
