do ->

  $layer = $ '#layer-info'

  # function

  fn = (arg) ->

    if !arg? then return arg
    msg = $.parseString arg
    $item = (fn.$item or= $ '<div>').clone()

    fn.render $item, msg
    fn.show $item, -> fn.check()
    $.next 2e3, -> fn.hide $item, -> fn.check()

    msg

  fn.clear = -> $layer.empty().addClass 'hidden'

  fn.check = ->

    $child = $layer.children '.item'

    if !$child.length
      fn.clear()
      return

    if $child.length > 5
      fn.remove $child.eq 0

  fn.hide = ($item, callback) ->
    $item.animateBy 'fadeOut', ->
      fn.remove $item
      callback?()

  fn.show = ($item, callback) -> $item.animateBy 'fadeIn', -> callback?()

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

  fn.remove = ($item) ->
    $item.next().remove()
    $item.remove()

  # return

  $.info = fn