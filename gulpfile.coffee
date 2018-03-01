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

  await $$.task('kokoro')()

  await $$.lint './source/**/*.styl'

  await $$.lint [
    './gulpfile.coffee'
    './source/**/*.coffee'
  ]