## Syntax

- `Name` is the lua pattern `[A-Za-z_][A-Za-z0-9_]*`
- `String` is the lua pattern `%b""`, `%b''`, or `%[%[.-%]%]` (accounting for escape characters)
- `Number` is the lua pattern `[0-9]*%.[0-9]+`, or `0x[0-9A-Fa-f]`

```
block ::= { expression [ ';' ] }

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


if-expression ::= 'if' expression 'then' block { 'elseif' block } [ 'else' block ] 'end'

for-expression ::= 'for' variable-list 'in' expression-list 'do' block 'end'

while-expression ::= 'while' expression 'do' block 'end'

do-expression ::= 'do' block 'end'

repeat-expression ::= 'repeat' block 'until' expression


assign-expression ::= variable-list assign-operator expression-list

unary-expression ::= unary-operator expression

binary-expression ::= expression binary-operator expression


function-definition ::= 'function' [ variable ] '(' function-parameters ')' block 'end'

function-parameters ::= '...' |  variable-list [',' '...']

function-call ::= variable-prefix function-call-suffix { function-call-suffix }

function-call-suffix ::= { variable-index } [ variable-self-index ] '(' expression-list ')'


variable ::= variable-prefix { variable-index }

variable-prefix ::= literal-value | infix-expression

variable-index ::= variable-name-index | variable-expression-index

variable-name-index ::= '.' Name

variable-self-index ::= ':' Name

variable-expression-index ::= '[' expression ']'

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
```