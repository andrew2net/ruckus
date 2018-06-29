$ ->
  $(document).on 'input change', 'input[name="donation[amount]"]', ->
    amount = $(@).val()
    $('#donation_amount[type="hidden"]').val(amount)

  $(document).on 'input change', '#donation_amount[type="text"]', ->
    amount = $(@).val()
    maximum = $(@).data('max')
    amount = amount.replace(/[^0-9\.]/g, '')
    amount = maximum if maximum? and amount > maximum
    $(@).val(amount)
