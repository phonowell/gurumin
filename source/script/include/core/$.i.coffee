$.i = (arg...) ->
  [method, type, msg] = switch arg.length
    when 1 then ['log', 'default', arg[0]]
    when 2 then ['log', arg[0], arg[1]]
    else arg

  if type in $.i.forbidden then return msg

  console[method] if type == 'default' then msg else "<#{type.toUpperCase()}> #{msg}"

  msg

# $.i.forbidden

$.i.forbidden = []
$.i.forbid = (arg) -> $.i.forbidden = _.union $.i.forbidden, if $.type(arg) != 'array' then [arg] else arg
