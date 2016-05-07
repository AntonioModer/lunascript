local lex = require 'luna.lex'

describe('luna.lex', function()
  it('correctly lexes string interpolation syntax', function()
    assert.are.same({
      {type = "string-head", value = '"'},
      {type = "string-content", value = 'te\\"st'},
      {type = "string-tail", value = '"'},
      {type = "line-break", value = "\n"},
      {type = "string-head", value = "'"},
      {type = "string-content", value = "te\\'st"},
      {type = "string-tail", value = "'"},
      {type = "line-break", value = "\n\n"},
      {type = "string-head", value = '"""'},
      {type = "string-content", value = "\n'test'\n\"test\"\n"},
      {type = "string-infix-open", value = "#{"},
      {type = "name", value = "a"},
      {type = "space", value = " "},
      {type = "plus", value = "+"},
      {type = "space", value = " "},
      {type = "name", value = "b"},
      {type = "string-infix-close", value = "}"},
      {type = "string-content", value = "\n"},
      {type = "string-tail", value = '"""'},
      {type = "line-break", value = "\n\n"},
      {type = "string-head", value = "'"},
      {type = "string-content", value = "#{test}"},
      {type = "string-tail", value = "'"},
      {type = "line-break", value = "\n"},
      {type = "string-head", value = '"'},
      {type = "string-infix-open", value = "#{"},
      {type = "name", value = "test"},
      {type = "string-infix-close", value = "}"},
      {type = "string-tail", value = '"'},
      {type = "line-break", value = "\n"},
    }, lex[[
"te\"st"
'te\'st'

"""
'test'
"test"
#{a + b}
"""

'#{test}'
"#{test}"
]])

  end)
end)
