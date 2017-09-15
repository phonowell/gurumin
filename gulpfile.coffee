# require

$$ = require 'fire-keeper'
{$, _, Promise} = $$.library
co = Promise.coroutine

# function

exclude = (arg) ->

  list = switch $.type arg
    when 'array' then arg
    when 'string' then [arg]
    else throw new Error 'invalid argument type'

  list.push '!**/include/**'
  list = _.uniq list

  # return
  list

# task

###

  lint

###

$$.task 'lint', co ->

  yield $$.task('kokoro')()

  yield $$.lint './source/**/*.styl'

  yield $$.lint [
    './gulpfile.coffee'
    './source/**/*.coffee'
  ]
