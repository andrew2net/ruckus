$ ->
  RuckusAdmin._eventsFunctions = () ->
    $('#event_start_time_date').datepicker
      dateFormat: 'mm/dd/yy',
      minDate: '0'

    if $('#event_start_time_date').length
      if $('#event_start_time_date').val().length
        $('.end-time-row').show();
        $('#display-end-time-row').hide();
      else
        $('.end-time-row').hide();
        $('#display-end-time-row').show();

    $(document).on 'click', '#display-end-time-row', (e) ->
      e.preventDefault();
      $('.end-time-row').show();
      $(@).hide();

    $('#event_end_time_date').datepicker
      dateFormat: 'mm/dd/yy',
      minDate: $( '#event_start_time_date' ).datepicker('getDate')

    $(document).on 'change', '#event_start_time_date', ->
      startDateString = $(@).val()
      startDate = new Date(startDateString)
      $('#event_end_time_date').datepicker('option', 'minDate', startDate)
