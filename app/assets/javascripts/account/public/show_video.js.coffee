$ ->
  $('.sample-modal-link').on 'click', (e) ->
    e.preventDefault()
    $video = $('.sample-site-video')
    iframeSrc = $video.find('iframe').prop('src')
    $video.show()
    $(@).find('.fa').hide()
    $video.find('iframe').prop 'src', iframeSrc + '&autoplay=1'
