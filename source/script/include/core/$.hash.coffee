do ->

  # function

  fn = (key) -> fn.get key

  ###

    get([key])
    parse([url])

  ###

  fn.get = (key) ->

    data = fn.parse()
    if !key then return data
    data[key]

  fn.parse = (url) ->

    url or= (
      if cordova.notCordova then location.hash
      else $.session 'pathname'
    ) or ''

    list = if !url.length then []
    else
      url.replace /.*#/, ''
      .replace /[?&].*/, ''
      .split ';'

    res = {}
    for a in list when a.length
      b = a.split '='
      res[b[0]] = decodeURIComponent b[1]

    # return
    res

  # return
  $.hash = fn