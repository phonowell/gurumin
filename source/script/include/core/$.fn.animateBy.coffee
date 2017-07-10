$.fn.animateBy = (list, callback) ->
  
  if !$.fn.onAnimationEnd
    throw new Error 'have to require $.fn.onAnimationEnd()'
  
  if $.type(list) != 'array' then list = [list]
  @each -> $.animateBy $(@), list, 0, callback

$.animateBy = ($el, list, i, callback) ->

  if i >= list.length
    callback?()
    return $el

  $el.onAnimationEnd ->
    $el.removeClass list[i]
    $.animateBy $el, list, i + 1, callback
  .addClass list[i]