$.timeStamp = (arg) ->

  type = $.type arg

  if type == 'number' then return _.floor arg, -3

  if type != 'string' then return _.floor _.now(), -3

  str = _.trim arg
  .replace /\s+/g, ' '
  .replace /[-|/]/g, '.'

  date = new Date()

  arr = str.split ' '

  b = arr[0].split '.'
  date.setFullYear b[0], (b[1] - 1), b[2]

  if !(a = arr[1])
    date.setHours 0, 0, 0, 0
  else
    a = a.split ':'
    date.setHours a[0], a[1], a[2] or 0, 0

  date.getTime()
