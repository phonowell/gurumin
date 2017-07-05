$.parseJson = (data) ->
  switch $.type data
    when 'string'
      try
        $.parseJSON data
      catch err
        data
    when 'object', 'array'
      data
    else
      data