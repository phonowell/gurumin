$.fn.onAnimationEnd = (fn) ->

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
    $el.one EVENT, -> fn.apply $el