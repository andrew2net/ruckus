#= require shared/global_requirements

#= require jquery.mcustomscrollbar.concat.min
#= require validator

#= require shared/remote_forms
#= require shared/edit-modal
#= require shared/upload
#= require shared/caps_lock
#= require_tree ./account/public

$ ->
  $(document).on 'click', '#media .media-control', ->
    $carousel = $("#media-slider").find(".scrollWrapper")
    if $(@).hasClass('media-next')
      $carousel.kinetic "start", velocity: 10
    else if $(@).hasClass('media-prev')
      $carousel.kinetic "start", velocity: -10
    setTimeout (->
      $carousel.kinetic "stop"
    ), 300

  $(window).on "load", ->
    if $(".expansion-container.active").height() > $(".expansion-wrapper").height()
      $(".expansion-button").removeClass('hide')
      $(".expansion-wrapper").removeClass('short')

  $(document).on 'change', 'input[name="donation[amount]"]', (e) ->
    amount = $(@).val()
    $('#donation_amount[type="hidden"]').val(amount)

  # Validate Other payment
  $(document).on 'submit', '.donate-form', () ->
    $radio = $('#donation_amount_other')
    $input = $('#donation_amount[type="text"]')
    if $radio.is(":checked")
      if not $input.val()
        $(".radio.other-amount").removeClass("valid").addClass("invalid")
      else
        $(".radio.other-amount").removeClass("valid").removeClass("invalid")

  $(document).on 'change', 'input[name="donation[amount]"]', (e) ->
    if $(@).val isnt 'other'
      $(".radio.other-amount").removeClass("invalid").removeClass("valid")
