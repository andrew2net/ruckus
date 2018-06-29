#= require shared/builder_switcher

$ ->
  # Remote forms + Jquery validation
  $(document).on 'ajax:before', 'form.validate[data-remote=true]', (e)->
    !!$(e.target).data('FormValidator').validate()

  #Live ajax on loaded content
  $(document).ajaxSuccess ->
    chooseAccount()
    if not $('body').hasClass('home')
      $('.ajax-modal-link').magnificPopup($.extend(
        { type: 'ajax' },
        RuckusAccount.defaultMFPOptions
      ));
    BuilderSwitcher()

  $('form.validate').on 'submit', (e) ->
    return false unless $(e.target).data('FormValidator').validate()

  $('i.tip').tooltip();

  $(window).unload ->
    $.rails.enableFormElements $($.rails.formSubmitSelector)
    return

  $("form.validate").on "submit", ->
    false unless $(@).data('FormValidator').validate()

  $(document).on 'click', '.social-feed-modal-link', (e) ->
    e.preventDefault()
    src = $(@).attr "href"
    $.magnificPopup.open($.extend(
      {
        items:
          src: src
        type: "ajax"
      },
      RuckusAccount.defaultMFPOptions
    ));
