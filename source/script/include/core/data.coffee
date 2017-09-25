class window.Data

  # const

  D = '__data__'

  # constructor

  constructor: -> @[D] = {}

  # function

  ###

    error(code)
    get(key)
    observe(arg)
    set(arg)

  ###

  error: (arg) ->
    throw new Error switch arg
      when 'type' then 'invalid arguments type'
      when 'length' then 'invalid arguments length'
      else "unknown error arg <#{arg}>"

  get: (key) ->
    if !key? then return @
    @[key]

  observe: (arg...) ->

    [key, getter, setter] = switch arg.length
      when 2 then [arg[0], null, arg[1]]
      when 3 then arg
      else @error 'length'

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
      else @error 'length'

    @
