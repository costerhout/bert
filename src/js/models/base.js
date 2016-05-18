define([
    'jquery',
    'underscore',
    'backbone',
    'jquery.xml2json'
], function ($, _, Backbone) {
    'use strict';

    // Create the base model factory - this will be extended by all models
    var Base = Backbone.Model.extend({
        // Initial state variables
        options: {
            format: 'xml',
            readonly: true,
            url: '#',
            defaults: {}
        },

        // Provide for an initialization function to set object parameters based
        // on passed in configuration, specifically to set up different functions
        // to parse and fetch data depending on the expected data store type (xml or json)
        initialize: function (o) {
            var that = this,
                reset = function () {
                    // Directly manipulate the attributes array is usually a no-no,
                    // but we want to stave off the trigger event until the end
                    that.attributes = that.options.defaults || {};

                    // Finally tell the world about it
                    that.trigger('change');
                };

            that.options = _.extend(
                // Start with the default set of options
                that.options,

                // Merge with the config array (known keys)
                _.pick(
                    o,
                    _.keys(that.options)
                ),

                // Convert some values as needed (in this case the 'readonly' key to boolean)
                _.mapObject(
                    _.pick(
                        o,
                        ['readonly']
                    ),
                    Boolean
                )
            );

            // Set the default data object
            that.defaults = o.defaults || {};

            // Set the fetch function depending on the value of the dataType option
            // Function idea courtesy of http://stackoverflow.com/questions/8419061/backbonejs-with-xml-ajax
            that.fetch = {
                xml: that.options.readonly ? reset : function () {
                    return Backbone.Model.prototype.fetch.call(that, { dataType: 'xml' });
                },
                json: that.options.readonly ? reset : that.fetch,
            }[that.options.format];

            // Set the parse function depending on the value of the dataType option
            // For readonly models don't even bother
            that.parse = {
                xml: that.options.readonly ? _.noop : $.xml2json,
                json: that.options.readonly ? _.noop : that.parse
            }[that.options.format];
        }
    });

    // Return the model to the controller
    return Base;
});
