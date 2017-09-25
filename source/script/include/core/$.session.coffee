do ->

  ss = window.sessionStorage

  # function

  fn = (arg...) ->
    switch arg.length
      when 0 then ss # $.session()
      when 1
        switch $.type arg[0]
          when 'string' then fn.get arg... # $.session(key)
          else fn.set arg... # $.session({key: value})
      when 2 then fn.set arg... # $.session(key, value)
      else ss # unknown

  ###

    clear()
    get(key)
    prefix(key)
    remove(key)
    set(key)
    size()

  ###

  fn.clear = -> ss.clear()

  fn.get = (key) -> $.parseJson ss.getItem fn.prefix key

  fn.prefix = (key) -> "cache::#{key}"

  fn.remove = (key) -> ss.removeItem fn.prefix key

  fn.set = (arg...) ->

    switch arg.length

      when 1
        for key, value of arg[0]
          if !value? then fn.remove key
          else ss.setItem fn.prefix(key), $.parseString value

      when 2
        [key, value] = arg
        if !value? then fn.remove key
        else ss.setItem fn.prefix(key), $.parseString value

      else throw new Error 'invalid argument length'

    ss

  fn.size = -> ss.length

  # return
  $.session = fn
