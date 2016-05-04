# LunaScript

A language that compiles to Lua, based largely on MoonScript and CoffeeScript. Compiler and language draft are works in progress.

## Language Rundown

```
-- variables
-- localized automatically at head of scope (local high, hello, a, b, c)
high = 5
hello = 'world'
a, b, c = 1, 2, 3

global Constant = 'IMPORTANT GLOBAL VALUE'

-- assignment operators
counter or= math.huge
counter and= 0
counter += 1
counter *= 9999
counter /= 0 -- oops

-- drop parens on function calls w/ args
call something, using, stuff

-- conditions + some English-readable operator aliases
if world is 'safe' -- ==
  chill()
elseif world isnt 'stable' -- ~=
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

-- loops
for i = 99, 0, -1
  print i .. ' bottles of beer on the wall'

for i, v in ipairs { 1, 2, 3 }
  print i, v

while frustrated()
  scream()

-- nicer table loops with `of`
items = { 'eggs', 'milk', 'cheese', 'bread' }
for item, i of items
  print i .. ': ' .. item

-- range syntax
hundred = 1 to 100 -- {1, 2, ..., 100}

for num of hundred
  if num % 2 isnt 0
    print num .. ' is odd!'

-- `step` keyword
-- intelligently compiles to `for i=101, 1, -2 do ... end`
for num of 101 to 1 step -2
  print num .. ' is most definitely odd'

-- comprehensions
evens = every n for n of 1 to 100 while n % 2 is 0

-- or multiline, if you prefer
evens = every n
  for n of 1 to 100
  while n % 2 is 0

-- recursion
coords = every {x, y}
  for x of 1 to 100
  for y of 1 to 100
  --> { {1, 1}, {1, 2}, ... }

-- give two values to assign key/value pairs
hashed = pos, true for pos of coords
  --> { [{1, 1}] = true, [{1, 2}] = true, ... }

-- fun functions!
fun hello
  print 'world', 1, 2, 3

fun test(something)
  something 1, 2

test fun(a, b) print a + b --> 3

-- allow parens to remove ambiguity
try first(1, 2, 3), second(1, 2, 3), third(1, 2, 3)

-- rest: automatic ... assign to array
fun rests(head, ...rest)
  print head, rest[#rest]

-- `method` to accept implicit self
method move(distance)
  self.position += distance

-- tables
-- ...
-- ¯\_(ツ)_/¯

-- classes/objects
-- possibly closure based?
class Point extends Super

  -- can have multiple `extends` statements to borrow methods in order
  -- the last `extends` has priority in property conflicts
  -- it might be better to error on a conflict, however
  extends SomeMixin
  extends SomeOtherMixin

  -- localize a method to make it private
  local method stringify
    '(' .. self.x .. ',' .. self.y .. ')'

  -- normal variables indexed to instance
  x = 0
  y = 0

  -- static variables
  static count = 0

  method new(x, y)
    self.x, self.y = x, y -- NOTE: consider borrowing `@`
    self.__class.count += 1

  method print()
    print stringify self

origin = Point 0, 0
origin:print()     --> (0, 0)
print Point.count  --> 1
print origin.count --> nil

-- theoretical compiled lua
local Point
do
  local __class = { __name = 'Point' }
  local __static = {}

  for k,v in pairs(Super) do
    __class[k] = v
  end

  for k,v in pairs(SomeMixin) do
    __class[k] = v
  end

  for k,v in pairs(SomeOtherMixin) do
    __class[k] = v
  end

  local function stringify(self)
    return '(' .. self.x .. ',' .. self.y .. ')'
  end

  __class.x = 0
  __class.y = 0

  __static.count = 0

  __class.new = function(self, x, y)
    self.x, self.y = x, y
    self.__class.count = self.__class.count + 1
  end

  __class.print = function(self)
    print(stringify(self))
  end

  local function __call(_, ...)
    local __instance = setmetatable({ __class = __class }, { __index = __class })
    if __instance.new then
      __instance:new(...)
    end
    return __instance
  end

  local function __index(_, key, value)
    return rawget(__static, key)
  end

  setmetatable(__class, { __call = __call, __index = __index })

  Point = __class
end
```
