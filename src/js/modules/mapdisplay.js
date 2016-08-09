/**
* @Author: Colin Osterhout <ctosterhout>
* @Date:   2016-05-09T14:31:58-08:00
* @Email:  ctosterhout@alaska.edu
* @Project: BERT
* @Last modified by:   ctosterhout
* @Last modified time: 2016-08-08T14:25:26-08:00
* @License: Released under MIT License. Copyright 2016 University of Alaska Southeast.  For more details, see https://opensource.org/licenses/MIT
*/



// Define the mapdisplay controller module
define([
    'underscore',           // handy util
    'backbone',
    'models/mapdisplay',    // Map display model
    'views/mapdisplay'     // Map display view
], function (_, Backbone, MapDisplayModel, MapDisplayView) {
    'use strict';

    function MapDisplayModule(options) {
        // Configure arguments / options
        // Since we are bs2 / bs3 agnostic we don't require templateScheme
        var optionsMapModel = _.chain(options)
                // Generate list of arguments appropriate for the model
                .filterArg(['format', 'url'])
                .value(),
            model = new MapDisplayModel(options.defaults || {}, optionsMapModel),
            // Generate list of arguments appropriate for the view
            optionsMapView = _.chain(options)
                .checkArgMandatory(['el'])
                .filterArg(['el', 'type', 'zoom', 'idShow', 'templateScheme'])
                .extend({ model: model })
                .defaults({
                    // Synthesize templatePath from the passed in module options (from main)
                    // If templateName is specified then load that from an external resource
                    templatePath: _.has(options, 'templateName')
                        ? _.reject([
                            options.baseTemplateUrl,
                            options.templateScheme,
                            options.templateName
                        ], _.isEmpty).join('/')
                        : options.baseTemplateUrlInternal + '/' + 'mapdisplay.point'
                })
                .value(),
            view = new MapDisplayView(optionsMapView);

        // Derive from the event interface
        _.extend(this, Backbone.Events);

        // If the model or view fails to load or parse properly, then fail
        this.listenToOnce(model, 'error', _.isFunction(options.fail) ? options.fail : _.noop);
        this.listenToOnce(view, 'error', _.isFunction(options.fail) ? options.fail : _.noop);

        // Listen for the view to be done (or deferred)- when that's finished call the success callback
        // this.listenToOnce(view, 'render', _.isFunction(options.success) ? options.success : _.noop);
        this.listenToOnce(view, 'render render_deferred', _.isFunction(options.success) ? options.success : _.noop);

        // Have the view listen to changes for when the map has finished loading
        // This method only allows one creation of the map
        view.listenToOnce(model, 'sync', view.render);

        // Fetch the map data
        model.fetch();
    }

    MapDisplayModule.prototype = {
        constructor: MapDisplayModule
    };

    // Return the initialization routine to the main controller
    return MapDisplayModule;
});
