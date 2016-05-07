local luna = require 'luna'

local source = [[
let test = "stuff"
let foo = 123

let test = "hello" .. "world"
]]

print(luna.tolua(source))
