local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt

return {
  s({
    trig = "cl", name = "Console log"
  }, fmt([[
  console.log({})
  ]], {
    i(1)
  })
  ),
}


