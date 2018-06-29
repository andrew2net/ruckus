$ ->
  RuckusAdmin._toggleDrop = ($el, issueCategorySlug, toggle) ->
    parentDrop = $el.closest('.ruckus-drop')
    dropSelected = parentDrop.find('.ruckus-selected')
    dropOptions = parentDrop.find('.ruckus-drop-options')
    issueCategorySlug = $el.data('issue-category')

    if issueCategorySlug
      dropSelected.find('.category').html($el.find('.category').html())
      $(parentDrop.data('field')).val(issueCategorySlug)

    dropOptions.toggle()

  $(document).on 'click.selectOption', '.issues .ruckus-drop-options > li', ->
    val = $(@).data('issue-category')
    $('#issue_issue_category_id').val(val)

  $(document).on 'ruckus:sorted', (doc, el, ids) ->
    if $('body.issues').length or $('.ruckus-modal-body.issues').length
      url = $('.issues ul.draggable').data('sorted-url')
      $.ajax url, data: {ids: ids}, type: 'POST'

