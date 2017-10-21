# prepare

for key in 'anitama cordova plugins'.split ' '
  window[key] or= {}
for key in 'check fn keyboard share'.split ' '
  app[key] or= {}

# function

###

  app.fn.clearCache()
  app.fn.clip(string)
  app.fn.exit()
  app.fn.download(src, name)
  app.fn.feedback()
  app.fn.fullScreen(option)
  app.fn.hideSplash()
  app.fn.setOrientation(option)

  app.open(url, [target], [option])
  app.open.InAppBrowser(url, [target], [option])
  app.check.connection()
  app.check.push()
  app.stat(category, key, arg)
  app.share.submit(type, data)
  app.translucent(param)
  app.user.login(type, [callback])
  app.check.isWechatInstalled()
  app.keyboard.show()
  app.keyboard.hide()
  app.addSearchData(param)
  app.remind(param)
  app.shareEx(opt)
  app.pageTransit(method, option)

###

app.fn.clearCache = ->

  def = $.Deferred()

  plugin = window.cache
  if !plugin
    return def.reject '该功能尚未就绪'

  fnDone = (status) -> def.resolve status
  fnFail = (status) -> def.reject status

  plugin.clear fnDone, fnFail

  def.promise()

app.fn.clip = (string) ->
  plugin = cordova.plugins.clipboard
  if !plugin then return
  plugin.copy string

app.fn.exit = ->
  plugin = navigator.app
  if !plugin then return
  plugin.exitApp()

app.fn.download = (source, filename) ->

  def = $.Deferred()

  fnDoneAndroid = ->

    target = "#{cordova.file.externalRootDirectory}/Pictures/Anitama/#{filename}"
    window.refreshMedia?.refresh? target

    def.resolve "已存储至/Pictures/Anitama"

  fnDoneIOS = -> def.resolve '已存储至相册'

  fnFail = (err) ->
    def.reject "#{err.source}\n#{err.target}\n#{err.code}"

  switch app.os

    when 'android'

      ft = new FileTransfer()
      ft.download encodeURI(source)
      , "#{cordova.file.externalRootDirectory}/Pictures/Anitama/#{filename}"
      , fnDoneAndroid, fnFail, true

    when 'ios'

      cordova.plugins?.socialSharing?.saveToPhotoAlbum [source]
      , fnDoneIOS, fnFail

    else throw new Error "invalid os <#{app.os}>"

  def.promise()

app.fn.feedback = ->
  plugin = anitama.feedback
  if !plugin then return
  plugin.openFeedback()

app.fn.fullScreen = (option) ->
  plugin = window.StatusBar
  if !plugin then return

  method = if option then 'hide' else 'show'
  plugin[method]()

app.fn.hideSplash = ->
  plugin = navigator.splashscreen
  if !plugin then return
  plugin.hide()

app.fn.setOrientation = (option) ->
  plugin = window.screen
  if !plugin then return
  plugin.orientation.lock option

#

app.open = (url, target, option) ->

  if app.os != 'ios'
    return app.open.InAppBrowser url, target, option

  plugin = window.SafariViewController
  if !plugin then return

  plugin.isAvailable (available) ->

    if !available
      return app.open.InAppBrowser url, target, option

    plugin.show {url}

app.open.InAppBrowser = (url, target = '_blank', option = 'zoom=no') ->

  plugin = cordova.InAppBrowser

  if !plugin
    # fall back
    return window.open url

  plugin.open url, target, option

app.check.connection = ->
  app.connection = do ->
    status = app.debug 'connection'
    if status then return status
    plugin = navigator.connection
    if !plugin then return 'none'
    plugin.type

app.check.push = ->
  plugin = anitama.push

  if !plugin then return

  if !app.config 'push'
    plugin.disablePush()
    return

  plugin.enablePush()
  plugin.checkIntent null, (data) -> app.receive data

app.stat = (category, key, arg) ->
  plugin = anitama.stat

  if !plugin then return

  # check param
  if !category
    plugin.start()
    return

  $.i 'stat', "#{category} / #{key} / #{arg}"

  # plugin
  plugin.event
    category: category
    key: key
    args: arg
  , $.noop, $.noop

app.share.submit = (type, data) ->

  def = $.Deferred()

  plugin = anitama.share

  if !plugin
    return def.reject '相关插件暂不可用'

  # map
  map =
    moments: 'WechatTimeline'
    weibo: 'Weibo'
    wechat: 'Wechat'
    qq: 'QQ'
    qqzone: 'QQZone'
    tieba: 'Tieba'

  fnShare = plugin["share#{map[type]}"]
  if !fnShare
    return def.reject '相关方法暂不可用'

  fnDone = (msg) -> def.resolve msg
  fnFail = (msg) -> def.reject msg

  fnShare data, fnDone, fnFail

  def.promise()

app.translucent = (option) ->

  unless app.os == 'android' and ~$.os.version.search '4.4'
    return

  plugin = window.statusbarTransparent
  if !plugin then return

  # plugin
  if option then plugin.enable()
  else plugin.disable()

app.user.login = (type, callback) ->
  plugin = anitama.share

  if !plugin then return

  name = 'login' + switch type
    when 'weibo' then 'Weibo'
    when 'wechat' then 'Wechat'

  plugin[name] null
  , (res) ->
    app.post "/auth/#{type}", res
    .fail (msg) -> $.info msg
    .done (data) ->

      if !data.success
        $.info data.info
        app.user.logout()
        return

      a = data.data

      app.user
        uid: a.uid
        name: a.nickname
        avatar: a.avatarUrl
        token: a.accessToken
        expire: a.expireAt

      app.check 'login'
      $.info '登录成功'

      callback?()
  , (msg) -> $.info msg

app.check.isWechatInstalled = ->
  plugin = anitama.share

  if !plugin then return

  plugin.isWXAppInstalled null, (res) ->
    app.isWechatInstalled = res
  , $.noop

app.keyboard.show = ->
  plugin = cordova.plugins.Keyboard
  if !plugin then return
  plugin.show()

app.keyboard.hide = ->
  plugin = cordova.plugins.Keyboard
  if !plugin then return
  plugin.close()

app.addSearchData = (param) ->
  if app.os != 'ios' then return

  plugin = anitama.push

  if !plugin then return

  p = _.clone param

  plugin.addSearchData
    id: p.aid
    title: p.title
    content: p.content
  , _.noop, _.noop

app.remind = (param) ->
  plugin = anitama.toolkit
  if !plugin then return
  plugin.remind param, _.noop, (msg) -> $.info msg

app.shareEx = (opt) ->
  def = $.Deferred()
  plugin = cordova.plugins.socialSharing

  if !plugin
    def.reject 'cordova.plugins.socialSharing is undefined'
    return def.promise()

  fnDone = (res) -> def.resove res
  fnFail = (msg) -> def.reject msg

  plugin.shareWithOptions
    message: opt.message or ''
    subject: opt.subject or '来自Anitama的分享'
    files: [opt.src]
    url: opt.url or ''
    chooserTitle: '分享'
  , fnDone, fnFail

  def.promise()

# http://plugins.telerik.com/cordova/plugin/native-page-transitions
app.pageTransit = (method, option) ->

  plugin = window.plugins.nativepagetransitions
  if !plugin then return

  if !method
    plugin.executePendingTransition()
    return

  option = _.merge
    androiddelay: -1
    iosdelay: -1
  , option or {}

  plugin.cancelPendingTransition()
  plugin[method] option
