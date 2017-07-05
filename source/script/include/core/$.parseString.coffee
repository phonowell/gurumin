$.parseString = (data) ->
  switch $.type d = data
    when 'string' then d
    when 'number' then d.toString()
    when 'array'
      (JSON.stringify _obj: d)
        .replace /\{(.*)\}/, '$1'
        .replace /"_obj":/, ''
    when 'object'then JSON.stringify d
    when 'boolean' then d.toString()
    when 'undefined' then 'undefined'
    when 'null' then 'null'
    else
      try
        d.toString()
      catch e
        ''