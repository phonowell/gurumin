do ->

  fn = $.hash = (key) ->
    data = $.hash.parse()
    if !key then return data
    data[key]

  fn.parse = (
    url = (
      if cordova?.notCordova then location.hash
      else $.session '_route'
    ) or ''
  ) ->
    res = {}
    for a in url.replace(/.*#/, '').replace(/[\?&].*/, '').split(';') when a.length
      b = a.split '='
      res[b[0]] = decodeURIComponent b[1]
    res