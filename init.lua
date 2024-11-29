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

vim.opt.signcolumn = "yes"

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
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- ts_ls setup for TypeScript/JavaScript
      lspconfig.ts_ls.setup({
        on_attach = function(client, bufnr)
          -- Disable ts_ls formatting (use Prettier/null-ls instead)
          client.server_capabilities.documentFormattingProvider = false

          local opts = { noremap = true, silent = true, buffer = bufnr }
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
          vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
          vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
        end,
        capabilities = capabilities,
        flags = { debounce_text_changes = 150 },
      })
    end,
  },
  {
    "jose-elias-alvarez/null-ls.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local null_ls = require("null-ls")
      null_ls.setup({
        sources = {
          null_ls.builtins.formatting.prettier.with({
            filetypes = { "javascript", "typescript", "html", "css", "json" },
          }),
        },
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
    "hrsh7th/nvim-cmp", -- Autocomplete engine
    dependencies = {
      "hrsh7th/cmp-nvim-lsp", -- Integration with LSP
      "hrsh7th/cmp-buffer", -- Buffer completions
      "hrsh7th/cmp-path", -- Path completions
      "hrsh7th/vim-vsnip", -- Snippet engine
      "hrsh7th/cmp-vsnip", -- Snippet completions
    },
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        snippet = {
          expand = function(args)
            vim.fn["vsnip#anonymous"](args.body)
          end,
        },
        mapping = {
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping.select_next_item(),
          ["<S-Tab>"] = cmp.mapping.select_prev_item(),
        },
        sources = {
          { name = "nvim_lsp" }, -- LSP-based completions
          { name = "buffer" }, -- Buffer-based completions
          { name = "path" }, -- File path completions
        },
      })
    end,
  },
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "mxsdev/nvim-dap-vscode-js",
      "nvim-telescope/telescope-dap.nvim",
      "nvim-neotest/nvim-nio",
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      local layouts = {
        {
          elements = {
            { id = "scopes", size = 0.3 },
            { id = "breakpoints", size = 0.2 },
            { id = "stacks", size = 0.3 },
            { id = "watches", size = 0.2 },
          },
          size = 0.3,
          position = "left", -- Sidebar
        },
        {
          elements = {
            { id = "repl", size = 1.0 }, -- REPL
            -- { id = "console", size = 0.5 }, -- Debug Console
          },
          size = 0.25,
          position = "bottom", -- Bottom panel
        },
      }

      vim.api.nvim_set_keymap("n", "<leader>do", ":lua require('dapui').open()<CR>", { noremap = true, silent = true })
      vim.api.nvim_set_keymap("n", "<leader>dO", ":lua require('dapui').close()<CR>", { noremap = true, silent = true })
      -- Configure dap-ui
      dapui.setup({layouts = layouts})

      -- Automatically open/close the UI during debugging
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end

      -- Set up JavaScript/TypeScript debugging (nvim-dap-vscode-js)
      local dap_vscode_js = require("dap-vscode-js")
      dap_vscode_js.setup({
        debugger_path = vim.fn.stdpath("data") .. "/vscode-js-debug",
        adapters = { "pwa-node", "pwa-chrome" },
      })

      -- Define DAP configurations for JavaScript and TypeScript
      for _, language in ipairs({ "javascript", "typescript", "javascriptreact", "typescriptreact" }) do
        dap.configurations[language] = {
          {
            type = "pwa-node",
            request = "launch",
            name = "Launch Node.js Program",
            program = "${file}",
            cwd = "${workspaceFolder}",
          },
          {
            type = "pwa-chrome",
            request = "launch",
            name = "Launch Chrome",
            url = "http://localhost:3000", -- Adjust as needed
            webRoot = "${workspaceFolder}",
          },
          {
            type = "pwa-node",
            request = "attach",
            name = "Attach to Node.js",
            processId = require("dap.utils").pick_process,
            cwd = "${workspaceFolder}",
          },
        }
      end

      -- Keybindings for Debugging
      local opts = { noremap = true, silent = true }
      vim.api.nvim_set_keymap("n", "<F5>", ":lua require'dap'.continue()<CR>", opts) -- Start/Continue
      vim.api.nvim_set_keymap("n", "<F10>", ":lua require'dap'.step_over()<CR>", opts) -- Step Over
      vim.api.nvim_set_keymap("n", "<F11>", ":lua require'dap'.step_into()<CR>", opts) -- Step Into
      vim.api.nvim_set_keymap("n", "<F12>", ":lua require'dap'.step_out()<CR>", opts) -- Step Out
      vim.api.nvim_set_keymap("n", "<leader>dd", ":lua require('dap').terminate()<CR>", { noremap = true, silent = true })
      vim.api.nvim_set_keymap("n", "<leader>dq", ":lua require('dap').disconnect()<CR>", { noremap = true, silent = true })
      vim.api.nvim_set_keymap("n", "<leader>du", ":lua require('dapui').toggle()<CR>", { noremap = true, silent = true })
      vim.api.nvim_set_keymap("n", "<leader>b", ":lua require'dap'.toggle_breakpoint()<CR>", opts) -- Toggle Breakpoint
      vim.api.nvim_set_keymap("n", "<leader>B", ":lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>", opts) -- Conditional Breakpoint
      vim.api.nvim_set_keymap("n", "<leader>dr", ":lua require'dap'.repl.open()<CR>", opts) -- Open REPL

      -- Telescope Integration for DAP
      require("telescope").load_extension("dap")
      vim.api.nvim_set_keymap("n", "<leader>dc", ":Telescope dap configurations<CR>", opts) -- Debug Configurations
      vim.api.nvim_set_keymap("n", "<leader>dv", ":Telescope dap variables<CR>", opts) -- Debug Variables
      vim.api.nvim_set_keymap("n", "<leader>df", ":Telescope dap frames<CR>", opts) -- Debug Frames
      vim.api.nvim_set_keymap("n", "<leader>dl", ":Telescope dap list_breakpoints<CR>", opts) -- List Breakpoints
    end,
  },
  {
    "nvim-tree/nvim-web-devicons",
    config = function()
      require("nvim-web-devicons").setup()
    end
  },
  {
    "nvim-tree/nvim-tree.lua",
    config = function()
      vim.api.nvim_set_keymap('n', '<leader>e', ':NvimTreeToggle<CR>', { noremap = true, silent = true })
      require("nvim-tree").setup({
        update_focused_file = {
          enable = true
        }
      })
    end
  },
  {
    "nvim-treesitter/nvim-treesitter",
    config = function()
      require('nvim-treesitter.configs').setup({
        ensure_installed = {
          "python",
          "lua",
          "c",
          "c_sharp",
          "javascript",
          "java",
          "markdown",
          "typescript",
          "tsx",
          "html",
          "css"
        },
        highlight = {
          enable = true,
        },
        indent = {
          enable = true,
        },
      })
    end
  },
  {
    "kosayoda/nvim-lightbulb",
    config = function()
      require("nvim-lightbulb").setup({
        autocmd = { enabled = true },
        sign = {
          enabled = false,
          priority = 10,
        },
        virtual_text = {
          enabled = true,
          text = "❯",
        },
      })
    end,
  },
  {
    "cocopon/iceberg.vim",
    config = function()
      vim.cmd.colorscheme("iceberg")
    end,
  }
})
