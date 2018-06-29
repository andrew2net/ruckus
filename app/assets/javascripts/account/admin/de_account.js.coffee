$ ->
  $('.check-box.accept-terms').on 'click', ->
    val = $(@).find('input[type=hidden]').val()
    btn = $(@).parents('form').find('[type=submit]')

    if val == '0'
      btn.removeAttr('disabled')
    else
      btn.attr('disabled', 'disabled')
  $('#new_de_account_form [type=submit]').on 'click', (e) ->
    agreementField = $('#de_account_agreements')

    if agreementField.val().toString() isnt ''
      agreementField.focus()
      $('#agreement-error').show()
      e.preventDefault()
