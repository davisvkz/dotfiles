local autosave_enabled = false

local autosave_group = vim.api.nvim_create_augroup("AutoSaveOnInsertLeaveAndNormal", { clear = true })

local function autosave()
	-- Só salva se o buffer for modificável e não for só leitura
	if vim.bo.modifiable and not vim.bo.readonly and vim.bo.modified then
		vim.cmd("silent! write")
	end
end

vim.api.nvim_create_user_command("AutoSaveToggle", function()
	autosave_enabled = not autosave_enabled

	vim.api.nvim_clear_autocmds({ group = autosave_group })

	if autosave_enabled then
		-- Ao sair do modo insert
		vim.api.nvim_create_autocmd("InsertLeave", {
			group = autosave_group,
			pattern = "*",
			callback = autosave,
		})

		-- Ao mover o cursor no modo normal
		vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI", "CursorMoved", "CursorMovedI" }, {
			group = autosave_group,
			pattern = "*",
			callback = function()
				-- só salva se estiver no modo normal (evita salvar no insert toda hora)
				if vim.fn.mode() == "n" then
					autosave()
				end
			end,
		})

		print("AutoSave ativado: salva ao sair do insert ou mover no normal")
	else
		print("AutoSave desativado")
	end
end, {})
