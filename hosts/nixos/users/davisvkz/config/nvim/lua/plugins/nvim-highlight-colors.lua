return {
  "brenoprata10/nvim-highlight-colors",
  event = "BufReadPre",
  opts = {
    render = 'background',
    virtual_symbol = '■',
    virtual_symbol_prefix = '',
    virtual_symbol_suffix = ' ',
    virtual_symbol_position = 'inline',
    enable_hex = true,
    enable_short_hex = true,
    enable_rgb = true,
    enable_hsl = true,
    enable_ansi = true,
    enable_hsl_without_function = true,
    enable_var_usage = true,
    enable_named_colors = true,
    enable_tailwind = false,
    custom_colors = {
      { label = '%-%-theme%-primary%-color', color = '#0f1219' },
      { label = '%-%-theme%-secondary%-color', color = '#5a5d64' },
    },
    exclude_filetypes = {},
    exclude_buftypes = {},
    exclude_buffer = function(bufnr) end
  },
  config = function(_, opts)
    vim.opt.termguicolors = true
    require('nvim-highlight-colors').setup(opts)
  end,
}