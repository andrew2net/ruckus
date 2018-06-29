(($, window, undefined_, I) ->
  GoogleMap =
    initialize: (latitude, longitude, containerId) ->
      mapOptions =
        center: new google.maps.LatLng(latitude, longitude)
        zoom: 8
      map = new google.maps.Map(document.getElementById(containerId), mapOptions)
    generateMaps: ->
      $('.map-container').each (index, container) ->
        latitude = $(container).data('latitude')
        longitude = $(container).data('longitude')
        containerId = $(container).attr('id')
        GoogleMap.initialize(latitude, longitude, containerId)

  window.GoogleMap = GoogleMap

) jQuery, window, null, Impress
