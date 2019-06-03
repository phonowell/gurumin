$ = require 'fire-keeper'
{_} = $

# return
module.exports = ->

  # await $.task('kokoro')()

  await $.lint_ [
    './**/*.coffee'
    './**/*.md'
    './**/*.styl'
    '!**/nib/**'
    '!**/node_modules/**'
  ]
