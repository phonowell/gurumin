$.parseSize = (arg) ->

  if !arg then return '0 B'

  s = parseInt arg

  switch
    when s > 1099511627776
      "#{(s / 1099511627776).toFixed 2} TB"
    when s > 1073741824
      "#{(s / 1073741824).toFixed 2} GB"
    when s > 1048576
      "#{(s / 1048576).toFixed 2} MB"
    when s > 1024
      "#{(s / 1024).toFixed 2} KB"
    else
      "#{s} B"