# require

$$ = require 'fire-keeper'
{$, _, Promise, gulp} = $$.library
co = Promise.coroutine

# function

exclude = (arg) ->

  list = switch $.type arg
    when 'array' then arg
    when 'string' then [arg]
    else throw new Error 'invalid argument type'

  _.uniq list.push '!**/include/**'

  # return
  list

# task

###

  lint

###

$$.task 'lint', co ->

  yield $$.task('link')()

  yield $$.lint './source/**/*.styl'

  yield $$.lint [
    './gulpfile.coffee'
    './source/**/*.coffee'
  ]