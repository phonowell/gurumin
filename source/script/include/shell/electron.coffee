window.cordova or= {}
window.anitama or= {}
window.electron or= require?('electron') or {}

app.check or= {}
app.keyboard or= {}

#open
app.open = (url) ->
  plugin = electron.shell
  if !plugin then return
  plugin.openExternal url

#clip
app.clip = (string) ->
  plugin = electron.clipboard
  if !plugin then return
  plugin.writeText string