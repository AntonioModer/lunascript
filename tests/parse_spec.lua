local parse = require 'luna.parse'

describe('parser', function()
  it('parses lines, ignoring unnecessary whitespace', function()
    assert.are.same(parse.lines 'hello\nworld\n  \n\ntest\n', {'hello','world','test'})
  end)
end)
