local lex = require 'luna.lex'
local luna = require 'luna'
local inspect = require 'inspect'

local source = [[
"te\"st"
'te\'st'

"""
'test'
"test"
#{a + b}
"""

'#{test}'
"#{test}"
]]

print(inspect(lex(source)))
