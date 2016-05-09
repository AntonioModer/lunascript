local luna = require 'luna'
local inspect = require 'inspect'

local source = [[
let theAnswer = 42
]]

print(inspect(luna.tree(source)))
-- print(inspect(luna.luatree(source)))
-- print(luna.tolua(source))
