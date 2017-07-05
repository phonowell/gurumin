do ->
  ua = navigator.userAgent
  platform = navigator.platform

  os = $.os = {}
  browser = $.browser = {}
  webkit = ua.match(/Web[kK]it[\/]{0,1}([\d.]+)/)
  android = ua.match(/(Android);?[\s\/]+([\d.]+)?/)
  osx = !!ua.match(/\(Macintosh\; Intel /)
  ipad = ua.match(/(iPad).*OS\s([\d_]+)/)
  ipod = ua.match(/(iPod)(.*OS\s([\d_]+))?/)
  iphone = not ipad and ua.match(/(iPhone\sOS)\s([\d_]+)/)
  webos = ua.match(/(webOS|hpwOS)[\s\/]([\d.]+)/)
  win = /Win\d{2}|Windows/.test(platform)
  wp = ua.match(/Windows Phone ([\d.]+)/)
  touchpad = webos and ua.match(/TouchPad/)
  kindle = ua.match(/Kindle\/([\d.]+)/)
  silk = ua.match(/Silk\/([\d._]+)/)
  blackberry = ua.match(/(BlackBerry).*Version\/([\d.]+)/)
  bb10 = ua.match(/(BB10).*Version\/([\d.]+)/)
  rimtabletos = ua.match(/(RIM\sTablet\sOS)\s([\d.]+)/)
  playbook = ua.match(/PlayBook/)
  chrome = ua.match(/Chrome\/([\d.]+)/) or ua.match(/CriOS\/([\d.]+)/)
  firefox = ua.match(/Firefox\/([\d.]+)/)
  firefoxos = ua.match(/\((?:Mobile|Tablet); rv:([\d.]+)\).*Firefox\/[\d.]+/)
  ie = ua.match(/MSIE\s([\d.]+)/) or ua.match(/Trident\/[\d](?=[^\?]+).*rv:([0-9.].)/)
  webview = not chrome and ua.match(/(iPhone|iPod|iPad).*AppleWebKit(?!.*Safari)/)
  safari = webview or ua.match(/Version\/([\d.]+)([^S](Safari)|[^M]*(Mobile)[^S]*(Safari))/)

  if browser.webkit = !!webkit
    browser.version = webkit[1]
  if android
    os.android = true
    os.version = android[2]
  if iphone and not ipod
    os.ios = os.iphone = true
    os.version = iphone[2].replace /_/g, '.'
  if ipad
    os.ios = os.ipad = true
    os.version = ipad[2].replace /_/g, '.'
  if ipod
    os.ios = os.ipod = true
    os.version = if ipod[3] then ipod[3].replace(/_/g, '.') else null
  if wp
    os.wp = true
    os.version = wp[1]
  if webos
    os.webos = true
    os.version = webos[2]
  if touchpad
    os.touchpad = true
  if blackberry
    os.blackberry = true
    os.version = blackberry[2]
  if bb10
    os.bb10 = true
    os.version = bb10[2]
  if rimtabletos
    os.rimtabletos = true
    os.version = rimtabletos[2]
  if playbook
    browser.playbook = true
  if kindle
    os.kindle = true
    os.version = kindle[1]
  if silk
    browser.silk = true
    browser.version = silk[1]
  if !silk and os.android and ua.match /Kindle Fire/
    browser.silk = true
  if chrome
    browser.chrome = true
    browser.version = chrome[1]
  if firefox
    browser.firefox = true
    browser.version = firefox[1]
  if firefoxos
    os.firefoxos = true
    os.version = firefoxos[1]
  if ie
    browser.ie = true
    browser.version = ie[1]
  if safari and (osx or os.ios or win)
    browser.safari = true
    if !os.ios
      browser.version = safari[1]
  if webview
    browser.webview = true
  os.tablet = !!(ipad or playbook or (android and !ua.match /Mobile/) or (firefox and ua.match /Tablet/) or (ie and !ua.match(/Phone/) and ua.match /Touch/))
  os.phone = !!(!os.tablet and !os.ipod and (android or iphone or webos or blackberry or bb10 or (chrome and ua.match /Android/) or (chrome and ua.match /CriOS\/([\d.]+)/) or (firefox and ua.match /Mobile/) or (ie and ua.match /Touch/)))

# check features
do ->
  list = []
  ua = navigator.userAgent

  # os
  arr = switch
    when $.os.android then ['os-android', 'android']
    when $.os.ios then ['os-ios', 'ios']
    else ['os-web', 'web']
  list.push arr[0]
  app.os = arr[1]

  # device
  arr = switch
    when $.os.phone then ['device-phone', 'phone']
    when $.os.tablet then ['device-tablet', 'tablet']
    else ['device-desktop', 'desktop']
  list.push arr[0]
  app.device = arr[1]

  # shell
  arr = switch
    when ~ua.search /MicroMessenger/i then ['shell-wechat', 'wechat']
    when ~ua.search /Electron/i then ['shell-electron', 'electron']
    when cordova?.notCordova
      # browser name
      for key in ['chrome', 'ie', 'firefox', 'safari'] when $.browser[key]
        app.browser = key
        list.push "browser-#{key}"
        break
      ['shell-browser', 'browser']
    else ['shell-application', 'application']
  list.push arr[0]
  app.shell = arr[1]

  # add class
  $stage.addClass list.join ' '