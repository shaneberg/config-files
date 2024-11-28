vim.opt.clipboard = "unnamedplus"

vim.opt.listchars = {
    tab = '▸▸',
    extends = 'E',
    precedes = 'P',
    space = '∙',
    trail = '◦',
    eol = '┤'
}

-- Tabs
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.autoindent = false

vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.colorcolumn = '81'
vim.opt.textwidth = 80

vim.opt.number = true
vim.o.list = true

-- Ensure the shada file is saved on exit and loaded on start
vim.opt.shadafile = vim.fn.stdpath('data') .. '/shada/main.shada'
vim.opt.shada = "'100,<50,s10,h"

-- Open URL or path under cursor
local function open_path()
    local path = vim.fn.expand(vim.fn.expand("<cWORD>"))
    local open_cmd

    if vim.fn.has("mac") == 1 then
        open_cmd = "open"
    elseif vim.fn.has("unix") == 1 then
        open_cmd = "xdg-open"
    elseif vim.fn.has("win32") == 1 then
        open_cmd = "start"
    else
        print("Unsupported OS")
        return
    end

    if open_cmd == "start" then
        vim.fn.jobstart({"cmd.exe", "/C", open_cmd, path}, {detach = true})
    else
        vim.fn.jobstart({open_cmd, path}, {detach = true})
    end
end

vim.api.nvim_create_user_command('OpenUrl', open_path, {})
vim.api.nvim_set_keymap('n', '<leader>o', ':OpenUrl<CR>', { noremap = true, silent = true })

-- Trim trailing whitespace
local function trim_trailing_whitespace()
    local view = vim.fn.winsaveview()
    vim.cmd([[keeppatterns %s/\s\+$//e]])
    vim.fn.winrestview(view)
end

vim.api.nvim_create_user_command('TrimWhitespace', trim_trailing_whitespace, {})
vim.api.nvim_set_keymap('n', '<leader>t', ':TrimWhitespace<CR>', { noremap = true, silent = true })

-- Copy file path to clipboard
vim.api.nvim_set_keymap('n', '<leader>y', ':let @+ = expand("%:p")<CR>', { noremap = true, silent = true })

-- Remove Highlights
vim.api.nvim_set_keymap('n', '<leader><space>', ":noh<CR>", { noremap = true, silent = true })

-- Y should work like yy
vim.api.nvim_set_keymap('n', 'Y', 'yy', { noremap = true, silent = true })

-- Neovide-specific settings
if vim.g.neovide then
    vim.g.neovide_cursor_vfx_mode = "wireframe"
    vim.api.nvim_set_keymap('n', '<F11>', ":lua vim.g.neovide_fullscreen = not vim.g.neovide_fullscreen<CR>", { noremap = true, silent = true })
end

-- GUI-specific settings
if vim.fn.has("gui_running") == 1 then
    function adjust_font_size(delta)
        local guifont = table.concat(vim.opt.guifont:get(), ",")
        local size = guifont:match('h(%d+)')
        if size then
            size = tonumber(size) + delta
            vim.opt.guifont = guifont:gsub('h%d+', 'h' .. size)
        end
    end

    vim.api.nvim_set_keymap('n', '<C-=>', ":lua adjust_font_size(1)<CR>", { noremap = true, silent = true })
    vim.api.nvim_set_keymap('n', '<C-->', ":lua adjust_font_size(-1)<CR>", { noremap = true, silent = true })

    vim.opt.guifont = "Cascadia Code:h14:cANSI"

    vim.opt.guicursor = {
        "n-v-c:block-Cursor",                  -- Normal, Visual, Command-line: block
        "i-ci-ve:ver25-Cursor",                -- Insert, Command-line Insert, Visual: vertical bar cursor 25% width
        "r-cr:hor20-Cursor",                   -- Replace, Command-line Replace: horizontal bar cursor 20% height
        "o:hor50",                             -- Operator-pending: horizontal bar cursor 50% height
        "a:blinkwait700-blinkoff400-blinkon250-Cursor"
    }
end

-- Lazy.nvim setup
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    { "nvim-lua/plenary.nvim" },
    {
        "neovim/nvim-lspconfig",
        config = function()
            local lspconfig = require("lspconfig")

            -- ts_ls setup for TypeScript/JavaScript
            lspconfig.ts_ls.setup({
                on_attach = function(client, bufnr)
                    -- Disable ts_ls formatting (use Prettier/null-ls instead)
                    client.server_capabilities.documentFormattingProvider = false

                    -- Key mappings for LSP functionality
                    local opts = { noremap = true, silent = true, buffer = bufnr }
                    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
                    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
                    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
                    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
                    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
                    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
                    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
                end,
                flags = { debounce_text_changes = 150 },
            })
        end,
    },
    {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            require("telescope").setup({
                defaults = {
                    file_ignore_patterns = { "node_modules", ".git/" },
                }
            })
            vim.api.nvim_set_keymap('n', '<leader>ff', ":Telescope find_files<CR>", { noremap = true, silent = true })
            vim.api.nvim_set_keymap('n', '<leader>fg', ":Telescope live_grep<CR>", { noremap = true, silent = true })
        end,
    },
    {
        "cocopon/iceberg.vim",
        config = function()
            vim.cmd.colorscheme("iceberg")
        end,
    }
})
