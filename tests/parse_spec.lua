local parse = require 'luna.parse'

describe('parser', function()
  it('ignores empty source', function()
    assert.are.same(parse.lex(''), {})
  end)

  it('ignores whitespace-only lines', function()
    assert.are.same(parse.lex('  \n\n  \n'), {})
  end)

  it('matches numbers', function()
    local lines = parse.lex('420 .69 3.14159 0xDEADBEEF 5e100 314159E-5 1E+100')

    assert.are.equal(lines[1].tokens[1].value, '420')
    assert.are.equal(lines[1].tokens[2].value, '.69')
    assert.are.equal(lines[1].tokens[3].value, '3.14159')
    assert.are.equal(lines[1].tokens[4].value, '0xDEADBEEF')
    assert.are.equal(lines[1].tokens[5].value, '5e100')
    assert.are.equal(lines[1].tokens[6].value, '314159E-5')
    assert.are.equal(lines[1].tokens[7].value, '1E+100')
  end)
end)
