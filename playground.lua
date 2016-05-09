local luna = require 'luna'
local inspect = require 'inspect'

local source = [[
let test = "test #{'test'}"
let test = "overwriting test"
let test2 = "foo"

global = "don't look, i'm global"
]]

-- print(inspect(luna.tree(source)))
-- print(inspect(luna.luatree(source)))
print(luna.tolua(source))
