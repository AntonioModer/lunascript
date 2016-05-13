local lexer = require 'luna.lexer'
local parser = require 'luna.parser'
local util = require 'luna.util'

local source = [[
a = 3.14
b = 42
]]

local tokens, err = lexer.tokenize(source)

local tree = parser.parse(tokens)
util.print(tree)
