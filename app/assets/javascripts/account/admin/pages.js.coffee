$ ->
  $(document).on 'click', '.icon-minus-circled', ->
    $('form.new_account').remove()
    $('#create-account-button').show()

