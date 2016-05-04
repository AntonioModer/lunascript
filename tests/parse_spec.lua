local parse = require 'luna.parse'

describe('parser', function()
  it('ignores empty source', function()
    assert.are.same(parse.lex(''), {})
  end)

  it('ignores whitespace-only lines', function()
    assert.are.same(parse.lex('  \n\n  \n'), {})
  end)

  it('matches numbers', function()
    assert.are.equal(parse.lex('420')[1].tokens[1].value, '420')
  end)
end)
