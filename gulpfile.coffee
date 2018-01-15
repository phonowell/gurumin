# require

$$ = require 'fire-keeper'
{$, _} = $$.library

# function

exclude = $$.fn.excludeInclude

# task

###

  lint()

###

$$.task 'lint', ->

  yield $$.task('kokoro')()

  yield $$.lint './source/**/*.styl'

  yield $$.lint [
    './gulpfile.coffee'
    './source/**/*.coffee'
  ]