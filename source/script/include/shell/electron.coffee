# prepare

for key in 'cordova plugins'.split ' '
  window[key] or= {}
for key in 'check fn keyboard share'.split ' '
  app[key] or= {}

window.electron or= require?('electron') or {}

# function

###

  app.fn.clip(string)
  app.fn.open(url)

###

app.fn.clip = (string) ->
  plugin = electron.clipboard
  if !plugin then return
  plugin.writeText string

app.fn.open = (url) ->
  plugin = electron.shell
  if !plugin then return
  plugin.openExternal url