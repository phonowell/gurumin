# require

$$ = require 'fire-keeper'
{$, _, Promise} = $$.library
co = Promise.coroutine

# function

exclude = $$.fn.excludeInclude

# task

###

  lint()

###

$$.task 'lint', co ->

  yield $$.task('kokoro')()

  yield $$.lint './source/**/*.styl'

  yield $$.lint [
    './gulpfile.coffee'
    './source/**/*.coffee'
  ]