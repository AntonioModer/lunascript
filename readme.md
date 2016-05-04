# LunaScript

A language that compiles to Lua, based largely on MoonScript and CoffeeScript. Compiler and language draft are works in progress.

## Language Rundown

```lua
-- variables
-- localized automatically at head of scope (local high, hello, a, b, c)
high = 5
hello = 'world'
a, b, c = 1, 2, 3

global Constant = 'IMPORTANT GLOBAL VALUE'

-- names can have dashes, compiles to camelCase equivalent
assert high-five == highFive

-- assignment operators
counter or= math.huge
counter and= 0
counter += 1
counter *= 9999
counter /= 0 -- oops

-- functions
say-hello = -> print 'hello'
add = (a, b) -> a + b

-- drop parentheses on single arg
square = n -> n * n

-- drop parens on function calls w/ args
call something, using, stuff

-- table literals
song = {'do', 're', 'mi', 'fa', 'so'}

-- newlines replace commas
bits = {
  1, 0, 1
  0, 0, 1
  1, 1, 0
}

-- literal keys need no braces
countries = {
  'United States' = {
    size = 'big'
    population = 'a lot'
  }
  'England' = {
    size = 'not as big'
    population = 'probably smaller'
  }
}
importantNumbers = {
  3.14 = 'pi'
  42 = 'life'
  420 = 'blaze it'
}

test = {
  {
    'hello'
    'world'
  } = {
    'foo'
    'bar'
  }
}

-- conditions + some English-readable operator aliases
if world is 'safe'
  chill()
elseif world isnt 'stable'
  panic()
else
  cry()

-- switch statement
switch value
  when 1
    print 'value is 1'
  when 2
    print 'value is 2'
  else
    print 'value is too damn high'

-- normal lua iterator loops
for char in "hello world":gmatch '.'
  print char

-- while loop
while frustrated()
  scream()

-- nicer table loops with `of`
-- loops through all key/value pairs
-- value before index
items = { 'eggs', 'milk', 'cheese', 'bread' }
for item, i of items
  print i .. ': ' .. item

scores =
  'Player 1' = 5
  'Player 2' = 10

for score, player of scores
  print player .. ' scored ' .. score

-- ranges
for num of 1 to 10
  print num

-- comprehensions
letters = every letter for letter in sentence:gmatch '.'

-- short form
letters = every letter in sentence:gmatch '.'

-- conditions
vowels = every vowel of letters when 'aeiou':find vowel

-- split it up on lines
vowels = every vowel
  for vowel of letters
  when 'aeiou':find vowel

-- expressionize it
gibberish = table.concat every vowel
  for vowel of letters
  when 'aeiou':find vowel

-- recursion
coords = every {x, y}
  for x of 1 to 100
  for y of 1 to 100
  --> { {1, 1}, {1, 2}, ... }

-- give two values to assign key/value pairs
hashed = every pos, true for pos of coords
  --> { [{1, 1}] = true, [{1, 2}] = true, ... }
```
