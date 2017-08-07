/**
* @Author: Colin Osterhout <ctosterhout>
* @Date:   2016-10-21T13:50:25-08:00
* @Email:  ctosterhout@alaska.edu
* @Project: BERT
 * @Last modified by:   ctosterhout
 * @Last modified time: 2017-08-06T11:17:02-08:00
* @License: Released under MIT License. Copyright 2016 University of Alaska Southeast.  For more details, see https://opensource.org/licenses/MIT
*/

define([
    'module',
    'underscore',           // handy util
    'backbone',
    'models/decisiontree',
    'views/decisiontree'
], function (module, _, Backbone, DecisionTreeModel, DecisionTreeView) {
    'use strict';

    function DecisionTreeModule(options) {
        // Configure arguments / options
        // Since we are bs2 / bs3 agnostic we don't require templateScheme
        var optionsModel = _.chain(options)
                .filterArg(['format', 'url'])
                .value(),
            model = new DecisionTreeModel(options.defaults || {}, optionsModel),
            optionsView = _.chain(options)
                .checkArgMandatory(['el'])
                // Apply sensible view defaults
                .defaults({
                    animationDuration: module.config().animationDuration
                })
                .filterArg(['el', 'animationDuration'])
                .extend({ model: model })
                .value(),
            view = new DecisionTreeView(optionsView);

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

    DecisionTreeModule.prototype = {
        constructor: DecisionTreeModule
    };

    // Return the initialization routine to the main controller
    return DecisionTreeModule;
});
