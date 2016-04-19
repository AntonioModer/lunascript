local tokenize = require 'luna'.tokenize

describe('tokenizer', function()
  it('ignores comments', function()
    assert.are.same(tokenize('--'), {})
    assert.are.same(tokenize('-- hello world'), {})
    assert.are.same(tokenize('-- hello world\n--hello moon'), {})
    assert.are.same(tokenize('--[[\ntest\ntest\n]]'), {})
  end)

  it('ignores whitespace', function()
    assert.are.same(tokenize(' '), {})
    assert.are.same(tokenize('\n\n\n'), {})
    assert.are.same(tokenize('\r\n\r\n\r\n'), {})
  end)

  it('matches all symbols', function()
    assert.are.same(tokenize('...'), {{ type = 'literal-vararg', value = '...' }})

    assert.are.same(tokenize('= += -= *= /= ..='), {
      { type = 'assign-operator', value = '=' },
      { type = 'assign-operator', value = '+=' },
      { type = 'assign-operator', value = '-=' },
      { type = 'assign-operator', value = '*=' },
      { type = 'assign-operator', value = '/=' },
      { type = 'assign-operator', value = '..=' },
    })

    assert.are.same(tokenize('// >> << .. <= >= ~= =='), {
      { type = 'binary-operator', value = '//' },
      { type = 'binary-operator', value = '>>' },
      { type = 'binary-operator', value = '<<' },
      { type = 'binary-operator', value = '..' },
      { type = 'binary-operator', value = '<=' },
      { type = 'binary-operator', value = '>=' },
      { type = 'binary-operator', value = '~=' },
      { type = 'binary-operator', value = '==' },
    })

    assert.are.same(tokenize('+ * / ^ % & | < > - ~'), {
      { type = 'binary-operator', value = '+' },
      { type = 'binary-operator', value = '*' },
      { type = 'binary-operator', value = '/' },
      { type = 'binary-operator', value = '^' },
      { type = 'binary-operator', value = '%' },
      { type = 'binary-operator', value = '&' },
      { type = 'binary-operator', value = '|' },
      { type = 'binary-operator', value = '<' },
      { type = 'binary-operator', value = '>' },
      { type = 'binary-operator', value = '-' },
      { type = 'binary-operator', value = '~' },
    })

    assert.are.same(tokenize('( ) , . : [ ] ;'), {
      { type = 'infix-open',             value = '(' },
      { type = 'infix-close',            value = ')' },
      { type = 'list-separator',         value = ',' },
      { type = 'index-name',             value = '.' },
      { type = 'index-self',             value = ':' },
      { type = 'index-expression-open',  value = '[' },
      { type = 'index-expression-close', value = ']' },
      { type = 'semicolon',              value = ';' },
    })
  end)

  it('matches unary symbols correctly', function()
    assert.are.same(tokenize('#test -test ~test'), {
      { type = 'unary-operator', value = '#' },
      { type = 'literal-name',   value = 'test' },
      { type = 'unary-operator', value = '-' },
      { type = 'literal-name',   value = 'test' },
      { type = 'unary-operator', value = '~' },
      { type = 'literal-name',   value = 'test' },
    })
  end)

  it('matches int and decimal numbers', function()
    assert.are.same(tokenize('420 .69 3.14159'), {
      { type = 'literal-number', value = '420' },
      { type = 'literal-number', value = '.69' },
      { type = 'literal-number', value = '3.14159' },
    })
  end)

  it('matches hex numbers', function()
    assert.are.same(tokenize('0x000 0xFFF 0xabcdefABCDEF0123456789 0xdEaDbEEF'), {
      { type = 'literal-number', value = '0x000' },
      { type = 'literal-number', value = '0xFFF' },
      { type = 'literal-number', value = '0xabcdefABCDEF0123456789' },
      { type = 'literal-number', value = '0xdEaDbEEF' },
    })
  end)

  it('matches strings', function()
    assert.are.same(tokenize("\"hello\" 'world' [[hello\n luna!]]"), {
      { type = 'literal-string', value = '"hello"' },
      { type = 'literal-string', value = "'world'" },
      { type = 'literal-string', value = "[[hello\n luna!]]"},
    })
  end)

  it('accounts for escapes', function()
    pending('not implemented yet')
  end)

  it('matches names', function()
    assert.are.same(tokenize('foo _bar baz100_'), {
      { type = 'literal-name', value = 'foo' },
      { type = 'literal-name', value = '_bar' },
      { type = 'literal-name', value = 'baz100_' },
    })
  end)

  it('matches keywords', function()
    assert.are.same(tokenize('if then elseif else end for in do while function break return repeat until and or not true false nil'), {
      { type = 'if',       value = 'if' },
      { type = 'then',     value = 'then' },
      { type = 'elseif',   value = 'elseif' },
      { type = 'else',     value = 'else' },
      { type = 'end',      value = 'end' },
      { type = 'for',      value = 'for' },
      { type = 'in',       value = 'in' },
      { type = 'do',       value = 'do' },
      { type = 'while',    value = 'while' },
      { type = 'function', value = 'function' },
      { type = 'break',    value = 'break' },
      { type = 'return',   value = 'return' },
      { type = 'repeat',   value = 'repeat' },
      { type = 'until',    value = 'until' },

      { type = 'binary-operator', value = 'and' },
      { type = 'binary-operator', value = 'or' },
      { type = 'unary-operator',  value = 'not' },

      { type = 'literal-constant', value = 'true' },
      { type = 'literal-constant', value = 'false' },
      { type = 'literal-constant', value = 'nil' },
    })
  end)
end)
