$ ->
  $(document).on 'ruckus:sorted', (doc, el, ids) ->
    if $('body.my-updates').length or $('.my-updates').length
      url = $('.my-updates ul.draggable').data('sorted-url')
      $.ajax url, data: {ids: ids}, type: 'POST'

  $('#submit_update').click ->
    id = $('#update-edit-id').val()
    url = '/account/press_releases/' + id + '.js'
    $('#update-edit').attr('action', url)

  $(document).on 'ajax:before', '#update-form', (event, xhr, status) ->
    newUrl = $('#curl-url').val()
    $('#press_release_url').val(newUrl)

  # show/hide updates
  $(document).on 'ready', ->
    $('#updates_list').hide() if $('#updates_list .trash').length == 0

  $(document).on 'ajax:success', '#update-create', (event, xhr, status) ->
    $('#updates_list').show() if $('#updates_list .trash').length > 0

  $(document).on 'click', '#updates_list .trash', ->
    $('#updates_list').hide() if $('#updates_list .trash').length == 1
