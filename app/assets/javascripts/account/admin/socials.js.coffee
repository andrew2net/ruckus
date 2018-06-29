$ ->
  inputSelector = 'body.socials input'

  disableOrEnableSwitches = (element, autoenable = true) ->
    socialUrl = $(element).val()
    switchWrapper = $(element).closest('.white-box').find('.switch')
    if socialUrl.length > 0
      switchWrapper.removeClass('disabled')
      switchWrapper.click() if autoenable && !switchWrapper.hasClass('active')
    else
      switchWrapper.click() if autoenable && switchWrapper.hasClass('active')
      switchWrapper.addClass('disabled')

  $(document).on 'ready', ->
    $(inputSelector).each (index, element) ->
      disableOrEnableSwitches(element, false)

  $(document).on 'change keyup input', inputSelector, ->
    disableOrEnableSwitches(@)
