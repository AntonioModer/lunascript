local luna = require 'luna'
local inspect = require 'inspect'

local source = [[
let theAnswer = 42

do
  let blazeit = "420yoloswag"

let bacon = 'force'
]]

print(inspect(luna.tree(source)))
-- print(inspect(luna.luatree(source)))
-- print(luna.tolua(source))
