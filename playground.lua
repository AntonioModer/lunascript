local luna = require 'luna'

local source = [[
let test = "stuff"
let foo = 123
]]

print(luna.tolua(source))
