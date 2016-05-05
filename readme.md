# LunaScript

A language that compiles to Lua, based largely on MoonScript and CoffeeScript. Compiler and language draft are works in progress.

## Language Features

### Comments
Normal lua comments:
```moon
-- this is a comment
-- this is another comment
```

Multi-line comments are fenced with `---`
```moon
---
some
multi-line
commenting
---
```

### Variables and Scope
Variable scoping rules are the same as in lua, except instead of `local`, use `let`. Any variables declared with `let` are localized at the head of the block.
```moon
let foo = 'bar'
do
  let a = 1
  let b = 2
```
```lua
-- lua output
local foo
foo = bar
do
  local a, b
  a = 1
  b = 2
end
```

### Strings
Normal strings:
```moon
let hello = 'world'
let foo = "bar"
let escaped = "i have \"quotes\" inside"
```

Luna uses `"""` for multiline strings. Initial indentation is ignored, and escapes work the same as in regular strings.
```moon
let ascii = """
            Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt
            ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco
            laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in
            voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat
            cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
            """
```
```lua
-- lua output:
local ascii = "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt\nut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco\nlaboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in\nvoluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat\ncupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
```

### Assignment Operators
```moon
let counter = 0
counter += 1
```

Available: `+=`, `-=`, `*=`, `/=`, `..=`, `and=`, `or=`

### Equality Operator Aliases
```moon
assert 10 == 10
assert 10 is 10

assert 0 ~= 100
assert 0 isnt 100
```

### Functions
```moon
let sayHello = -> print 'hello'

let add = (a, b) -> a + b

-- can drop parentheses with only one argument
let square = n -> n * n
let cube = n -> n * square n
```

### Tables
```moon
let song = {'do', 're', 'mi', 'fa', 'so'}

-- newlines replace commas
let bits = {
  1, 0, 1
  0, 0, 1
  1, 1, 0
}

-- literal keys need no braces
let countries = {
  'United States' = {
    size = 'big'
    population = 'a lot'
  }
  'England' = {
    size = 'not as big'
    population = 'probably smaller'
  }
}

let importantNumbers = {
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
```moon
for char in "hello world":gmatch '.'
  print char
```

### Array Table Loops: `for ... of`
```moon
let items = { 'eggs', 'milk', 'cheese', 'bread' }

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
let hundred = 1 to 100
```

### Slices
```moon
let slice = content[1 to 10]
let everyOther = content[1 to 10 by 2]
let reversed = content[10 to 1 by -1]
let reversed = content[10 to 1] -- implicit -1 when the second number is less than the first

let firstTen = content[to 10] -- if omitted, starts at 1
```

Using the `#` operator for the length of the table.
```moon
let copy = content[to #]
let reversed = content[# to 1]
```

### While
```moon
while notEnoughMoney()
  getMoney()
```

### Comprehensions using `every`
```moon
let numbers = every number for number of numbers
let letters = every letter for letter in sentence:gmatch '.'

-- short form:
let numbers = every number of numbers
let letter = every letter in sentence:gmatch '.'

-- conditions with `when`
let vowels = every letter in sentence:gmatch '.' when 'aeiou':find letter

-- multiline: split `for` and `when` on their own line
let vowels = every letter
  for letter in sentence:gmatch '.'
  when 'aeiou':find letter

-- recursive
let grid = every {x, y}
  for x of 1 to 100
  for y of 1 to 100

-- return two values for key-value pairs
let people = {
  { name = 'Bob',   status = 'Happy' }
  { name = 'Larry', status = 'Sad' }
}

let statusMap = every person.name, person.status
  for person of people
```
