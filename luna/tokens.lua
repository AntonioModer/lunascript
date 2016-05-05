return {
  -- comments
  { type = 'comment', pattern = '%s*%-%-%-.-%-%-%-%s*', ignore = true }, -- multiline
  { type = 'comment', pattern = '%s*%-%-[^\r\n]*',      ignore = true }, -- single line

  -- whitespace
  { type = 'space',             pattern = '[ \t]+'  }, -- space character
  { type = 'line-break',        pattern = '[\r\n]+' }, -- line break character - treat multiple as a single break
  { type = 'line-continuation', pattern = '\\%s+'   }, -- line continuation: continue current line to next, ignores indentation

  { type = 'number', pattern = '0x%x+' },               -- hex number
  { type = 'number', pattern = '%d*%.?%d+e%d+' },       -- sci notation (short form)
  { type = 'number', pattern = '%d*%.?%d+E[%+%-]%d+' }, -- sci notation (long form)
  { type = 'number', pattern = '%d*%.?%d+' },           -- decimal number

  { type = 'string', head = '"""',   body = {'\\.', '.'}, tail = '"""'  }, -- multiline string
  { type = 'string', head = '"',     body = {'\\.', '.'}, tail = '"'    }, -- double quoted string
  { type = 'string', head = "'",     body = {'\\.', '.'}, tail = "'"    }, -- single quoted string

  -- symbols, grouped by char length
  { type = 'vararg', pattern = '%.%.%.' },

  { type = 'floor-divide',  pattern = '//'   },
  { type = 'concat',        pattern = '%.%.' },
  { type = 'equality',      pattern = '==' },
  { type = 'greater-equal', pattern = '>=' },
  { type = 'less-equal',    pattern = '<=' },

  { type = 'plus',           pattern = '%+' },
  { type = 'minus',          pattern = '%-' },
  { type = 'multiply',       pattern = '%*' },
  { type = 'divide',         pattern = '/'  },
  { type = 'modulo',         pattern = '%%' },
  { type = 'len',            pattern = '#'  },
  { type = 'power',          pattern = '^'  },
  { type = 'greater',        pattern = '>'  },
  { type = 'less',           pattern = '<'  },
  { type = 'dot',            pattern = '%.' },
  { type = 'colon',          pattern = ':'  },
  { type = 'assign',         pattern = '='  },
  { type = 'comma',          pattern = ','  },
  { type = 'open-bracket',   pattern = '%[' },
  { type = 'closed-bracket', pattern = '%]' },
  { type = 'open-paren',     pattern = '%(' },
  { type = 'closed-paren',   pattern = '%)' },
  { type = 'open-brace',     pattern = '{'  },
  { type = 'closed-brace',   pattern = '}'  },

  -- keywords
  { type = 'if',       find = 'if',       pattern = '%l+' },
  { type = 'elseif',   find = 'elseif',   pattern = '%l+' },
  { type = 'else',     find = 'else',     pattern = '%l+' },
  { type = 'then',     find = 'then',     pattern = '%l+' },
  { type = 'while',    find = 'while',    pattern = '%l+' },
  { type = 'do',       find = 'do',       pattern = '%l+' },
  { type = 'local',    find = 'local',    pattern = '%l+' },
  { type = 'global',   find = 'global',   pattern = '%l+' },
  { type = 'switch',   find = 'switch',   pattern = '%l+' },
  { type = 'when',     find = 'when',     pattern = '%l+' },
  { type = 'for',      find = 'for',      pattern = '%l+' },
  { type = 'in',       find = 'in',       pattern = '%l+' },
  { type = 'of',       find = 'of',       pattern = '%l+' },
  { type = 'to',       find = 'to',       pattern = '%l+' },
  { type = 'by',       find = 'by',       pattern = '%l+' },
  { type = 'every',    find = 'every',    pattern = '%l+' },
  { type = 'import',   find = 'import',   pattern = '%l+' },
  { type = 'continue', find = 'continue', pattern = '%l+' },
  { type = 'break',    find = 'break',    pattern = '%l+' },
  { type = 'and',      find = 'and',      pattern = '%l+' },
  { type = 'or',       find = 'or',       pattern = '%l+' },
  { type = 'not',      find = 'not',      pattern = '%l+' },
  { type = 'true',     find = 'true',     pattern = '%l+' },
  { type = 'false',    find = 'false',    pattern = '%l+' },
  { type = 'is',       find = 'is',       pattern = '%l+' },
  { type = 'isnt',     find = 'isnt',     pattern = '%l+' },

  -- lua names
  { type = 'name', pattern = '[%a_][%w_]*' },
}
