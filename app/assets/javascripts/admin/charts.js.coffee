jQuery ->
  new Morris.Line
    element: 'chart'
    data: $('#chart').data('records')
    xkey: 'created_at'
    ykeys: ['count']
    labels: [$('#chart').data('label')]
    dateFormat: (x) ->
      formatDate(x)
    xLabelFormat: (x) ->
      formatDate(x)

  new Morris.Line
    element: 'amounts_chart'
    data: $('#amounts_chart').data('records')
    xkey: 'created_at'
    ykeys: ['total_amount']
    labels: [$('#amounts_chart').data('label')]
    preUnits: '$'
    dateFormat: (x) ->
      formatDate(x)
    xLabelFormat: (x) ->
      formatDate(x)

formatDate = (x) ->
  date = new Date(x)
  month = addLeadingZero((date.getMonth() + 1))
  day = addLeadingZero(date.getDate())
  year = date.getFullYear()
  [month, day, year].join('/')

addLeadingZero = (n) ->
  if n < 10
    '0' + n
  else
    n
