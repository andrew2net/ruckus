$ ->
  $(document).on 'click', 'a.cancel-link', (event) ->
    event.preventDefault()
    $.magnificPopup.close()

  $(document).on 'click', '.js-edit-modal', (e) ->
    e.preventDefault()
    self = $(@)
    editField = self.closest('[data-edit]').data('edit')

    $.magnificPopup.open $.extend
      callbacks:
        ajaxContentAdded:->
          $body = $(this.content).find('.ruckus-modal-body')
          if $body.length
            $body.mCustomScrollbar
              theme: 'dark-2'
              scrollInertia: 400
          if typeof editField != 'undefined'
            inputFields = this.content.find(".#{editField}").find('input, select, textarea')
            firstLabel= inputFields.first().prev('label').attr('for')
            inputFields.addClass('highlighted')
            $body.mCustomScrollbar('scrollTo', "label[for = #{firstLabel}]")
      items:
        src: self.attr('href')
        type: 'ajax'
      closeOnBgClick: false
