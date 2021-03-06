do ->

  ls = window.localStorage

  fn = $.cache = (arg...) ->
    # switch
    switch arg.length
      when 0 then ls # $.cache()
      when 1
        switch $.type arg[0]
          when 'string' then fn.get arg... # $.cache(key)
          else fn.set arg... # $.cache({arg...})
      when 2 then fn.set arg... # $.cache(key, value)
      else ls # unknown

  fn.namespace = 'cache'
  fn.prefix = (key) -> "#{fn.namespace}::#{key}"

  fn.get = (key) -> $.parseJson ls.getItem fn.prefix key

  fn.set = (arg...) ->
    fn.check()
    switch arg.length
      when 1
        for key, value of arg[0]
          key = fn.prefix key
          if !value? then return ls.removeItem key
          ls.setItem key, $.parseString value
      when 2
        [key, value] = arg
        key = fn.prefix key
        if !value? then return ls.removeItem key
        ls.setItem key, $.parseString value
    ls

  fn.clear = ->
    temp = {}
    list = $.Cache.list

    for key in list
      temp[key] = fn.get key

    ls.clear() # clear

    # rewrite
    for key in list when temp[key]?
      fn.set key, temp[key]

    ls

  fn._limit = (if app.os == 'ios' then 2 else 4) * 1024 * 1024
  fn.check = ->
    if $.parseString($.cache()).length > fn._limit
      $.i 'cache', 'cleared because localStorage was full'
      fn.clear()

# cache
$.Cache = (name, defaultProp) ->

  ($.Cache.list or= []).push name

  # $.fn
  fn = (arg...) ->
    # switch
    switch arg.length
      when 0 then fn.data # $.fn()
      when 1
        switch $.type arg[0]
          when 'string' then fn.get arg... # $.fn(key)
          else fn.set arg... # $.fn({arg...})
      when 2 then fn.set arg... # $.fn(key, value)
      else fn.data # unknown

  fn.get = (key) -> fn.data[key]

  fn.set = (arg...) ->
    switch arg.length
      when 1
        for key, value of arg[0]
          if !value? then fn.remove key
          else fn.data[key] = value
      when 2
        [key, value] = arg
        if !value? then fn.remove key
        else fn.data[key] = value
    fn.save()

  # remove
  fn.remove = (key) -> delete fn.data[key]

  # save
  fn.save = ->
    $.cache name, fn.data
    fn.data

  # clear
  fn.clear = ->
    fn.data = _.clone fn._data
    fn.save()

  # init
  fn._data = _.clone defaultProp
  fn.data = $.extend {}, fn._data, $.cache(name)

  # return
  fn