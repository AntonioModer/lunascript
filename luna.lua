local lexer = require 'luna.lexer'
local util = require 'luna.util'

local source = [[
let notlet letnot "hell\"o 'world'" 'test "test" \'test\'' 123.456 foobar

line \
continuation
]]

local tokens, err = lexer.tokenize(source)
util.print(tokens or err)
