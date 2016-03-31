(function(mymodule) {
    mymodule(window.jQuery, window, document);
}(function($, window, document) {
    $(function () {
        // We're looking for all div elements of class 'uas-widget-map' with
        // the necessary attributes
        $('div.uas-widget-map[data-map-src][data-map-type]').each(function () {
            var el = this,
                map = {},
                locations = [],
                mapTypeId,
                showId = '';

            // Determine map type
            switch ($(this).attr('data-map-type')) {
                case 'hybrid': mapTypeId = google.maps.MapTypeId.HYBRID; break;
                case 'roadmap': mapTypeId = google.maps.MapTypeId.ROADMAP; break;
                case 'satellite': mapTypeId = google.maps.MapTypeId.SATELLITE; break;
                case 'terrain': mapTypeId = google.maps.MapTypeId.TERRAIN; break;
                default: mapTypeId = google.maps.MapTypeId.HYBRID;
            }

            // See if we're supposed to show a particular point
            if ($(this).attr('data-map-show') !== undefined) {
                showId = $(this).attr('data-map-show');
            }

            // Begin AJAX call to get the map data
            $.ajax({
                url: $(this).attr('data-map-src'),
                dataType: 'xml'
            }).done(function (xml) {
                // Parse XML response - get center point location and zoom level
                var locationsShow, centerPos,
                    centerLat = Number($('system-data-structure > latitude', xml).first().html()),
                    centerLng = Number($('system-data-structure > longitude', xml).first().html()),
                    zoom = Number($('system-data-structure > zoom', xml).first().html());

                // Create a new location in an array and populate
                // based on the values in the XML response
                $('point', xml).each(function () {
                    var id, lat, lng, title, content, show;
                    id = $('id', this).first().html();
                    lat = Number($('latitude', this).first().html());
                    lng = Number($('longitude', this).first().html());
                    title = $('label', this).first().html();
                    content = $('content', this).first().html();
                    show = $('default > value', this).first().html() === 'Yes';

                    locations.push({
                        id: id,
                        position: new google.maps.LatLng(lat, lng),
                        title: title,
                        content: content,
                        show: show
                    })
                });

                // Determine the points that need to be shown at map startup
                locationsShow = locations.filter(function (location) {
                    // If showId is set, then filter on that.  If it's not set
                    // then filter on any of the points in the XML file with the
                    // 'default' element containing the element 'value' with a
                    // value of 'Yes'
                    if (showId !== '') {
                        return (location.id === showId);
                    } else {
                        return ( location.show === true );
                    }
                });

                // If any of the points are listed with "show: true" then
                // use those coordinates
                if (locationsShow.length) {
                    centerPos = locationsShow[0].position;
                } else {
                    centerPos = new google.maps.LatLng(centerLat, centerLng);
                }

                // Create map
                map = new google.maps.Map(el, {
                    center: centerPos,
                    zoom: zoom,
                    mapTypeId: mapTypeId
                });

                // Create marker for each location and attach map to marker
                locations.forEach(function (location) {
                    location.map = map;
                    location.marker = new google.maps.Marker({
                        position: location.position,
                        map: map,
                        title: location.title
                    });
                    location.infowindow = new google.maps.InfoWindow({
                        content: location.content
                    });
                    location.marker.addListener('click', function(){
                        location.infowindow.open(location.map, location.marker);
                    });
                });

                // Show the info window for any default displayed marker
                locationsShow.forEach(function (location) {
                    location.infowindow.open(location.map, location.marker);
                });
            }).fail(function (jqXHR, status, error) {
                throw 'Failed to load map data. Status: ' + status;
            });
        });
    });
}));
