do ->

  DELAY = 500

  EVENT = '.hold'
  START = ("#{event}#{EVENT}" for event in ['touchstart']).join ' '
  END = (
    "#{event}#{EVENT}" for event in [
      'touchend', 'touchmove', 'touchcancel'
    ]
  ).join ' '

  $.fn.hold = (arg...) ->

    timer = null

    [handle, callback] = switch arg.length
      when 0 then []
      when 1 then [null, arg[0]]
      when 2 then arg
      else []

    if !callback then return

    cb = (e) ->
      clearTimeout timer
      timer = setTimeout =>
        callback.call @, e
      , DELAY

    list = [START]
    if handle then list.push handle
    list.push cb

    @off EVENT
    @on.apply @, list
    @on END, -> clearTimeout timer
