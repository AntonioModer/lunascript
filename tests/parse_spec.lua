local lex = require 'luna.lex'
local parse = require 'luna.parse'

describe('luna.parse', function()
  it('parses let statements', function()
    assert.are.same(
      { type = 'let', target = 'a', assign = '=', value = '5' },
      parse(lex[[let a = 5]]).body[1])
  end)
end)
