$.next = (arg...) ->

  [delay, callback] = switch arg.length
    when 1 then [0, arg[0]]
    else arg

  setTimeout callback, delay
