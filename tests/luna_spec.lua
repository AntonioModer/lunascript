local luna = require 'luna'

local source = [[
let foo = 'bar'
let a, b, c = 1, 2, 3

global = "var"

ten = 3 + 7
]]

local output = [[
local a, b, c, foo
foo = 'bar'
a, b, c = 1, 2, 3
global = "var"
ten = 3 + 7
]]

describe('luna', function()
  it('parses empty source', function()
    assert.are.same('\n', luna.tolua '')
  end)

  it('can translate from luna code to lua', function()
    assert.are.same(output, luna.tolua(source))
  end)

  it('can run luna code directly', function()
    assert.has.no.errors(function() luna.dostring 'let world = "happy place"' end)
  end)

  it('can run files directly', function()
    assert.has.no.errors(function() luna.dofile 'examples/hello.luna' end)
  end)
end)
