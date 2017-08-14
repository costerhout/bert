/**
* @Author: Colin Osterhout <ctosterhout>
* @Date:   2016-05-09T14:31:58-08:00
* @Email:  ctosterhout@alaska.edu
* @Project: BERT
 * @Last modified by:   ctosterhout
 * @Last modified time: 2017-08-08T10:37:33-08:00
* @License: Released under MIT License. Copyright 2016 University of Alaska Southeast.  For more details, see https://opensource.org/licenses/MIT
*/

// Define the Soundings controller module
define([
    'underscore',           // handy util
    'backbone',
    'models/base',
    'views/menu'
], function (_, Backbone, Model, MenuView) {
    'use strict';

    function MenuModule(options) {
        // Configure arguments / options
        // Since we are bs2 / bs3 agnostic we don't require templateScheme
        var optionsModel = _.chain(options)
                .filterArg(['format', 'url', 'cacheBust'])
                .value(),
            model = new Model(options.defaults || {}, optionsModel),
            optionsView = _.chain(options)
                .checkArgMandatory(['el'])
                .filterArg(['el', 'type', 'brandLogo', 'brandLink', 'brandLabel'])
                .extend({ model: model, id: $(options.el).attr('id') })
                .value(),
            view = new MenuView(optionsView);

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

    MenuModule.prototype = {
        constructor: MenuModule
    };

    // Return the initialization routine to the main controller
    return MenuModule;
});
