local luna = require 'luna'
local inspect = require 'inspect'

local source = [[
let foobar = 123
]]

print(luna.tolua(source))
