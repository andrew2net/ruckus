$ ->
  originalLeave = $.fn.popover.Constructor::leave
  $.fn.popover.Constructor::leave = (obj) ->
    self = (if obj instanceof @constructor then obj else $(obj.currentTarget)[@type](@getDelegateOptions()).data("bs." + @type))
    container = undefined
    timeout = undefined
    originalLeave.call this, obj
    if obj.currentTarget
      container = $(obj.currentTarget).siblings(".popover")
      timeout = self.timeout
      container.one "mouseenter", ->
        #We entered the actual popover – call off the dogs
        clearTimeout timeout
        #Let's monitor popover content instead
        container.one "mouseleave", ->
          $.fn.popover.Constructor::leave.call self, self
          return
        return

  $('[data-toggle="popover"]').popover({ trigger: 'click hover', delay: {show: 50, hide: 400}});

  $('#premiumModal').on 'hidden.bs.modal', (e) ->
    $(@).find('input:not([type="submit"]),textarea,select').val("")
    $(@).find('.help-inline').remove()
    $(@).find('.has-error').removeClass('has-error')
    return

  $(document).on 'click', '.js-show-coupon-form', (e) ->
    e.preventDefault()
    $(@).addClass "hide"
    $('.js-coupon-form').removeClass "hide"

  $(document).on 'ajax:before', '#premiumModal form', ->
    if $('.js-coupon-form').is(':visible')
      $('#premiumModal').addClass('coupon-visible')
