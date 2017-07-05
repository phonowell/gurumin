window.cordova or= {}
window.plugins or= {}
window.anitama or= {}

app.check or= {}
app.keyboard or= {}
app.share or= {}

app.open = (url, target = '_blank') ->

  if app.os != 'ios'
    app.open.InAppBrowser url
    return

  plugin = window.SafariViewController

  if !plugin then return

  plugin.isAvailable (available) ->

    if !available
      app.open.InAppBrowser url
      return

    plugin.show {url}

app.open.InAppBrowser = (url) ->

  plugin = cordova.InAppBrowser

  if !plugin

    # fall back to window.open()

    window.open url

    return

  plugin.open url, '_blank', 'zoom=no'

app.fullScreen = (arg) ->

  plugin = window.StatusBar

  if !plugin then return

  method = if arg then 'hide' else 'show'
  plugin[method]()

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

app.stat = (category, key, args) ->
  plugin = anitama.stat

  if !plugin then return

  # check param
  if !category
    plugin.start()
    return

  $.i 'stat', "#{category} / #{key} / #{args}"

  # plugin
  plugin.event
    category: category
    key: key
    args: args
  , $.noop, $.noop

app.exit = ->
  plugin = navigator.app
  if !plugin then return
  plugin.exitApp()

app.hideAppSplash = ->
  plugin = navigator.splashscreen
  if !plugin then return
  plugin.hide()

app.share.submit = (type, data) ->
  def = $.Deferred()
  plugin = anitama.share

  if !plugin
    def.reject '相关插件暂不可用'
    return def.promise()

  # map
  map =
    moments: 'WechatTimeline'
    weibo: 'Weibo'
    wechat: 'Wechat'
    qq: 'QQ'
    qqzone: 'QQZone'
    tieba: 'Tieba'

  # check fn
  fn = plugin["share#{map[type]}"]
  if !fn
    def.reject '相关方法暂不可用'
    return def.promise()

  # plugin
  fn data
  , (msg) ->
    # do not write the lines below & upon into a SINGLE line
    def.resolve msg # done
  , (msg) -> def.reject msg # fail

  def.promise()

app.translucent = (param) ->
  if !(app.os == 'android' and ~$.os.version.search '4.4') then return

  plugin = window.statusbarTransparent

  if !plugin then return

  # plugin
  if param then plugin.enable()
  else plugin.disable()

app.feedback = ->
  plugin = anitama.feedback
  if !plugin then return
  plugin.openFeedback()

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

app.clip = (string) ->
  plugin = cordova.plugins.clipboard
  if !plugin then return
  plugin.copy string

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

app.clear = (callback = _.noop) ->
  plugin = window.cache
  if !plugin then return
  cache.clear callback, _.noop
  # cache.cleartemp()

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

app.download = (src, name) ->
  def = $.Deferred()

  fnDoneAndroid = ->
    window.refreshMedia?.refresh? "#{cordova.file.externalRootDirectory}/Pictures/Anitama/#{name}"
    def.resolve "已存储为/Pictures/Anitama/#{name}"
  fnDoneIOS = -> def.resolve '已存储至相册'
  fnFail = (err) -> def.reject "#{err.source}\n#{err.target}\n#{err.code}"

  switch app.os
    when 'android'
      ft = new FileTransfer()
      ft.download encodeURI(src), "#{cordova.file.externalRootDirectory}/Pictures/Anitama/#{name}", fnDoneAndroid, fnFail, true
    when 'ios'
      cordova.plugins?.socialSharing?.saveToPhotoAlbum [src], fnDoneIOS, fnFail

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