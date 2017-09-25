$.parseJson = (data) ->
  switch $.type data
    when 'array', 'object' then data
    when 'string'
      try $.parseJSON data
      catch err then data
    else data
