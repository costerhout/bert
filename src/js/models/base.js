define([
    'jquery',
    'underscore',
    'backbone',
    'jquery.xml2json'
], function ($, _, Backbone) {
    'use strict';

    // Create the base model factory - this will be extended by all models
    var BaseModel = Backbone.Model.extend({
        // Initial state variables
        defaults: {},

        options: {
            format: 'xml',
            url: '#'
        },

        // Provide for an initialization function to set object parameters based
        // on passed in configuration, specifically to set up different functions
        // to parse and fetch data depending on the expected data store type (xml or json)
        initialize: function (attributes, options) {
            var that = this,
                reset = function () {
                    // Directly manipulate the attributes array is usually a no-no,
                    // but we want to stave off the trigger event until the end
                    that.attributes = _.clone(that.defaults) || {};

                    // Finally tell the world about it
                    that.trigger('sync');
                };

            // Initialize the defaults object with the passed in values
            that.defaults = attributes;

            // Massage the options object which keeps track of initial state
            that.options = _.defaults(
                _.pick(
                    options,
                    _.keys(that.options)
                ),
                that.options
            );

            // Set the URL for this model
            that.urlRoot = that.options.url;

            // Set the fetch function depending on the value of the dataType option
            // // Function idea courtesy of http://stackoverflow.com/questions/8419061/backbonejs-with-xml-ajax
            // We use the url === '#' flag in order to determine if we should just use the default
            // object as a source whenever we fetch
            that.fetch = {
                xml: that.options.url === '#' ? reset : function () {
                    return Backbone.Model.prototype.fetch.call(that, { dataType: 'xml' });
                },
                json: that.options.url === '#' ? reset : that.fetch,
            }[that.options.format];

            // Set the parse function depending on the value of the dataType option
            // For default only models don't even bother
            that.parse = {
                // Here we wrap the xml2json call within another function to limit the number of arguments we pass,
                // as the xml2json call interprets the second argument as a boolean, where if truthy it makes everything an array
                xml: that.options.url === '#' ? _.noop : _.wrap($.xml2json, function (func, xml) { return func(xml); }),
                json: that.options.url === '#' ? _.noop : that.parse
            }[that.options.format];
        }
    });

    // Return the model to the controller
    return BaseModel;
});
