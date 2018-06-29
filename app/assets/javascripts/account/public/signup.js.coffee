window.chooseAccount = ->
  $('.choose-actions:not(.premium-actions) .button').click ->
    $btn = $(this)
    firstStep = $btn.parents('.choose-account')
    secondStep = $btn.data('id')
    firstStep.fadeOut()
    $("##{secondStep}").slideDown()
    $("##{secondStep}").mCustomScrollbar()

  $(document).on 'click', '.button.go-premium', (e) ->
    e.preventDefault()
    self = $(@)
    $.magnificPopup.open $.extend(
      callbacks:
        ajaxContentAdded: ->
          $body = undefined
          $body = $(@content).find('.ruckus-modal-body')
          if $body.length
            $body.mCustomScrollbar
              theme: 'dark-2'
              scrollInertia: 400
      items:
        src: self.attr('href')
        type: 'ajax'
      closeOnBgClick: false)

    $.magnificPopup.instance.close = ->
      location.reload()
