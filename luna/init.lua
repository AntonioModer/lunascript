local tokenize = require 'luna.tokenize'
local parse = require 'luna.parse'
local translate = require 'luna.translate'
local compile = require 'luna.compile'
local dump = require 'luna.dump'

local path = ...
local _, content = io.input(path), io.read('*a'), io.close(), io.input()

local tokens = tokenize(content)
local tree = parse(tokens)
local translated = translate(tree)
local output = compile(translated)


local inspect = require 'inspect'

-- print(content)
-- print(inspect(tokens))
-- dump(tree)
-- dump(translated)
print(output)
