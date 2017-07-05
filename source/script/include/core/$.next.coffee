$.next = (args...) ->

  [delay, callback] = switch args.length
    when 1 then [0, args[0]]
    else args

  setTimeout callback, delay