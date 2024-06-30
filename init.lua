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
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.autoindent = false

vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.colorcolumn = '121'
vim.opt.textwidth=120

vim.opt.number = true
vim.o.list = true

-- Ensure the shada file is saved on exit and loaded on start
vim.opt.shadafile = vim.fn.stdpath('data') .. '/shada/main.shada'
vim.opt.shada = "'100,<50,s10,h"

-- Open URL or path under cursor
local function open_path()
    local path = vim.fn.expand(vim.fn.expand("<cWORD>")) -- Exapnd twice to parse paths with ~
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
        -- Blech!
        vim.fn.jobstart({"cmd.exe", "/C", open_cmd, path}, {detach = true})
    else
        vim.fn.jobstart({open_cmd, path}, {detach = true})
    end
end

vim.api.nvim_create_user_command('OpenUrl', open_path, {})
vim.api.nvim_set_keymap('n', '<leader>o', ':OpenUrl<CR>', { noremap = true, silent = true })

-- Define a function to trim trailing whitespace
local function trim_trailing_whitespace()
    local view = vim.fn.winsaveview()
    vim.cmd([[keeppatterns %s/\s\+$//e]]) -- Keep existing highlighting with keeppatterns.
    vim.fn.winrestview(view)
end

vim.api.nvim_create_user_command('TrimWhitespace', trim_trailing_whitespace, {})
vim.api.nvim_set_keymap('n', '<leader>t', ':TrimWhitespace<CR>', { noremap = true, silent = true })

-- Remove Highlights
vim.api.nvim_set_keymap('n', '<leader><space>', ":noh<CR>", { noremap = true, silent = true })

-- Y should work like yy
vim.api.nvim_set_keymap('n', 'Y', 'yy', { noremap = true, silent = true })

-- Lazy bootstrap
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- Plugins
require("lazy").setup({
    { "nvim-lua/plenary.nvim" },
    {
        "nvim-telescope/telescope.nvim",
        config = function()
            vim.api.nvim_set_keymap('n', '<leader>ff', ":Telescope find_files<CR>", { noremap = true, silent = true })
            vim.api.nvim_set_keymap('n', '<leader>fg', ":Telescope live_grep<CR>", { noremap = true, silent = true })
            vim.api.nvim_set_keymap('n', '<leader>fb', ":Telescope buffers<CR>", { noremap = true, silent = true })
            vim.api.nvim_set_keymap('n', '<leader>fh', ":Telescope help_tags<CR>", { noremap = true, silent = true })

            require('telescope').setup()
        end
    },
    {
        "nvim-tree/nvim-web-devicons",
        config = function()
            require("nvim-web-devicons").setup()
        end
    },
    {
        "nvim-tree/nvim-tree.lua",
        requires = { "nvim-tree/nvim-web-devicons" },
        config = function()
            vim.api.nvim_set_keymap('n', '<leader>e', ':NvimTreeToggle<CR>', { noremap = true, silent = true })
            require("nvim-tree").setup()
        end
    },
    {
        "nvim-treesitter/nvim-treesitter",
        run = ":TSUpdate",
        config = function()
            require('nvim-treesitter.configs').setup({
                ensure_installed = {"python", "lua", "c", "c_sharp", "javascript", "java"},
                highlight = {
                    enable = true
                },
                indent = {
                    enable = true
                }
            })
        end
    },
    {
        "cocopon/iceberg.vim", -- Adding Iceberg colorscheme
        config = function()
            vim.cmd.colorscheme("iceberg")
        end
    }
})

vim.cmd.filetype("indent off")
vim.cmd.filetype("plugin on")
vim.cmd.syntax("enable")
