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

Only because I'm annoyed with a few things I can't do with regular Lua, while not wanting to use another full-blown entirely different language that has its own sets of limitations and lack of considerations when it comes to some things.

## Syntax

- `Name` is the lua pattern `[A-Za-z_][A-Za-z0-9_]*`
- `String` is the lua pattern `%b""`, `%b''`, or `%[%[.-%]%]` (accounting for escape characters)
- `Number` is the lua pattern `[0-9]*%.[0-9]+`, or `0x[0-9A-Fa-f]`
- `Newline` is the lua pattern `[\r\n]+`

```
block ::= { expression [ expression-terminator ] }

expression ::=
  infixed-expression |
  if-expression |
  for-expression |
  while-expression |
  do-expression |
  repeat-expression |
  function-definition |
  function-call |
  unary-expression |
  assign-expression |
  binary-expression |
  literal-value

infixed-expression ::= '(' expression ')'

expression-list ::= expression { ',' expression }

expression-prefix ::= variable | function-call | infixed-expression


if-expression ::= 'if' expression 'then' block { 'elseif' block } [ 'else' block ] 'end'

for-expression ::= 'for' variable-list 'in' expression-list 'do' block 'end'

while-expression ::= 'while' expression 'do' block 'end'

do-expression ::= 'do' block 'end'

repeat-expression ::= 'repeat' block 'until' expression


assign-expression ::= variable-list assign-operator expression-list

unary-expression ::= unary-operator expression

binary-expression ::= expression binary-operator expression


function-definition ::= 'function' [ function-name ] '(' function-parameters ')' block 'end'

function-name ::= Name { '.' Name } [ ':' Name ]

function-parameters ::= variable-list [',' '...'] | '...'

function-call ::= expression-prefix '(' expression-list ')'


variable ::= Name | expression-prefix '[' expression ']' | expression-prefix '.' Name

variable-list ::= variable { ',' variable }


literal-value ::= 'true' | 'false' | 'nil' | '...' | table-definition | Name | String | Number


unary-operator ::= '-' | 'not' | '#' | '~'

binary-operator ::=  '+' | '-' | '*' | '/' | '//' | '^' | '%' |
  '&' | '~' | '|' | '>>' | '<<' | '..' |
  '<' | '<=' | '>' | '>=' | '==' | '~=' |
  'and' | 'or'

assign-operator ::= '+=' | '-=' | '*=' | '/=' | '..=' | 'and=' | 'or='


table-definition ::= '{' [table-pair-list] '}'

table-pair-list ::= table-pair { table-pair-separator table-pair } [table-pair-separator]

table-pair ::= '[' expression ']' '=' expression | Name '=' expression | expression

table-pair-separator ::= ',' | ';'

expression-terminator ::= ';' | Newline
```
