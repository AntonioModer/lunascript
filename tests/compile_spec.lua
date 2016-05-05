local lex = require 'luna.lex'
local parse = require 'luna.parse'
local transform = require 'luna.transform'
local compile = require 'luna.compile'

local source = [[
let hello = 'world'
let a, b, c = 1, 2, 3
]]

local expected = [[
local a, b, c, hello
hello = 'world'
a, b, c = 1, 2, 3
]]

local output = compile(transform(parse(lex(source))))

describe('luna.compile', function()
  it('compiles to lua source', function()
    assert.are.equal(output, expected)
  end)
end)
