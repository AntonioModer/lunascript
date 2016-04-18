tokenize = require 'luna'.tokenize

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

    assert.are.same(tokenize('#test -test ~test'), {
      { type = 'unary-operator', value = '#' },
      { type = 'literal-name',   value = 'test' },
      { type = 'unary-operator', value = '-' },
      { type = 'literal-name',   value = 'test' },
      { type = 'unary-operator', value = '~' },
      { type = 'literal-name',   value = 'test' },
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
end)
