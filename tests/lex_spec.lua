local lex = require 'luna.lex'

local source = [[
let hello = 'world'
let high = 5

let multi = """
cake is
lovely
"""

-- single comment
---
multi comment
---

if happy
  dance() -- test comment after name
else
  findHappiness() ---
  test multiline after name
  ---
]]

describe('luna.lex', function()
  it('reads source and spits out a bunch of tokens', function()
    assert.are.same({
      { type = "let", value = "let" },
      { type = "space", value = " " },
      { type = "name", value = "hello" },
      { type = "space", value = " " },
      { type = "assign", value = "=" },
      { type = "space", value = " " },
      { type = "string", value = "'world'" },
      { type = "line-break", value = "\n" },
      { type = "let", value = "let" },
      { type = "space", value = " " },
      { type = "name", value = "high" },
      { type = "space", value = " " },
      { type = "assign", value = "=" },
      { type = "space", value = " " },
      { type = "number", value = "5" },
      { type = "line-break", value = "\n\n" },
      { type = "let", value = "let" },
      { type = "space", value = " " },
      { type = "name", value = "multi" },
      { type = "space", value = " " },
      { type = "assign", value = "=" },
      { type = "space", value = " " },
      { type = "multi-string", value = '"""\ncake is\nlovely\n"""' },
      { type = "line-break", value = "\n\n" },
      { type = "comment", value = "-- single comment" },
      { type = "line-break", value = "\n" },
      { type = "comment", value = "---\nmulti comment\n---\n\n" },
      { type = "if", value = "if" },
      { type = "space", value = " " },
      { type = "name", value = "happy" },
      { type = "line-break", value = "\n" },
      { type = "space", value = "  " },
      { type = "name", value = "dance" },
      { type = "open-paren", value = "(" },
      { type = "closed-paren", value = ")" },
      { type = "space", value = " " },
      { type = "comment", value = "-- test comment after name" },
      { type = "line-break", value = "\n" },
      { type = "else", value = "else" },
      { type = "line-break", value = "\n" },
      { type = "space", value = "  " },
      { type = "name", value = "findHappiness" },
      { type = "open-paren", value = "(" },
      { type = "closed-paren", value = ")" },
      { type = "space", value = " " },
      { type = "comment", value = "---\n  test multiline after name\n  ---\n" },
    }, lex(source))
  end)
end)
