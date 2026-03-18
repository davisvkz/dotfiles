return {
  "weirongxu/plantuml-previewer.vim",
  ft = { "plantuml" },
  cmd = { "PlantumlOpen", "PlantumlStart", "PlantumlStop", "PlantumlSave" },
  dependencies = {
    "tyru/open-browser.vim",
    "aklt/plantuml-syntax",
  },
  init = function()
    vim.filetype.add({
      extension = {
        pu = "plantuml",
        uml = "plantuml",
        plantuml = "plantuml",
        puml = "plantuml",
        iuml = "plantuml",
      },
    })

    vim.g["plantuml_previewer#file_pattern"] = "*.pu,*.uml,*.plantuml,*.puml,*.iuml"
    vim.g["plantuml_previewer#save_format"] = "svg"
  end,
}
