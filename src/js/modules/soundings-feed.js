/**
* @Author: Colin Osterhout <ctosterhout>
* @Date:   2016-05-09T14:31:58-08:00
* @Email:  ctosterhout@alaska.edu
* @Project: BERT
* @Last modified by:   ctosterhout
* @Last modified time: 2016-06-23T14:38:30-08:00
* @License: Released under MIT License. Copyright 2016 University of Alaska Southeast.  For more details, see https://opensource.org/licenses/MIT
*/



// Define the mapdisplay controller module
define([
    'underscore',           // handy util
    'models/soundings-feed',    // Map display model
    'views/soundings-feed'     // Map display view
], function (_, SoundingsFeedModel, SoundingsFeedView) {
    'use strict';

    function SoundingsFeedModule(options) {
        // Configure arguments / options
        // Since we are bs2 / bs3 agnostic we don't require templateScheme
        var optionsModel = _.chain(options)
                .filterArg(['format', 'url'])
                .value(),
            model = new SoundingsFeedModel(options.defaults || {}, optionsModel),
            optionsView = _.chain(options)
                .checkArgMandatory(['el'])
                .filterArg(['el', 'count', 'departments'])
                .extend({ model: model })
                .value(),
            view = new SoundingsFeedView(optionsView);

        // Have the view listen to changes for when the map has finished loading
        // This method only allows one creation of the map
        view.listenToOnce(model, 'sync', view.render);

        // Fetch the map data
        model.fetch();
    }

    SoundingsFeedModule.prototype = {
        constructor: SoundingsFeedModule
    };

    // Return the initialization routine to the main controller
    return SoundingsFeedModule;
});
