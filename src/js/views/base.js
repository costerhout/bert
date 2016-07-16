/**
* @Author: Colin Osterhout <ctosterhout>
* @Date:   2016-05-27T14:08:18-08:00
* @Email:  ctosterhout@alaska.edu
* @Project: BERT
* @Last modified by:   ctosterhout
* @Last modified time: 2016-06-30T08:49:10-08:00
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

    // Allow runtime loading of templates
    // 'hbs!templates/bs2/base'
    'require'
], function ($, _, Backbone, require) {
    'use strict';

    var BaseView = Backbone.View.extend({
        tagName: 'div',

        initialize: function (options) {
            var that = this;

            that.viewOptions = _.chain(options)
                .filterArg(['templatePath'])
                .value();

            // Set up view variables to connect us to the model and the DOM
            that.model = options.model;
            that.el = options.el;
        },

        render: function () {
            // Save this for later
            var that = this,
                // Define the basic template render function
                renderTemplate = function (template) {
                    $(that.el).empty();
                    $(that.el).append(template(that.model.attributes));
                    return that;
                };

            // Bring in the template that is asked for
            require(['hbs!' + that.viewOptions.templatePath], renderTemplate);
        }
    });

    return BaseView;
});
