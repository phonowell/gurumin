$.preload = (arg...) ->

  [list, callback] = switch arg.length
    when 1 then [arg[0], null]
    when 2 then arg
    else throw new Error 'invalid argument length'

  list = _.uniq switch $.type list
    when 'string' then list.split ' '
    when 'array' then list
    else throw new Error 'invalid list'

  def = $.Deferred()

  if !list.length
    def.resolve()
    callback?()
    return def.promise()

  # loader
  $loader = $ '<img>'
  $loader
  .on 'error', -> check()
  .on 'load', -> check $loader.attr 'src'

  # function

  check = (src) ->

    if !list.length
      $loader.remove()
      def.notify src
      def.resolve()
      callback?()
      return

    def.notify src
    next()

  do next = -> $loader.attr 'src', list.shift()

  # return
  def.promise()