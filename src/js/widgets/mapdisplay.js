(function(mymodule) {
    mymodule(window.jQuery, window, document);
}(function($, window, document) {
    $(function () {
        // We're looking for all div elements of class 'mapdisplay' with
        // the necessary attributes
        $('div.mapdisplay[data-map-src][data-map-type]').each(function () {
            var el = this,
                map = undefined,    // Set to undefined to check for init later on
                locations = [],
                locationsShow = [],
                mapTypeId,
                centerPos = {},
                showId = '';

            // Determine map type
            mapTypeId = {
                hybrid: google.maps.MapTypeId.HYBRID,
                roadmap: google.maps.MapTypeId.ROADMAP,
                satellite: google.maps.MapTypeId.SATELLITE,
                terrain: google.maps.MapTypeId.TERRAIN
            }[$(this).attr('data-map-type')];

            // Default case
            mapTypeId = typeof mapTypeId === 'undefined' ? google.maps.MapTypeId.HYBRID : mapTypeId;

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
                centerPos = new google.maps.LatLng(
                        Number($('system-data-structure > latitude', xml).first().html()),
                        Number($('system-data-structure > longitude', xml).first().html())
                    ),
                    zoom = Number($('system-data-structure > zoom', xml).first().html());

                // Create a new location in an array and populate
                // based on the values in the XML response
                $('point', xml).each(function () {
                    locations.push({
                        id: $('id', this).first().html(),
                        position: new google.maps.LatLng(
                            Number($('latitude', this).first().html()),
                            Number($('longitude', this).first().html())
                        ),
                        title: $('label', this).first().html(),
                        content: $('content', this).first().html(),
                        show: $('default > value', this).first().html() === 'Yes',
                        url_image: $('image', this).first().html(),
                        url_icon: $('icon', this).first().html(),
                        address: $('address', this).first().html()
                    });
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
                }

                // Should we create the map now or upon a modal popup?
                var $parent = $(el).closest(".modal");

                if ( $parent.length === 0 || $parent.is(":visible") ) {
                    // We're not modal, or else the div is visible - create the map
                    create_map();
                } else {
                    $parent.on('shown.bs.modal', function(){
                        // Wait until the modal is shown, and then create the map
                        create_map();
                    });
                }
            }).fail(function (jqXHR, status, error) {
                throw 'Failed to load map data. Status: ' + status;
            });

            // Procedure to generate the Google map
            function create_map () {
                // Create map (if not already created)
                if (typeof map === 'undefined') {
                    map = new google.maps.Map(el, {
                        center: centerPos,
                        zoom: zoom,
                        mapTypeId: mapTypeId
                    });

                    // Create marker for each location and attach map to marker
                    locations.forEach(function (location) {
                        var marker_options;

                        // TODO - this may be a good place for the use of a template
                        // If no additional content is specified, then use the title
                        if (location.content === '') {
                            location.content = location.title;
                        }

                        // Modify window content if there's an image specified
                        if (location.url_image !== '') {
                            location.content =
                                "<img src='" + location.url_image + "'"
                                + " alt='" + location.title + "'"
                                + " style='max-width: 120px;'"
                                + "/>"
                                + "<div>"
                                + location.content
                                + "</div>";
                        }

                        // Modify window content if there's an address specified
                        if (location.address !== '') {
                            location.content += "<br/>"
                                + location.address;
                        }

                        location.map = map;

                        // Initialize the marker options to pass to constructor
                        marker_options = {
                            position: location.position,
                            map: map,
                            title: location.title
                        };

                        // If there's a icon specified then use that as a URL string
                        if (location.url_icon !== '') {
                            marker_options.icon = location.url_icon;
                        }

                        // Create the marker point on the map
                        location.marker = new google.maps.Marker(marker_options);

                        // Create the window that pops up on click and attach handler
                        // to open the window upon click
                        location.infowindow = new google.maps.InfoWindow({
                            content: location.content
                        });
                        location.marker.addListener('click', function(){
                            // Close all other windows
                            locations.forEach(function (location) {
                                location.infowindow.close();
                            });

                            // Open this window
                            location.infowindow.open(location.map, location.marker);
                        });
                    });

                    // Show the info window for any default displayed marker
                    locationsShow.forEach(function (location) {
                        location.infowindow.open(location.map, location.marker);
                    });
                }
            }
        });
    });
}));
