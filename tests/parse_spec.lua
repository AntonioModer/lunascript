io.stdout:setvbuf('no')

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
    local tokens = lines[1].tokens

    assert.are.equal('420', tokens[1].value)
    assert.are.equal('.69', tokens[2].value)
    assert.are.equal('3.14159', tokens[3].value)
    assert.are.equal('0xDEADBEEF', tokens[4].value)
    assert.are.equal('5e100', tokens[5].value)
    assert.are.equal('314159E-5', tokens[6].value)
    assert.are.equal('1E+100', tokens[7].value)
  end)

  it('matches strings and accounts for escapes', function()
    local lines = parse.lex("\"hel\\\"lo\" 'wor\\\'ld' [[t\\\[\[es\\\]\]ti]\\\]ng]]")
    local tokens = lines[1].tokens

    assert.are.equal('"hel\\"lo"', tokens[1].value)
    assert.are.equal("'wor\\\'ld'", tokens[2].value)
    assert.are.equal("[[t\\\[\[es\\\]\]ti]\\\]ng\]\]", tokens[3].value)
  end)
end)
