do ->
  ss = window.sessionStorage

  fn = $.session = (args...) ->
    switch args.length
      when 0 then ss # $.session()
      when 1
        switch $.type args[0]
          when 'string' then fn.get args... # $.session(key)
          else fn.set args... # $.session({key: value})
      when 2 then fn.set args... # $.session(key, value)
      else ss # unknown

  fn.prefix = (key) -> "cache::#{key}"

  fn.get = (key) -> $.parseJson ss.getItem fn.prefix key

  fn.set = (args...) ->
    switch args.length
      when 1
        for key, value of args[0]
          if !value? then fn.remove key
          else ss.setItem fn.prefix(key), $.parseString value
      when 2
        [key, value] = args
        if !value? then fn.remove key
        else ss.setItem fn.prefix(key), $.parseString value
    ss

  fn.remove = (key) -> ss.removeItem fn.prefix key

  fn.clear = -> ss.clear()

  fn.size = -> ss.length