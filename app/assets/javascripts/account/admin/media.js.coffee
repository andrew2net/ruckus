$ ->
  $(document).on 'ruckus:sorted', (doc, el, ids) ->
    if $('.draggable.media-tiles').length
      url = $('.draggable.media-tiles').data('sorted-url')
      $.ajax url, data: {profile: { media_stream_ids: ids }}, type: 'PATCH'

  $(document).on 'change', '.instant-upload', ->
    $(@).closest('form').submit()

  $(document).on 'click', '.media-block', (e) ->
    mediaItem = $(@).closest('.media-tiles')
    checkBox = $(@).find('.check-box')
    e.stopPropagation()

    if mediaItem.hasClass('media-stream')
      checkBox.toggleClass('active')
      input = checkBox.find("input")
      input.attr 'checked', not input.attr 'checked'
    else
      $('.check-box').removeClass('active').find("input").removeAttr('checked')
      checkBox.addClass('active')
      checkBox.find("input").prop('checked', 'checked')

    if mediaItem.hasClass('media-cropable')
      mediaItem.prev('.button-photo-selected').trigger 'click'
    else
      if not mediaItem.hasClass('media-stream')
        $(@).addClass('non-clickable')
        $(@).find('.loader').fadeIn(250)
        $(@).closest('form').submit()


  $(document).on 'click', '.photo-stream-actions .button', ->
    $('#media-profile-form').submit()


  $(document).on 'click', '.photo-stream-actions .cancel', (e) ->
    e.preventDefault()
    $.magnificPopup.instance.close()
