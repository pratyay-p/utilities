vim.filetype.add({
  pattern = {
    ["makefile*"] =  "make",
    ["%.mk$"] = "make",
    ["%.make$"] = "make",
    ["%.vuerc$"] = "json",
    ["%.bashrc.*"] = "bash",
    ["%.profile.*"] = "bash",
    ["%.i$"] = "cpp"
  },
  extension = {
    inc = "cpp",
    td = "tablegen"
  }
})
