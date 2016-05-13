
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
    pos = 1,
    line = 1,
    col = 1,

    match = function (self, pattern)
      local position, value = source:match('()(' .. pattern .. ')', self.pos)
      return position == self.pos and value
    end,

    advance = function (self, distance)
      self.pos = self.pos + distance
      self.col = self.col + distance
    end,

    walk = function (self, pattern)
      local value = self:match(pattern)
      if value then
        return value, self.line, self.col, self:advance(#value)
      end
    end,

    capture = function (self, pattern, tokentype)
      local value, line, col = self:walk(pattern)
      return value and Token(tokentype, value, line, col) or nil
    end,
  }
end

-- token matchers
local function WhiteSpace(lexer)
  return lexer:capture('[ \t]+', 'white-space')
end

local function Number(lexer)
  return lexer:capture('%d*%.?%d+', 'number')
end

local function Name(lexer)
  return lexer:capture('[%a_][%w_]*', 'name')
end

local function String(lexer)
  local value, line, col = lexer:walk('"')
  if value then
    local content = {}
    while not lexer:walk('"') do
      local char = lexer:walk('\\.') or lexer:walk('.')
      if not char then return end
      table.insert(content, char)
    end
    return Token('string', '"' .. table.concat(content) .. '"', line, col)
  end
end

-- convert source to tokens
local function tokenize(source)
  local tokens = {}
  local lexer = Lexer(source)

  while lexer.pos <= #source do
    local token = WhiteSpace(lexer)
      or Number(lexer)
      or Name(lexer)
      or String(lexer)

    if token then
      table.insert(tokens, token)
    else
      local line, col = lexer.line, lexer.col
      local char = lexer.source:sub(lexer.pos, lexer.pos)
      local errformat = '%d:%d: unknown character "%s"'
      local errmsg = errformat:format(line, col, char)
      return nil, errmsg
    end
  end

  return tokens
end


return { tokenize = tokenize }
