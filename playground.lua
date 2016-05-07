local luna = require 'luna'

local source = [[
let test = "stuff"
let foo = 123

let test = "hello" .. "world"

let smallnum = #"string" + -5
]]

print(luna.tolua(source))
