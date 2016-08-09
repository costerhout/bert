/**
* @Author: Colin Osterhout <ctosterhout>
* @Date:   2016-05-09T14:31:58-08:00
* @Email:  ctosterhout@alaska.edu
* @Project: BERT
* @Last modified by:   ctosterhout
* @Last modified time: 2016-08-08T14:25:13-08:00
* @License: Released under MIT License. Copyright 2016 University of Alaska Southeast.  For more details, see https://opensource.org/licenses/MIT
*/



// Define the mapdisplay controller module
define([
    'underscore',           // handy util
    'backbone',
    'models/soundings-feed',
    'views/soundings-feed'
], function (_, Backbone, SoundingsFeedModel, SoundingsFeedView) {
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

        // Derive from the event interface
        _.extend(this, Backbone.Events);

        // If the model fails to load or parse properly, then fail
        this.listenToOnce(model, 'error', _.isFunction(options.fail) ? options.fail : _.noop);

        // Listen for the view to be done - when that's finished call the success callback
        this.listenToOnce(view, 'render', _.isFunction(options.success) ? options.success : _.noop);

        // Have the view listen to changes for when the model has finished loading
        view.listenToOnce(model, 'sync', view.render);

        // Fetch the module data
        model.fetch();
    }

    SoundingsFeedModule.prototype = {
        constructor: SoundingsFeedModule
    };

    // Return the initialization routine to the main controller
    return SoundingsFeedModule;
});
