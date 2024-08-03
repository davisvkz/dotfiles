return {
	'MarcHamamji/runner.nvim',
	opts = {
		position = 'bottom',
		width = 80,
		height = 10,
		handlers = {
			python = function(buffer) require('runner.handlers.helpers').shell_handler('python3 ' .. vim.fn.expand('%'):gsub(' ','\\ '))(buffer) end,
			typescript = function(buffer)
				require('runner.handlers.utils').run_command("npm run 2>&1 | grep '  ' | awk '{$1=$1};1' | sed -n 'p;n'", function(output)
					print(buffer)
					local bins = {}
					local helpers = require('runner.handlers.helpers')

					for _, line in pairs(output) do
						for _, data in pairs(line) do
							if vim.trim(data) ~= '' and not string.match(data, 'npm ERR!') then
								bins[#bins + 1] = data
							end
						end
					end

					local handlers = {
						['Run current file'] = helpers.shell_handler('tsx ' .. vim.fn.expand('%'):gsub(' ','\\ ')),
						['Custom'] = helpers.shell_handler('npm ', true),
					}

					for _, bin in pairs(bins) do
						handlers['Run "' .. bin .. '"'] = helpers.shell_handler('npm run ' .. bin)
					end

					helpers.choice(handlers)(buffer)
				end)
			end,
			cpp = function (buffer)
				local helpers = require('runner.handlers.helpers')
				local filename = vim.fn.expand('%')
				local outname = vim.fn.expand('%'):gsub('.cpp','')
				helpers.choice({
					['Build Release and run'] = helpers.shell_handler(string.format('g++ -O2 -DNDEBUG -o %s %s && %s',outname,filename,outname)),
					['Build debug and run'] = helpers.shell_handler(string.format('g++ -ggdb -o %s %s && %s',outname,filename,outname)),
					['Build Release'] = helpers.shell_handler(string.format('g++ -O2 -DNDEBUG -o %s %s',outname,filename)),
					['Build debug'] = helpers.shell_handler(string.format('g++ -ggdb -o %s %s',outname,filename)),
				})(buffer)
			end
			--typescript = function(buffer) require('runner.handlers.helpers').shell_handler('tsx ' .. vim.fn.expand('%'):gsub(' ','\\ '))(buffer) end,
		}
	},
	dependencies = {
		'nvim-telescope/telescope.nvim',
		dependencies = { 'nvim-lua/plenary.nvim' }
	},
}
