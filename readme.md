# LunaScript

A language that compiles to Lua, based largely on MoonScript and CoffeeScript. Compiler and language draft are works in progress.

## Language Rundown

### Variables and Scope
Variables are automatically localized at the head of scope.
```moon
high = 5
hello = 'world'
a, b, c = 1, 2, 3
```
```lua
local high, hello, a, b, c
high = 5
hello = 'world'
a, b, c = 1, 2, 3
```

Scopes underneath will try to reach the variables above them. Use `local` to prevent this.
```moon
foo = 'bar'
do
  foo = 'baz'
print foo --> 'baz'

do
  local foo = 'bullshit'
print foo --> 'baz'
```

Use `global` for non-locals.
```moon
global Constant = "Important Value"
```

### Assignment Operators
```moon
counter += 1
```

Available: `+=`, `-=`, `*=`, `/=`, `..=`, `and=`, `or=`

## Equality Operator Aliases
```moon
assert 10 == 10
assert 10 is 10

assert 0 ~= 100
assert 0 isnt 100
```

### Functions
```moon
sayHello = -> print 'hello'

add = (a, b) -> a + b

-- can drop parentheses with only one argument
square = n -> n * n
```

### Tables
```moon
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
```

### Conditions
```moon
if world is 'safe'
  chill()
elseif world isnt 'stable'
  panic()
else
  cry()
```

### Switch
```moon
switch value
  when 1
    print 'value is 1'
  when 2
    print 'value is 2'
  else
    print 'value is too damn high'
```

### Iterator Loops: `for ... in`
Lua iterator loop:
```moon
for char in "hello world":gmatch '.'
  print char
```

### Array Table Loops: `for ... of`
```moon
items = { 'eggs', 'milk', 'cheese', 'bread' }

print 'we need:'
for item of items
  print item
```

### Ranges
```moon
for n of 1 to 10
  print n .. ' is a number'

for n of 2 to 10 by 2
  print n .. ' is an even number'

-- assign it to a table
hundred = 1 to 100
```

### Slices
```moon
slice = content[1 to 10]
everyOther = content[1 to 10 by 2]
reversed = content[10 to 1 by -1]
reversed = content[10 to 1] -- implicit -1 when the second number is less than the first

firstTen = content[to 10] -- if omitted, starts at 1
```

Using the `#` operator for the length of the table.
```moon
copy = content[to #]
reversed = content[# to 1]
```

### While
```moon
while notEnoughMoney()
  getMoney()
```

### Comprehensions using `every`
```moon
numbers = every number for number of numbers
letters = every letter for letter in sentence:gmatch '.'

-- short form:
numbers = every number of numbers
letter = every letter in sentence:gmatch '.'

-- conditions with `when`
vowels = every letter in sentence:gmatch '.' when 'aeiou':find letter

-- multiline: split `for` and `when` on their own line
vowels = every letter
  for letter in sentence:gmatch '.'
  when 'aeiou':find letter

-- recursive
grid = every {x, y}
  for x of 1 to 100
  for y of 1 to 100

-- return two values for key-value pairs
people = {
  { name = 'Bob',   status = 'Happy' }
  { name = 'Larry', status = 'Sad' }
}

statusMap = every person.name, person.status
  for person of people
```
