# LunaScript

A language that compiles to Lua

## Ideas

- Everything is an expression
- 'import' shorthands for module requires
- Possible class system?
- Words over symbols, less syntactic confetti
- ASSIGNMENT OPERATORS PLEASE DEAR GOD

Something like this:
```lua
-- make importing stuff nicer
import 'something' --> local something = require 'something'
import 'some.stuff' --> local stuff = require 'some.stuff'
import 'lib' as module --> local module = require 'lib'

-- everything is an expression
-- tossing 'do' and 'then' out the window
status = if getMoney()
  'happy'
else
  'sadbois'
end

-- assign lots of stuff at once
a = b = c = 420

-- i wouldn't ever recommend doing this but this would be possible
a, b = x, y = foo, bar = 1337, 69
--> a = x = foo = 1337
--> b = y = bar = 69

-- looping has been limited to just tables, instead of iterators
-- use 'in' for array keys, 'of' for pairs
-- value before index
-- table key syntax stays
for value, key of { 1, 2, 3, hello = 'world', foo = 'bar' }
  print(key .. ' = ' .. value)
  --> 1 = 1
  --> 2 = 2
  --> 3 = 3
  --> hello = world
  --> foo = bar
end

-- comprehension that generates numbers vararg style, for flexibility
for num in { 1, 2, 3, 10 to 100 every 5 }
  print(num) --> 1, 2, 3, 10, 15, ..., 100
end

-- so you could also do this
a, b, c = 1 to 3 --> a = 1, b = 2, c = 3

-- copy a table
tab = { 1 to 10 }
copy = for n in tab
  n

-- note: not whitespace sensitive
-- this works too
copy = for n in tab n

-- did i mention how everything is an expression
if file = io.open('data.txt')
  while line = file:read()
    print(line)
  end
  file:close()
end

-- same function syntax, + argument defaults
function foo(hello = 'world')
  print('hello', hello)
end
foo()
foo('moon')

-- variables are auto localized at head of scope, so this isn't annoying anymore
-- because everyone loves stack overflows ¯\_(ツ)_/¯
function ping()
  pong()
end

function pong()
  ping()
end
```
