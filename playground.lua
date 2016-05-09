local luna = require 'luna'
local inspect = require 'inspect'

local source = [[
let world = 'world'
let bar = 'bar'
let test = "hello #{world} foo #{bar}"
]]

print(inspect(luna.tree(source)))
-- print(inspect(luna.luatree(source)))
-- print(luna.tolua(source))
