return {
	"sschleemilch/slimline.nvim",
	opts = {
		bold = false, -- makes primary parts bold

		-- Global style. Can be overwritten using `configs.<component>.style`
		style = 'bg', -- or "fg"

		-- Component placement
		components = {
			left = {
				'mode',
				'path',
				'git',
			},
			center = {},
			right = {
				'diagnostics',
				'filetype_lsp',
				'progress',
			},
		},

		-- Component configuration
		-- `<component>.style` can be used to overwrite the global 'style'
		-- `<component>.hl = { primary = ..., secondary = ...}` can be used to overwrite global ones
		-- `<component>.follow` can point to another component name to follow its style (e.g. 'progress' following 'mode' by default). Follow can be disabled by setting it to `false`
		configs = {
			mode = {
				verbose = false, -- Mode as single letter or as a word
				hl = {
					normal = 'Type',
					insert = 'Function',
					pending = 'Boolean',
					visual = 'Keyword',
					command = 'String',
				},
			},
			path = {
				directory = true, -- Whether to show the directory
				icons = {
					folder = ' ',
					modified = '',
					read_only = '',
				},
			},
			git = {
				icons = {
					branch = '',
					added = '+',
					modified = '~',
					removed = '-',
				},
			},
			diagnostics = {
				workspace = false, -- Whether diagnostics should show workspace diagnostics instead of current buffer
				icons = {
					ERROR = ' ',
					WARN = ' ',
					HINT = ' ',
					INFO = ' ',
				},
			},
			filetype_lsp = {},
			progress = {
				follow = 'mode',
				column = false, -- Enables a secondary section with the cursor column
				icon = ' ',
			},
			recording = {
				icon = ' ',
			},
		},
		spaces = {
			components = "",
			left = "",
			right = "",
		},
		sep = {
			hide = {
				first = true,
				last = true,
			},
			left = "",
			right = "",
		},

		-- Global highlights
		hl = {
			base = 'Comment',   -- highlight of the background
			primary = 'Normal', -- highlight of primary parts (e.g. filename)
			secondary = 'Comment', -- highlight of secondary parts (e.g. filepath)
		},
	}
}
