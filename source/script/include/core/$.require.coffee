do ->

  $body = $ 'body'
  $head = $ 'head'

  class Require

    constructor: ->

      @cache =
        html: {}
        script: {}
        style: {}

      @setting =
        html:
          callback: (html) -> $body.append html
          prefix: 'html/'
          suffix: ".html?salt=#{app.salt}"
        script:
          prefix: 'script/'
          suffix: ".js?salt=#{app.salt}"
        style:
          prefix: 'style/'
          suffix: ".css?salt=#{app.salt}"

    ###
    get(map, callback)
    getHtml(path)
    getScript(path)
    getStyle(path)
    set(data)
    ###

    get: (map, callback) ->

      def = $.Deferred()

      # style
      listDeferred = (@getStyle src for src in map.style)
      $.when.apply $, listDeferred
      .fail (msg) -> def.reject msg
      .done =>

        # html
        listDeferred = (@getHtml src for src in map.html)
        $.when.apply $, listDeferred
        .fail (msg) -> def.reject msg
        .done =>

          # script
          listDeferred = (@getScript src for src in map.script)
          $.when.apply $, listDeferred
          .fail (msg) -> def.reject msg
          .done ->

            def.resolve()
            callback?()

      # return
      def.promise()

    getHtml: (source) ->

      filename = "#{source}.html"

      if @cache.html[source]
        $.i 'require', "hit '#{filename}'"
        return @cache.html[source]

      def = $.Deferred()
      setting = @setting.html
      url = "#{setting.prefix}#{source}#{setting.suffix}"

      $.get url
      .fail -> def.reject "'#{filename}' not found"
      .done (html) ->
        $.i 'require', "loaded '#{filename}'"
        setting.callback html, source
        def.resolve()

      # return
      @cache.html[source] = def.promise()

    getScript: (source) ->

      filename = "#{source}.js"

      if @cache.script[source]
        $.i 'require', "hit '#{filename}'"
        return @cache.script[source]

      def = $.Deferred()
      setting = @setting.script
      url = "#{setting.prefix}#{source}#{setting.suffix}"

      $.getScript url
      .fail -> def.reject "'#{filename}' not found"
      .done ->
        $.i 'require', "loaded '#{filename}'"
        def.resolve()

      # return
      @cache.script[source] = def.promise()

    getStyle: (source) ->

      filename = "#{source}.css"

      if @cache.style[source]
        $.i 'require', "hit '#{filename}'"
        return @cache.style[source]

      def = $.Deferred()
      setting = @setting.style
      url = "#{setting.prefix}#{source}#{setting.suffix}"

      $ '<link>'
      .one 'error', -> def.reject "'#{filename}' not found"
      .one 'load', ->
        $.i 'require', "loaded '#{filename}'"
        def.resolve()
      .attr
        href: url
        rel: 'stylesheet'
      .appendTo $head

      # return
      @cache.style[source] = def.promise()

    set: (data) -> @setting = _.merge @setting, data

  fn = (arg, callback) ->

    # init
    if !arg
    
      if fn.handle
        $.i '$.require() overloaded'
        return fn.handle

      return fn.handle = new Require()

    type = $.type arg

    # when argument is an array

    if type == 'array'

      def = $.Deferred()

      $.when.apply $, (fn line for line in arg)
      .fail (msg) -> def.reject msg
      .done ->
        def.resolve()
        callback?()

      return def.promise()

    # when argument is not array

    map = switch type

      when 'string'
        html: arg
        style: arg
        script: arg

      when 'object' then arg

      else throw new Error 'invalid argument type'

    for key in ['html', 'script', 'style']

      value = map[key] or= []

      if $.type(value) != 'array'
        map[key] = [value]

      $.unique map[key]

    # execute
    fn.handle.get map, callback

  # return
  $.require = fn