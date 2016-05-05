local lex = require 'luna.lex'
local parse = require 'luna.parse'
local transform = require 'luna.transform'

local source = [[
let hello = 'world'
let a, b, c = 1, 2, 3
]]

local ast = transform(parse(lex(source)))

describe('luna.transform', function()
  it('transforms luna into a lua AST', function()
    assert.are.same({
      body = { {
          namelist = { "a", "b", "c", "hello" },
          type = "local"
        }, {
          explist = { "'world'" },
          namelist = { "hello" },
          type = "assign"
        }, {
          explist = { "1", "2", "3" },
          namelist = { "a", "b", "c" },
          type = "assign"
        } },
      type = "block"
    }, ast)
  end)
end)
