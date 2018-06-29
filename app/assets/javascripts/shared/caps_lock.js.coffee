$ ->
  $(document).on 'keypress', 'input[type=password]', (e) ->
    s = String.fromCharCode(e.which)
    $formGroup = $('input[type=password]').parent()
    if s.toUpperCase() is s and s.toLowerCase() isnt s and not e.shiftKey
      $formGroup.addClass('caps-lock')
    else
      $formGroup.removeClass('caps-lock')
