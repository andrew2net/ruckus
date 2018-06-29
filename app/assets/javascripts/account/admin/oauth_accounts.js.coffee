$ ->
  $(document).on 'click', '.dropdown .active', (event) ->
    event.preventDefault()
    $('.box-form').hide()
    $(@).closest('.dropdown').find('.box-form').show()

  $(document).on 'click', '.dropdown .cancel-btn', (event) ->
    event.preventDefault()
    input = $(@).closest('form').find('input[type="checkbox"]')
    oldValue = input.data('old-value')
    currentValue = input.is(':checked')
    shouldCheck = oldValue != currentValue
    input.click() if shouldCheck
    $(@).closest('.dropdown').find('.box-form').hide()
