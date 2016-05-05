local lex = require 'luna.lex'
local parse = require 'luna.parse'

local source = [[
let a, b,c = 1, 2, 3
]]

local tokens = lex(source)
local tree = parse(tokens)

describe('luna.parse', function()
  it('parses let assignments', function()
    assert.are.same({ type = 'let-assign', namelist = {'a', 'b', 'c'}, assign = '=', explist = {'1', '2', '3'} }, tree.body[1])
  end)
end)
