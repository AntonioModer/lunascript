local parse = require 'luna.parse'

describe('parser', function()
  it('ignores empty source', function()
    assert.are.same(parse.lex(''), {})
  end)

  it('ignores whitespace-only lines', function()
    assert.are.same(parse.lex('  \n\n  \n'), {})
  end)
end)
