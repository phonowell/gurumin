do ->

  $body = $ 'body'
  $head = $ 'head'

  class Require

    constructor: ->

      @setting =
        html:
          prefix: 'html/'
          suffix: ".html?salt=#{app.salt}"
          callback: (html) -> $body.append html
        style:
          prefix: 'style/'
          suffix: ".css?salt=#{app.salt}"
        script:
          prefix: 'script/'
          suffix: ".js?salt=#{app.salt}"

      @port =
        main: {}
        html: {}
        style: {}
        script: {}

    ###

      fill(list, map, type)
      get(map, callback)
      getHtml(path)
      getScript(path)
      getStyle(path)
      set(data)
      when(def, list, callback)

    ###

    fill: (list, map, type) ->

      if !map[type] then return

      for a in map[type] when a
        list.push @["get#{_.capitalize type}"] a

    get: (map, callback) ->

      def = $.Deferred()
      hash = $.parseString map
      p = @port.main

      switch p[hash]

        when 'pending'
          def.reject 'pending'

        when 'resolved'
          def.resolve()
          callback?()

        else

          p[hash] = 'pending'

          @fill list = [], map, 'html'
          @fill list, map, 'style'

          @when def, list, =>

            @fill list = [], map, 'script'

            @when def, list, ->

              p[hash] = 'resolved'
              def.resolve()
              callback?()

          def.promise()

    getHtml: (path) ->

      def = $.Deferred()
      s = @setting.html
      p = @port.html

      switch p[path]

        when 'pending' then def.reject 'pending'
        when 'resolved' then def.resolve()

        else

          p[path] = 'pending'

          $.get "#{s.prefix}#{path}#{s.suffix}"
          .fail ->
            p[path] = 'rejected'
            def.reject "'#{path}.html' not found"
          .done (html) ->
            $.i 'require', "#{path}.html"
            p[path] = 'resolved'
            s.callback html, path
            def.resolve()

          def.promise()

    getScript: (path) ->

      def = $.Deferred()
      s = @setting.script
      p = @port.script

      switch p[path]

        when 'pending' then def.reject 'pending'
        when 'resolved' then def.resolve()

        else

          p[path] = 'pending'

          $.getScript "#{s.prefix}#{path}#{s.suffix}"
          .fail ->
            p[path] = 'rejected'
            def.reject "'#{path}.js' not found"
          .done ->
            p[path] = 'resolved'
            def.resolve()

          def.promise()

    getStyle: (path) ->

      def = $.Deferred()
      s = @setting.style
      p = @port.style

      switch p[path]

        when 'pending' then def.reject 'pending'
        when 'resolved' then def.resolve()

        else

          p[path] = 'pending'

          $ '<link>'
          .one 'error', ->
            p[path] = 'rejected'
            def.reject "'#{path}.css' not found"
          .one 'load', ->
            p[path] = 'resolved'
            def.resolve()
          .attr
            href: "#{s.prefix}#{path}#{s.suffix}"
            rel: 'stylesheet'
          .appendTo $head

          def.promise()

    set: (data) -> @setting = _.merge @setting, data

    when: (def, list, callback) ->

      $.when.apply $, list
      .fail (msg) -> def.reject msg
      .done -> callback?()

  fn = (arg, callback) ->

    if !arg then return fn.fn or= new Require()

    type = $.type arg

    # when argument is array

    if type == 'array'

      def = $.Deferred()

      $.when.apply $, (fn line for line in arg)
      .fail (msg) -> def.reject msg
      .done ->
        def.resolve()
        callback?()

      return def.promise()

    # not array

    map = switch type

      when 'string'
        html: arg
        style: arg
        script: arg

      when 'object' then arg

      else throw new Error 'invalid argument type'

    for key, value of map
      if $.type(value) != 'array'
        map[key] = [value]
      $.unique map[key]

    # execute
    fn.fn.get map, callback

  # return

  $.require = fn
