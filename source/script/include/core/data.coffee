class window.Data

  # const
  DATA = '__data__'

  # constructor
  constructor: (value) ->
    
    type = $.type value

    if type == 'undefined'
      return @

    if type == 'object'
      return @set value

    throw new Error "invalid type <#{type}>"

  ###
  __data__
  ###

  "#{DATA}": {}

  ###
  get([key])
  observe(key, [getter], setter)
  set([key], value)
  ###

  get: (key) ->
    if !key then return @
    @[key]

  observe: (arg...) ->

    [key, getter, setter] = switch arg.length
      when 2 then [arg[0], undefined, arg[1]]
      when 3 then arg
      else throw new Error 'invalid length'

    Object.defineProperty @, key,
      configurable: true
      enumerable: true
      get: =>
        value = @[DATA][key]
        if getter then return getter value
        value
      set: (value) =>
        oldValue = @[DATA][key]
        @[DATA][key] = value
        setter value, oldValue

    @ # return

  set: (arg...) ->
    
    switch arg.length
      
      when 1 # set({value})
        if $.type(arg[0]) != 'object'
          throw new Error 'type of value must be object'
        for key, value of arg[0]
          @[key] = value
      
      when 2 # set(key, value)
        [key, value] = arg
        if $.type(key) != 'string'
          throw new Error 'type of key must be string'
        @[key] = value
      
      else throw new Error 'invalid length'

    @ # return