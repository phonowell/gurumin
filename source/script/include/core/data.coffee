class window.Data

  # const
  D = '__data__'

  # constructor
  constructor: -> @[D] = {}

  # data.error()
  error: (code) ->
    throw new Error switch code
      when 'type' then 'invalid arguments type'
      when 'length' then 'invalid arguments length'
      else "unknown error code <#{code}>"

  # data.get()
  get: (key) ->
    if !key? then return @
    @[key]

  # data.set()
  set: (args...) ->
    switch args.length
      when 1
        # map
        for key, value of args[0]
          @[key] = value
      when 2
        # key, value
        [key, value] = args
        @[key] = value
      else @error 'length'
    # return
    @

  # data.observe()
  observe: (args...) ->

    [key, getter, setter] = switch args.length
      when 2 then [args[0], null, args[1]]
      when 3 then args
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