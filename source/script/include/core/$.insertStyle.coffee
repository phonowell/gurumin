$.insertStyle = (id, style) ->

  unless id and style then return

  $target = $.insertStyle.$target or= $ 'head'
  $el = $ "##{id}"

  if $el.length
    $el.html style
    return style

  $ '<style>'
  .attr {id}
  .html style
  .appendTo $target

  # return
  style
