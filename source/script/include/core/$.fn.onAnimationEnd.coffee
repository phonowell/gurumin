$.fn.onAnimationEnd = (arg...) ->

  [isKept, callback] = switch arg.length
    when 1 then [false, arg[0]]
    when 2 then arg
    else throw new Error 'invalid argument length'

  EVENT = if window.WebKitTransitionEvent
    'webkitTransitionEnd
    webkitAnimationEnd'
  else
    'mozTransitionEnd
    MSTransitionEnd
    otransitionend
    transitionend
    mozAnimationEnd
    MSAnimationEnd
    oanimationend
    animationend'

  @each ->

    $el = $ @

    if !isKept then $el.off EVENT

    $el.one EVENT, -> callback $el
