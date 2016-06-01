// Define the mapdisplay controller module
define([
    'underscore',           // handy util
    'backbone',             // models / view framework
    'google_maps',          // includes google and google maps API
    'models/mapdisplay',    // Map display model
    'views/mapdisplay'     // Map display view
], function(_, Backbone, google, MapDisplayModel, MapDisplayView) {
    'use strict';

    function MapDisplayModule (options) {
        // Configure arguments / options
        // Since we are bs2 / bs3 agnostic we don't require templateScheme
        var optionsMapModel = _.chain(options)
                .filterArg(['type', 'format', 'zoom', 'dataType', 'url'])
                .value(),
            mapModel = new MapDisplayModel(options.defaults || {}, optionsMapModel),
            optionsMapView = _.chain(options)
                .checkArgMandatory(['el'])
                .filterArg(['el', 'zoom', 'idShow', 'templateScheme'])
                .extend({
                        model: mapModel
                    }
                )
                .defaults({
                    // Synthesize templatePath from the passed in module options (from main)
                    // If templateName is specified then load that from an external resource
                        templatePath: _.has(options, 'templateName') ?
                            _.reject([
                                options.baseTemplateUrl,
                                options.templateScheme,
                                options.templateName
                            ], _.isEmpty).join('/') :
                            options.baseTemplateUrlInternal + '/' + 'mapdisplay.point'
                    }
                )
                .value(),
            mapView = new MapDisplayView(optionsMapView);

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
