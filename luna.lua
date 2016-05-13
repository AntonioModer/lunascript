local lexer = require 'lexer'

local inspect = require 'inspect'

local source = [["hell\"o world" "test" 123 foobar]]

local tokens, err = lexer.tokenize(source)

print(tokens and inspect(tokens) or err) -- TODO: create a decent pretty-printer
