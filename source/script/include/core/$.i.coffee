$.i = (args...) ->
  [method, type, msg] = switch args.length
    when 1 then ['log', 'default', args[0]]
    when 2 then ['log', args[0], args[1]]
    else args

  if type in $.i.forbidden then return msg

  console[method] if type == 'default' then msg else "<#{type.toUpperCase()}> #{msg}"

  msg

# $.i.forbidden

$.i.forbidden = []
$.i.forbid = (arg) -> $.i.forbidden = _.union $.i.forbidden, if $.type(arg) != 'array' then [arg] else arg