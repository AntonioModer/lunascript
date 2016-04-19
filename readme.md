# LunaScript

A language that compiles to Lua

## Key Features

- Everything is an expression

```lua
if file = io.open 'file.txt' then
  while line = file:read() do
    print(line)
  end
  file:close()
end

life = 100
repeat
  print 'alive!'
until (life -= math.random(1, 10)) <= 0 and print 'dead :('

if (a = stuff()) and (b = stuff()) and (c = stuff()) then
  print 'all the stuff!'
end
```

- `require` helpers

```lua
import 'inspect'          --> local inspect = require 'inspect'
import 'lib.inspect'      --> local inspect = require 'lib.inspect'
import 'player' as Player --> local Player  = require 'player'
```

- Automatic localization, at top level of block, with optional globalization

```lua
function foo() bar() end
function bar() foo() end
global var = 5

-- compiles to:
local foo, bar
function foo() bar() end
function bar() foo() end
var = 5
```

- Don't require parentheses for operations on literals, e.g. `white = '#' .. 'F':rep(6)`
- Assignment operators, `+=`, `-=` and similar
- Possibly rework loops to make table/array looping less inconvenient and awkward
- Possible existential operator `?`
- Some other things stolen from MoonScript and other languages because being creative is hard ¯\\\_(ツ)\_/¯
- Anything else that can be answered with 'Why not?'

## Why?

To fill the desire for a language that's a lot nicer to use, but still feels like Lua. Therefore:
- Focus on readability, and keywords over symbols, instead of unappealing c-style "syntax confetti"
- Try to update the language a little to fit with other procedural languages today
- Try to stay mostly backwards compatible with Lua, and keep the spirit of the language.
