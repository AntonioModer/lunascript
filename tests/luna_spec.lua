local luna = require 'luna'

describe('luna', function()
  it('can translate from luna code to lua', function()
    assert.are.same(luna.tolua 'let foo = "bar"', 'local foo\nfoo = "bar"\n')
  end)

  it('can run luna code directly', function()
    assert.has.no.errors(function() luna.dostring 'let world = "happy place"' end)
  end)

  it('can run files directly', function()
    assert.has.no.errors(function() luna.dofile 'examples/hello.luna' end)
  end)
end)
