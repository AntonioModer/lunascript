local luna = require 'luna'
local inspect = require 'inspect'

local source = [[
let theAnswer = 42
let blazeit = "420yoloswag"
]]

print(inspect(luna.tree(source)))
-- print(inspect(luna.luatree(source)))
-- print(luna.tolua(source))
