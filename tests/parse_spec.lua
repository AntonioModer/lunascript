local lex = require 'luna.lex'
local parse = require 'luna.parse'

local source = [[
let a = 5
]]

describe('luna.parse', function()
  local tokens = lex(source)
  local tree = parse(tokens)

  it('parses let assignments', function()
    assert.are.same({ type = 'let-assign', target = 'a', assign = '=', value = '5' }, tree.body[1])
  end)
end)
