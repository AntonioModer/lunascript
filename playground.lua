local luna = require 'luna'
local inspect = require 'inspect'

local source = [[
let theAnswer = 42

do
  let blazeit = "420yoloswag"
  let bacon = 'force'

  do
    let test = 'testerino'

let a, b, c = 1, 2, 3

]]

-- print(inspect(luna.tree(source)))
-- print(inspect(luna.luatree(source)))
print(luna.tolua(source))
