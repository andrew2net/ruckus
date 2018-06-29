BuilderSwitcher = ->
  $('.switch-builder').each ->
    $checkbox = $(@).find('input[type="checkbox"]')
    $section = $(@).closest('.section-editable')
    $hidden_field = $checkbox.closest('.toggle').find("input[type=\"hidden\"]")
    $group = $($(@).attr('blocks'))

    if $checkbox.is(':checked')
      $(@).addClass 'active'
      $hidden_field.val "1"
      $section.removeClass('section-disabled')
      $group.removeClass('section-disabled') if $group?
    else
      $(@).removeClass 'active'
      $hidden_field.val "0"
      $section.addClass('section-disabled')
      $group.addClass('section-disabled') if $group?


window.BuilderSwitcher = BuilderSwitcher

$ ->
  switchToggle = (el) ->
    el.toggleClass 'active'
    $section = el.closest('.section-editable')
    $sectionGroup = $(el.attr('blocks'))
    $checkbox = el.find('input[type="checkbox"]')

    if el.hasClass('active')
      $checkbox.prop 'checked', true
      $checkbox.closest('.toggle').find("input[type=\"hidden\"]").val "1"
      $section.removeClass('section-disabled')
      $sectionGroup.removeClass('section-disabled')
    else
      $checkbox.prop 'checked', false
      $checkbox.closest('.toggle').find("input[type=\"hidden\"]").val "0"
      $section.addClass('section-disabled')
      $sectionGroup.addClass('section-disabled')

    el.closest('form').submit()

  $(document).on 'click', '.switch-builder', (e) ->
    switchToggle($(@))
    group = $(@).attr('group')

    $(".switch-builder[group='" + group + "']").not(@).each ->
      switchToggle($(@))

  BuilderSwitcher()
