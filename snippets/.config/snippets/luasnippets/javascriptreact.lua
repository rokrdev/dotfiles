local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local extras = require("luasnip.extras")
local fmt = require("luasnip.extras.fmt").fmt
local rep = extras.rep

return {
  s({
    trig = "rfc", name = "React Functional Component"
  }, fmt([[
  import * as React from 'react'
  function {} {{
    return (
    <div>
      {}
    </div>
    )
  }}

  export default {}
  ]], {
    i(1), i(0), rep(1)
  })
  ),
  s({
    trig = "af", name = "Arrow function"
  }, fmt([[
  {} => {{
    {}
  }}
  ]], {
    i(1), i(0)
  })
  ),
}
