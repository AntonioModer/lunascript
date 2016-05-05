return {
  -- comments
  { type = 'comment',    match = '%-%-[^\r\n]+', ignore = true },

  -- whitespace
  { type = 'space',             match = '[ \t]+'  }, -- space character
  { type = 'line-break',        match = '[\r\n]+' }, -- line break character - treat multiple as a single break
  { type = 'line-continuation', match = '\\%s+'   }, -- line continuation: continue current line to next, ignores indentation

  { type = 'number', match = '0x%x+' },               -- hex number
  { type = 'number', match = '%d*%.?%d+e%d+' },       -- sci notation (short form)
  { type = 'number', match = '%d*%.?%d+E[%+%-]%d+' }, -- sci notation (long form)
  { type = 'number', match = '%d*%.?%d+' },           -- decimal number

  { type = 'string', head = '"',   body = {'\\.', '.'}, tail = '"'   }, -- double quoted string
  { type = 'string', head = "'",   body = {'\\.', '.'}, tail = "'"   }, -- single quoted string
  { type = 'string', head = '[[',  body = {'\\.', '.'}, tail = ']]'  }, -- multiline string
  { type = 'string', head = '"""', body = {'\\.', '.'}, tail = '"""' }, -- doc string

  -- symbols, grouped by char length
  { type = 'vararg', match = '%.%.%.' },

  { type = 'floor-divide',  match = '//'   },
  { type = 'concat',        match = '%.%.' },
  { type = 'equality',      match = '==' },
  { type = 'greater-equal', match = '>=' },
  { type = 'less-equal',    match = '<=' },

  { type = 'plus',           match = '%+' },
  { type = 'minus',          match = '%-' },
  { type = 'multiply',       match = '%*' },
  { type = 'divide',         match = '/'  },
  { type = 'modulo',         match = '%%' },
  { type = 'len',            match = '#'  },
  { type = 'power',          match = '^'  },
  { type = 'greater',        match = '>'  },
  { type = 'less',           match = '<'  },
  { type = 'dot',            match = '%.' },
  { type = 'colon',          match = ':'  },
  { type = 'assign',         match = '='  },
  { type = 'comma',          match = ','  },
  { type = 'open-bracket',   match = '%[' },
  { type = 'closed-bracket', match = '%]' },
  { type = 'open-paren',     match = '%(' },
  { type = 'closed-paren',   match = '%)' },
  { type = 'open-brace',     match = '{'  },
  { type = 'closed-brace',   match = '}'  },

  -- keywords
  { type = 'if',       find = 'if',       match = '%l+' },
  { type = 'elseif',   find = 'elseif',   match = '%l+' },
  { type = 'else',     find = 'else',     match = '%l+' },
  { type = 'then',     find = 'then',     match = '%l+' },
  { type = 'while',    find = 'while',    match = '%l+' },
  { type = 'do',       find = 'do',       match = '%l+' },
  { type = 'local',    find = 'local',    match = '%l+' },
  { type = 'global',   find = 'global',   match = '%l+' },
  { type = 'switch',   find = 'switch',   match = '%l+' },
  { type = 'when',     find = 'when',     match = '%l+' },
  { type = 'for',      find = 'for',      match = '%l+' },
  { type = 'in',       find = 'in',       match = '%l+' },
  { type = 'of',       find = 'of',       match = '%l+' },
  { type = 'to',       find = 'to',       match = '%l+' },
  { type = 'by',       find = 'by',       match = '%l+' },
  { type = 'every',    find = 'every',    match = '%l+' },
  { type = 'import',   find = 'import',   match = '%l+' },
  { type = 'continue', find = 'continue', match = '%l+' },
  { type = 'break',    find = 'break',    match = '%l+' },
  { type = 'and',      find = 'and',      match = '%l+' },
  { type = 'or',       find = 'or',       match = '%l+' },
  { type = 'not',      find = 'not',      match = '%l+' },
  { type = 'true',     find = 'true',     match = '%l+' },
  { type = 'false',    find = 'false',    match = '%l+' },
  { type = 'is',       find = 'is',       match = '%l+' },
  { type = 'isnt',     find = 'isnt',     match = '%l+' },

  -- lua names
  { type = 'name', match = '[%a_][%w_]*' },
}
