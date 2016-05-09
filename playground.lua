local luna = require 'luna'
local inspect = require 'inspect'

local source = [[
let outer = 1
do
  let inner = 2
]]

-- print(inspect(luna.tree(source)))
-- print(inspect(luna.luatree(source)))
print(luna.tolua(source))
