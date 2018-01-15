class window.Data

  # const

  D = '__data__'

  # constructor

  constructor: -> @[D] = {}

  # function

  ###

    get(key)
    observe(arg)
    set(arg)

  ###

  get: (key) ->
    if !key? then return @
    @[key]

  observe: (arg...) ->

    [key, getter, setter] = switch arg.length
      when 2 then [arg[0], null, arg[1]]
      when 3 then arg
      else throw new Error 'invalid argument length'

    Object.defineProperty @, key,
      enumerable: true
      configurable: true
      get: =>
        value = @[D][key]
        if getter then return getter value
        value
      set: (value) =>
        oldValue = @[D][key]
        @[D][key] = value
        setter value, oldValue

    @

  set: (arg...) ->
    switch arg.length
      when 1 # map
        for key, value of arg[0]
          @[key] = value
      when 2 # key, value
        [key, value] = arg
        @[key] = value
      else throw new Error 'invalid argument length'

    @