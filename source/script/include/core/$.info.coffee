do ->

  $layer = $ '#layer-info'
  if !$layer.length then throw new Error 'invalid element'

  # function

  fn = (arg) ->

    if !arg? then return arg
    msg = $.parseString arg
    $item = (fn.$item or= $ '<div>').clone()

    fn.render $item, msg
    fn.show $item, -> fn.check()
    $.next 2e3, -> fn.hide $item, -> fn.check()

    msg

  ###

    check()
    clear()
    hide($item, callback)
    remove($item)
    render($item, content)
    show($item, callback)

  ###

  fn.check = ->

    $child = $layer.children '.item'

    if !$child.length
      fn.clear()
      return

    if $child.length > 5
      fn.remove $child.eq 0

  fn.clear = -> $layer.empty().addClass 'hidden'

  fn.hide = ($item, callback) ->
    $item.animateBy 'fadeOut', ->
      fn.remove $item
      callback?()

  fn.remove = ($item) ->
    $item.next().remove()
    $item.remove()

  fn.render = ($item, content) ->

    content = content.replace /[\r\n]+/g, '<br>'
    .replace /。</g, '<'
    .replace /。$/g, ''

    list = ['item']

    if ~content.search /<br>/ then list.push 'with-break'
    if 0 == content.search /<i/ then list.push 'with-icon'

    $item.attr 'class', list.join ' '
    .html content
    .appendTo $layer.removeClass 'hidden'
    .after '<br>'

  fn.show = ($item, callback) ->
    $item.animateBy 'fadeIn', -> callback?()

  # return
  $.info = fn