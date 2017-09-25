$.fn.switchClass = (className) ->
  @each ->
    $ @
    .addClass className
    .siblings ".#{className}"
    .removeClass className
