$ = require 'fire-keeper'
{_} = $

# return
module.exports = ->

  # await $.task('kokoro')()

  await $.lint_ [
    './*.md'
    './doc/**/*.md'
    './gulpfile.coffee'
    './source/**/*.coffee'
    './source/**/*.styl'
    './task/**/*.coffee'
    './test/**/*.coffee'
  ]