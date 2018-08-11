$ ->
  $(document).on 'click', '.dropdown .active', (event) ->
    event.preventDefault()
    $('.box-form').hide()
    $(@).closest('.dropdown').find('.box-form').show()

  $(document).on 'click', '.dropdown .cancel-btn', (event) ->
    event.preventDefault()
    $(@).closest('form').find('input[type="checkbox"][data-old-value]').each (idx, input) ->
      $input = $ input
      oldValue = $input.data('old-value')
      input.checked = oldValue
      # currentValue = $input.is(':checked')
      # shouldCheck = oldValue != currentValue
      # $input.click() if shouldCheck
      if oldValue
        $input.closest('label').addClass 'active'
      else
        $input.closest('label').removeClass 'active'

    $(@).closest('.dropdown').find('.box-form').hide()

  $(document).on 'click', 'a[data-fb-pages-reload]', (event) ->
    event.preventDefault()
    id = @dataset.fbPagesReload
    $('#fb-campaing-pages .loader').show()
    $('#fb-campaing-pages').load "/profile/oauth_accounts/#{id}/fb_pages_reload", ->
      $('#fb-campaing-pages .tip').tooltip()