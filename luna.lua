local lexer = require 'luna.lexer'
local parser = require 'luna.parser'
local transform = require 'luna.transform'
local compile = require 'luna.compile'
local util = require 'luna.util'

local source = [[
a = 3.14
b = 42
hello = 'world'
]]

local tokens, err = lexer.tokenize(source)
local lunatree, err = parser.parse(tokens)
local luatree = transform.transform(lunatree)
local output = compile.compile(luatree)

print(output)
