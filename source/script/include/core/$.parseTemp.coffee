$.parseTemp = (string, object) ->
  if $.type(string) != 'string' then return ''
  res = string
  for key, value of object
    res = res.replace (new RegExp "\\[#{key}\\]", 'g'), value
  res
