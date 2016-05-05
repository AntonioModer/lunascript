local lex = require 'luna.lex'

local source = [[
hello = 'world'
high = 5

if happy
  dance()
else
  findHappiness()

-- single comment
---
multi comment
---

name = name -- test comment after name
name = name ---
test multiline after name
---
]]

describe('luna.lex', function()
  it('reads source and spits out a bunch of tokens', function()
    assert.are.same({ -- generated w/ inspect.lua
      { type = "name", value = "hello" },
      { type = "space", value = " " },
      { type = "assign", value = "=" },
      { type = "space", value = " " },
      { type = "string", value = "'world'" },
      { type = "line-break", value = "\n" },
      { type = "name", value = "high" },
      { type = "space", value = " " },
      { type = "assign", value = "=" },
      { type = "space", value = " " },
      { type = "number", value = "5" },
      { type = "line-break", value = "\n\n" },
      { type = "name", value = "if" },
      { type = "space", value = " " },
      { type = "name", value = "happy" },
      { type = "line-break", value = "\n" },
      { type = "space", value = "  " },
      { type = "name", value = "dance" },
      { type = "open-paren", value = "(" },
      { type = "closed-paren", value = ")" },
      { type = "line-break", value = "\n" },
      { type = "name", value = "else" },
      { type = "line-break", value = "\n" },
      { type = "space", value = "  " },
      { type = "name", value = "findHappiness" },
      { type = "open-paren", value = "(" },
      { type = "closed-paren", value = ")" },
      { type = "comment", value = "\n\n-- single comment" },
      { type = "comment", value = "\n---\nmulti comment\n---\n\n" },
      { type = "name", value = "name" },
      { type = "space", value = " " },
      { type = "assign", value = "=" },
      { type = "space", value = " " },
      { type = "name", value = "name" },
      { type = "comment", value = " -- test comment after name" },
      { type = "line-break", value = "\n" },
      { type = "name", value = "name" },
      { type = "space", value = " " },
      { type = "assign", value = "=" },
      { type = "space", value = " " },
      { type = "name", value = "name" },
      { type = "comment", value = " ---\ntest multiline after name\n---\n" }
    }, lex(source))
  end)
end)
