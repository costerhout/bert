// Define the mapdisplay controller module
define([
    'underscore',           // handy util
    'backbone',             // models / view framework
    'google_maps',          // includes google and google maps API
    'models/mapdisplay',    // Map display model
    'views/mapdisplay'     // Map display view
], function(_, Backbone, google, MapDisplay, MapDisplayView) {
    'use strict';

    function MapDisplayModule (options) {
        // Configure arguments / options
        // Since we are bs2 / bs3 agnostic we don't require templateScheme
        var argMandatory = ['el', 'baseTemplateUrl'],
            argMissing = _.difference(argMandatory, _.keys(options)),
            argModel = ['type', 'format', 'zoom', 'dataType', 'url'],
            argView = ['el', 'zoom', 'idShow', 'templateScheme'],
            mapModel, mapView;

        // Check for any missing mandatory options
        if (!_.isEmpty(argMissing)) {
            throw new Error('Arguments missing: ' + argMissing.toString());
        }

        // Create the MapDisplay model, specifying the type and url parameters
        mapModel = new MapDisplay(options.defaults || {}, _.pick(options, argModel));

        // Create the MapDisplayView view, passing in a merged array
        // of default settings (including the model) and parameters specified
        // by the main module filtered for valid View keys
        mapView = new MapDisplayView(
            _.defaults(
                _.pick(options, argView),
                {
                    model: mapModel,
                    templateName: options.baseTemplateUrl + '/' + 'mapdisplay.point'
                }
            )
        );

        // Have the view listen to changes for when the map has finished loading
        // This method only allows one creation of the map
        mapView.listenToOnce(mapModel, 'sync', mapView.render);

        // Fetch the map data
        mapModel.fetch();
    }

    MapDisplayModule.prototype = {
        constructor: MapDisplayModule
    };

    // Return the initialization routine to the main controller
    return MapDisplayModule;
});
