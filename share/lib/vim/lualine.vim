lua << END
require('lualine').setup {
  sections = {
    lualine_a = {
      'mode',
      'vim.opt.paste._value and "PASTE" or nil'
    },
    lualine_x = {
      'encoding',
      'vim.opt.eol._value and "eol" or "noeol"',
      {
        'fileformat',
        symbols = {
          unix = '\\n',
          dos = '\\r\\n',
          mac = '\\r',
        },
      },
      'filetype'
    },
  },
  tabline = {
    lualine_a = {
      {
        'buffers',
        mode = 2,
        max_length = vim.o.columns - 32,
        icons_enabled = false,
        buffers_color = {
          active = 'lualine_a_normal',
          inactive = 'lualine_b_inactive',
        },
      },
    },
    lualine_z = {{'tabs', max_length = 32}},
  },
}
END
