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

    ($el = $ @).off EVENT
    .one EVENT, (e) -> fn.apply $el