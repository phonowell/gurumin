# prepare

for key in 'anitama cordova plugins'.split ' '
  window[key] or= {}
for key in 'check fn keyboard share status'.split ' '
  app[key] or= {}

# function

###
app.fn.addSearchData(data)
app.fn.clearCache()
app.fn.clip(string)
app.fn.download(src, name)
app.fn.enablePermission(name)
app.fn.exit()
app.fn.hideSplash()
app.fn.loginViaSDK(type)
app.fn.open(source, [target], [option])
app.fn.openInside(source, [target], [option])
app.fn.refreshGallery(source)
app.fn.setOrientation(option)
app.fn.shareEx(option)
app.fn.shareViaSDK(type, data)

app.check.connection()
app.check.isWechatInstalled()
app.check.push()
app.keyboard.hide()
app.keyboard.show()
app.stat(category, key, arg)
###

app.fn.addSearchData = (data) ->
  if app.os != 'ios' then return
  plugin = anitama.push
  if !plugin then return
  plugin.addSearchData data

app.fn.clearCache = ->

  def = $.Deferred()

  plugin = window.cache
  if !plugin
    return def.reject '相关插件暂不可用'

  fnDone = (status) -> def.resolve status
  fnFail = (status) -> def.reject status

  plugin.clear fnDone, fnFail

  def.promise()

app.fn.clip = (string) ->
  plugin = cordova.plugins.clipboard
  if !plugin then return
  plugin.copy string

app.fn.download = (source, filename) ->

  # function

  ###
  onError()
  onSuccess(entry)
  ###

  onError = -> def.reject '下载文件失败'
  onSuccess = (entry) ->

    if app.os == 'android'
      app.fn.refreshGallery entry.toURL()

    def.resolve '已存储至相册'

  # execute

  def = $.Deferred()

  switch app.os

    when 'android'

      app.fn.enablePermission 'WRITE_EXTERNAL_STORAGE'
      .fail (msg) -> $.info msg
      .done ->

        ft = new FileTransfer()
        source = encodeURI source
        target = encodeURI "#{cordova.file.externalRootDirectory}Pictures/Anitama/#{filename}"
        
        ft.download encodeURI(source)
        , encodeURI("#{cordova.file.externalRootDirectory}Pictures/Anitama/#{filename}")
        , onSuccess
        , onError

    when 'ios'

      plugin = window.plugins.socialsharing
      if !plugin
        return def.reject '相关插件暂不可用'
        
      plugin.saveToPhotoAlbum source, onSuccess, onError

    else throw new Error "invalid os <#{app.os}>"

  def.promise()

app.fn.enablePermission = (name) ->

  def = $.Deferred()

  if app.os != 'android'
    return def.resolve()

  unless plugin = cordova.plugins.permissions
    return def.reject '相关插件暂不可用'

  if !name?.length
    return def.reject '不可用的非法权限'
  name = name.toUpperCase()

  plugin.checkPermission plugin[name], (status) ->
    
    if status.hasPermission
      return def.resolve '权限已获取'

    fnDone = -> def.resolve '权限获取成功'
    fnFail = -> def.reject '权限获取失败'
    plugin.requestPermission plugin[name], fnDone, fnFail

  # return
  def.promise()

app.fn.exit = ->
  plugin = navigator.app
  if !plugin then return
  plugin.exitApp()

app.fn.hideSplash = ->
  plugin = navigator.splashscreen
  if !plugin then return
  plugin.hide()

app.fn.loginViaSDK = (type) ->

  def = $.Deferred()

  method = switch type
    when 'wechat' then 'loginWechat'
    when 'weibo' then 'loginWeibo'
  if !method then return def.reject "非法类型#{type}"

  plugin = anitama.share
  if !plugin then return def.reject '相关插件暂不可用'

  fnDone = (data) ->

    app.post "/auth/#{type}", data
    .fail (msg) -> def.reject msg
    .done (res) ->

      if !res.success
        return def.reject res.info

      app.user.record res.data

      app.user.check()
      def.resolve()
  
  fnFail = (msg) ->
    app.user.logout()
    def.reject msg

  plugin[method] null, fnDone, fnFail

  def.promise()

app.fn.open = (source, target, option) ->

  if app.os != 'ios'
    return app.fn.openInside source, target, option

  plugin = window.SafariViewController
  if !plugin
    return app.fn.openInside source, target, option

  plugin.isAvailable (available) ->

    if !available
      return app.fn.openInside source, target, option

    plugin.show url: source

app.fn.openInside = (url, target = '_blank', option = {}) ->

  plugin = cordova.InAppBrowser

  if !plugin
    # fall back
    return window.open url

  option = _.merge
    disallowoverscroll: 'yes'
    location: 'no'
    zoom: 'no'
  , option
  option = ("#{key}=#{value}" for key, value of option).join ','

  plugin.open url, target, option

app.fn.refreshGallery = (source) ->
  if app.os != 'android' then return
  if !source?.length then return
  plugin = window.refreshMedia
  if !plugin then return
  plugin.refresh source

app.fn.setOrientation = (option) ->
  plugin = window.screen
  if !plugin then return
  plugin.orientation.lock option

app.fn.shareEx = (option) ->

  plugin = window.plugins.socialsharing
  if !plugin then return

  plugin.shareWithOptions
    chooserTitle: '分享'
    files: [option.thumb]
    message: option.desc or ''
    subject: option.title or ''
    url: option.url

app.fn.shareViaSDK = (type, data) ->

  def = $.Deferred()

  for key in ['content', 'image', 'title', 'url']
    if !data[key] then return def.reject "#{key}字段不能为空"

  plugin = anitama.share
  if !plugin then return def.reject '相关插件暂不可用'

  # map
  map =
    moments: 'WechatTimeline'
    qq: 'QQ'
    qqzone: 'QQZone'
    tieba: 'Tieba'
    wechat: 'Wechat'
    weibo: 'Weibo'

  unless fnShare = plugin["share#{map[type]}"]
    return def.reject '相关方法暂不可用'

  fnDone = (msg) -> def.resolve msg
  fnFail = (msg) -> def.reject msg

  fnShare data, fnDone, fnFail

  def.promise()

#

app.check.connection = ->
  app.connection = do ->
    status = app.debug.get 'connection'
    if status then return status
    plugin = navigator.connection
    if !plugin then return 'none'
    plugin.type

app.check.push = (callback) ->
  plugin = anitama.push
  if !plugin then return
  plugin.enablePush?()
  plugin.checkIntent null, (data) -> callback? data

app.stat = (category, key, arg) ->
  
  plugin = anitama.stat
  if !plugin then return

  if !category then return plugin.start()

  $.i 'stat', "#{category} / #{key} / #{arg}"

  plugin.event
    category: category
    key: key
    args: arg
  , null, null

app.check.isWechatInstalled = ->
  plugin = anitama.share
  if !plugin then return false
  plugin.isWXAppInstalled null, (res) ->
    app.status.isWechatInstalled = res
  , null

app.keyboard.show = ->
  plugin = cordova.plugins.Keyboard
  if !plugin then return
  plugin.show()

app.keyboard.hide = ->
  plugin = cordova.plugins.Keyboard
  if !plugin then return
  plugin.close()