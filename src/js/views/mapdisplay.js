/**
* @Author: Colin Osterhout <ctosterhout>
* @Date:   2016-05-07T21:07:51-08:00
* @Email:  ctosterhout@alaska.edu
* @Project: BERT
* @Last modified by:   ctosterhout
* @Last modified time: 2016-06-01T23:05:52-08:00
* @License: Released under MIT License. Copyright 2016 University of Alaska Southeast.  For more details, see https://opensource.org/licenses/MIT
*/


/*
Things that we'll need to pass in by the controller:

div for the map display - passed along to Google maps creator

Template for point display
*/
define([
    'jquery',
    'underscore',
    'backbone',
    'google_maps',

    // Allow runtime loading of templates
    'require'
], function ($, _, Backbone, google, require) {
    'use strict';

    var MapDisplayView = Backbone.View.extend({
        tagName: 'div',

        initialize: function (options) {
            var that = this;

            that.mapOptions = _.chain(options)
                .filterArg(['zoom', 'type', 'idShow', 'defaults', 'templatePath', 'templateScheme'])
                .defaults({
                    zoom: '4',
                    type: google.maps.MapTypeId.ROADMAP,
                    templateScheme: 'bs2'
                }).value();

            // Set up view variables to connect us to the model and the DOM
            that.model = options.model;
            that.el = options.el;
        },

        render: function () {
            // Create a new location in an array and populate
            // based on the values in the XML response
            var that = this,
                createMapObject = function (options) {
                    that.map = new google.maps.Map(
                        options.el,
                        // Create the options array for Google
                        // This is made intentionally general for future reference
                        _.extend(
                            // Combine the valid options with same names as Google expects
                            _.pick(
                                options,
                                ['zoom', 'center']
                            ),
                            // Add in a modified key set
                            {
                                mapTypeId: options.type
                            },
                            // Convert selected values to numbers
                            _.mapObject(
                                _.pick(
                                    options,
                                    ['zoom']
                                ),
                                Number
                            )
                        )
                    );

                    return that.map;
                },
                // Function used to populate map with location markers and view windows
                populateMapWithLocations = function (locations, locationsShow) {
                    // Load up the template we'll need for displaying the map
                    require(['hbs!' + that.mapOptions.templatePath], function (template) {
                        _.each(locations, function (location) {
                            location.map = that.map;

                            // Create the marker point on the map, omitting icon if undefined
                            location.marker = new google.maps.Marker(
                                _.extend(
                                    _.pick(
                                        location,
                                        ['position', 'icon']
                                    ),
                                    {
                                        map: that.map,
                                        title: location.label
                                    }
                                )
                            );


                            location.infowindow = new google.maps.InfoWindow({
                                content: template(
                                    _.defaults(
                                        _.pick(
                                            location,
                                            ['image', 'content', 'address']
                                        ),
                                        {
                                            title: location.label
                                        },
                                        {
                                            title: 'University of Alaska Southeast'
                                        }
                                ))
                            });

                            location.marker.addListener('click', function(){
                                // Close all other windows
                                _.each(locations, function (location) {
                                    location.infowindow.close();
                                });

                                // Open this window
                                location.infowindow.open(location.map, location.marker);
                            });
                        });

                        // Show the info window for any default displayed marker
                        _.each(locationsShow, function (location) {
                            location.infowindow.open(location.map, location.marker);
                        });
                    });
                },
                // Initialize the locations array from the model data
                locations = _.map(
                    that.model.get('point'),
                    function (point) {
                        return _.extend(
                            // Filter out data we care about
                            _.pick(point, ['id', 'label', 'image', 'icon', 'address']),
                            // Add it to constructed data and simplified value
                            {
                                position: new google.maps.LatLng(
                                    Number(point.latitude),
                                    Number(point.longitude)
                                ),
                                show: point.default.value === 'Yes',
                            }
                            );
                        }
                    ),
                // Determine the points that need to be shown at map startup
                locationsShow = _.filter(locations, function (location) {
                    // If showId is set, then filter on that.  If it's not set
                    // then filter on any of the points in the XML file with the
                    // 'default' element containing the element 'value' with a
                    // value of 'Yes'
                    if ( _.isUndefined(that.mapOptions.idShow) ) {
                        return ( location.show === true );
                    } else {
                        return ( location.id === that.mapOptions.idShow );
                    }
                }),
                populateMap = _.bind(populateMapWithLocations, that, locations, locationsShow),
                createMap = _.compose(populateMap, _.bind(createMapObject, that, {
                    // If there's any items marked explicitly to be shown
                    // then pick the first as the center, or else pick the
                    // first spot on the list
                    center: locationsShow.length ?
                        locationsShow[0].position :
                        locations[0].position,
                    zoom: _.isUndefined(that.model.get('zoom')) ? that.mapOptions.zoom : Number(that.model.get('zoom')),
                    type: that.mapOptions.type,
                    el: that.el
                })),
                $parent = $(that.el).closest('.modal');

                // Create the google map (if we have points to map),
                // and then place all the locations on the map

                // Attach event handler to any upstream modals, if available
                if ( $parent.length === 0 || $parent.is(":visible") ) {
                    // We're not modal, or else the div is visible - create the map
                    createMap();
                } else {
                    $parent.on(
                        {
                            'bs2': 'shown',
                            'bs3': 'shown.bs.modal'
                        }[that.mapOptions.templateScheme] || 'shown',
                        function(){
                            // Wait until the modal is shown, and then create the map
                            createMap();
                        }
                    );
                }
            }
        }
    );

    return MapDisplayView;
});
