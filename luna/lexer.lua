
-- token interface
local function Token(tokentype, value, line, col)
  return {
    type = tokentype,
    value = value,
    line = line,
    col = col,
  }
end

-- lexer object
local function Lexer(source)
  return {
    pos = 1,  -- current position in the source
    line = 1, -- current line
    col = 1,  -- current column

    -- search for a match at the current position from a given pattern
    -- if a match is found, returns the match
    match = function (self, pattern)
      local position, value = source:match('()(' .. pattern .. ')', self.pos)
      return position == self.pos and value
    end,

    -- advance the position by a certain distance
    -- automatically increments the line number as needed
    advance = function (self, distance)
      for i=1, distance do
        if self:getchar() == '\n' then
          self.line = self.line + 1
          self.col = 1
        else
          self.col = self.col + 1
        end
        self.pos = self.pos + 1
      end
    end,

    -- checks for a match of a pattern at the current position
    -- if one is found, return the value and advance the position by the length of it
    walk = function (self, pattern)
      local value = self:match(pattern)
      if value then
        return value, self.line, self.col, self:advance(#value)
      end
    end,

    -- checks for a match of a pattern at the current position
    -- if one is found, return a token for it with the given type, and advance the position
    capture = function (self, pattern, tokentype)
      local value, line, col = self:walk(pattern)
      return value and Token(tokentype, value, line, col) or nil
    end,

    -- return the current character
    getchar = function (self)
      return source:sub(self.pos, self.pos)
    end,

    Space = function (self)
      return self:capture('%s*\\%s+', 'space')
      or self:capture('[ \t]+', 'space')
    end,

    LineBreak = function (self)
      return self:capture('%s*[\r\n]+', 'line-break')
    end,

    Number = function (self)
      return self:capture('%d+.%d+', 'number')
      or self:capture('%d+', 'number')
    end,

    Name = function (self)
      return self:capture('[%a_][%w_]*', 'name')
    end,

    String = function (self, head, tail)
      local value, line, col = self:walk(head)
      if value then
        local content = {}
        while not self:walk(tail) do
          local char = self:walk('\\.') or self:walk('.')
          if not char then return end
          table.insert(content, char)
        end
        return Token('string', head .. table.concat(content) .. tail, line, col)
      end
    end,

    Keyword = function (self, word)
      local value = self:match('%l+')
      if value == word then
        return Token(word, value, self.line, self.col), self:advance(#value)
      end
    end,

    Symbol = function (self, symbol, tokentype)
      return self:capture(symbol:gsub('(.)', '%%%1'), tokentype)
    end,
  }
end

-- convert source to tokens
local function tokenize(source)
  local tokens = {}
  local lexer = Lexer(source)

  while lexer.pos <= #source do
    local token = lexer:LineBreak() or lexer:Space()
      or lexer:Number()

      or lexer:Symbol('=', 'equals')

      or lexer:String('"', '"')
      or lexer:String("'", "'")

      or lexer:Keyword('let')

      or lexer:Name()

    if token then
      table.insert(tokens, token)
    else
      local line, col = lexer.line, lexer.col
      local char = source:sub(lexer.pos, lexer.pos)
      local errformat = '%d:%d: unknown character "%s"'
      local errmsg = errformat:format(line, col, char)
      return nil, errmsg
    end
  end

  return tokens
end


return { tokenize = tokenize }
