-- ========================
-- ⚙️ CONFIG BÁSICA
-- ========================
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.cmd("syntax on")

vim.g.mapleader = " "

-- ==========================
-- IDENTACIÓN CORRECTA (TABS)
-- ==========================
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = false
vim.opt.smartindent = true
vim.opt.autoindent = true
vim.opt.copyindent = true

-- ========================
-- 📦 LAZY (plugin manager)
-- ========================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    lazypath
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({

  -- Tema
  {
    "folke/tokyonight.nvim",
    config = function()
      require("tokyonight").setup({
        style = "night",
        transparent = true,
      })
      vim.cmd("colorscheme tokyonight")

-- Colores neon"
vim.api.nvim_set_hl(0, "Keyword", {
  fg = "#ff00ff",
  bold = true
})

vim.api.nvim_set_hl(0, "Function", {
  fg = "#00ffff",
  bold = true
})

vim.api.nvim_set_hl(0, "String", {
  fg = "#00ff99"
})

vim.api.nvim_set_hl(0, "Type", {
  fg = "#ffff00",
  bold = true
})

vim.api.nvim_set_hl(0, "Comment", {
  fg = "#7dcfff",
  italic = true
})
    end
  },

  --  LSP
  {
    "neovim/nvim-lspconfig"
  },

  -- TERMINAL
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
      require("toggleterm").setup({
        size = 15,
        direction = "horizontal",
      })

      -- Ctrl+Enter
      vim.keymap.set("n", "<C-CR>", ":ToggleTerm<CR>")

      -- fallback seguro
      vim.keymap.set("n", "<C-t>", ":ToggleTerm<CR>")

      -- salir fácil de terminal
      vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]])
    end
  },

  -- Auto-pairs (auto cerrar () [] {})
  {
	"windwp/nvim-autopairs",
	event = "InsertEnter",
	config = function()
    local autopairs = require("nvim-autopairs")
    autopairs.setup({})

    -- integración con nvim-cmp (IMPORTANTE)
    local cmp = require("cmp")
    local cmp_autopairs = require("nvim-autopairs.completion.cmp")

    cmp.event:on(
      "confirm_done",
      cmp_autopairs.on_confirm_done()
    )
	end,
   },

  --  Autocompletado
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local cmp = require("cmp")

      cmp.setup({
        mapping = cmp.mapping.preset.insert({
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<C-Space>"] = cmp.mapping.complete(),
        }),
        sources = {
          { name = "nvim_lsp" },
        },
      })
    end
  },

  --  Árbol
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup()
    end
  },

})

-- ========================
--  TRANSPARENCIA
-- ========================
vim.cmd([[hi Normal guibg=NONE ctermbg=NONE]])
vim.cmd([[hi NormalNC guibg=NONE ctermbg=NONE]])

-- ========================
--  ATAJOS
-- ========================
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>")

--  Ejecutar Java rápido
vim.keymap.set("n", "<leader>r", function()
  vim.cmd("w")
  vim.cmd("ToggleTerm")
  vim.cmd("TermExec cmd='javac % && java %:r'")
end)

-- ========================
-- ☕ JAVA LSP (JDTLS)
-- ========================
--vim.api.nvim_create_autocmd("FileType", {
--  pattern = "java",
--  callback = function()
--    local jdtls_path = vim.fn.expand("~/.local/share/jdtls")
--    local launcher = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")

--    local workspace_dir = vim.fn.expand("~/.cache/jdtls/workspace")

--    local config = {
--      cmd = {
--        "java",
--        "-Declipse.application=org.eclipse.jdt.ls.core.id1",
--        "-Declipse.product=org.eclipse.jdt.ls.core.product",
--        "-Xmx1g",
--        "--add-modules=ALL-SYSTEM",
--        "--add-opens", "java.base/java.util=ALL-UNNAMED",
--        "--add-opens", "java.base/java.lang=ALL-UNNAMED",

--        "-jar", launcher,
--        "-configuration", jdtls_path .. "/config_linux",
--        "-data", workspace_dir,
--      },
--      root_dir = vim.fn.getcwd(),
--    }

--    vim.lsp.start(config)
--  end,
--})


vim.api.nvim_create_autocmd("FileType", {
  pattern = "java",
  callback = function()
    local jdtls_path = vim.fn.expand("~/.local/share/jdtls")

    local launcher = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")

    local root_dir = require("lspconfig.util").root_pattern(
      ".git",
      "mvnw",
      "gradlew"
    )(vim.fn.getcwd()) or vim.fn.getcwd()

    vim.lsp.start({
      name = "jdtls",
      cmd = {
        "java",
        "-Declipse.application=org.eclipse.jdt.ls.core.id1",
        "-Declipse.product=org.eclipse.jdt.ls.core.product",
        "-Xmx1g",
        "--add-modules=ALL-SYSTEM",
        "--add-opens", "java.base/java.util=ALL-UNNAMED",
        "--add-opens", "java.base/java.lang=ALL-UNNAMED",
        "-jar", launcher,
        "-configuration", jdtls_path .. "/config_linux",
        "-data", vim.fn.expand("~/.cache/jdtls-workspace"),
      },
      root_dir = root_dir,
    })
  end,
})
