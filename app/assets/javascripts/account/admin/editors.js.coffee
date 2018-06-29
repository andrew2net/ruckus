$ ->
  $(document).on 'submit', '#edit_ownership', (e) ->
    if $('#ownership_type').val() == 'AdminOwnership'
      userApproved = confirm 'Are you sure? You will no longer be an admin of this site.'
      $(@).find('.mfp-close.cancel').click() unless userApproved
      userApproved
