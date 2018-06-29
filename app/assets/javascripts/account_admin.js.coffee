#= require shared/global_requirements
#= require shared/builder_switcher

#= require jquery.scrollto.min
#= require jquery.tablesorter
#= require jquery.flot.min
#= require jquery.flot.time.min
#= require shared/upload
#= require shared/edit-modal
#= require load-image.min
#= require jquery.jcrop
#= require shared/caps_lock

#= require_tree ./account/admin
#= require account_onboarding
#= require jquery.mcustomscrollbar.concat.min

$ ->
  $('.progress-list').mCustomScrollbar theme: "light-2"
  $('.post').mCustomScrollbar theme: "dark-2"

  $('.collapse').on 'show.bs.collapse', ->
    $(@).closest('.member-list-pad').find('.pull-right i').removeClass('icon-plus-circled').addClass('icon-minus-circled')

  $('.collapse').on 'hidden.bs.collapse', ->
    $(@).closest('.member-list-pad').find('.pull-right i').removeClass('icon-minus-circled').addClass('icon-plus-circled')
    $(@).find('form').hide()
    $(@).find('#create-account-button').show()
