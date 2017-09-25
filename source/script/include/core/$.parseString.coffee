$.parseString = (data) ->
  switch $.type d = data
    when 'array'
      (JSON.stringify _obj: d)
      .replace /\{(.*)\}/, '$1'
      .replace /"_obj":/, ''
    when 'boolean', 'number' then d.toString()
    when 'null' then 'null'
    when 'object'then JSON.stringify d
    when 'string' then d
    when 'undefined' then 'undefined'
    else
      try d.toString()
      catch e then ''
