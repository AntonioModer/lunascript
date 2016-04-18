local path = ...
local tokenize = require(path .. '.tokenize')
local parse = require(path .. '.parse')
local translate = require(path .. '.translate')
local compile = require(path .. '.compile')

local function tolua(source)
  local tokens = tokenize(source)
  local tree = parse(tokens)
  local luatree = translate(tree)
  local output = compile(luatree)
  return output
end

return {
  tokenize = tokenize,
  parse = parse,
  translate = translate,
  compile = compile,
  tolua = tolua,
}
