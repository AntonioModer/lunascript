## Syntax
```
block ::= { expression }

expression ::=
  assign-expression |
  if-expression |
  for-expression |
  while-expression |
  do-expression |
  function-expression |
  Name | String | Number |
  `(` expression `)` |
  { ',' expression }

assign-expression ::= name-list '=' expression

if-expression ::= 'if' expression 'then' block 'end'

for-expression ::= 'for' name-list 'in' expression 'do' block 'end'

while-expression ::= 'while' expression 'do' block 'end'

do-expression ::= 'do' block 'end'

function-expression ::= 'function' Name { '.' Name } [ ':' Name ]

name-list ::= Name { ',' Name }
```

- `Name` is the lua pattern `[A-Za-z_][A-Za-z0-9_]*`
- `String` is the lua pattern `%b""`, `%b''`, or `%[%[.-%]%]` (accounting for escape characters)
- `Number` is the lua pattern `[0-9]*%.[0-9]+`, or `0x[0-9A-Fa-f]`
