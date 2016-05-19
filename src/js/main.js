// Created by Colin Osterhout
// University of Alaska Southeast
// ctosterhout@alaska.edu
//
// Copyright @2016 University of Alaska Southeast
// License TBD - contact author. All rights reserved.
// Created by Colin Osterhout
// University of Alaska Southeast
// ctosterhout@alaska.edu
//
// Copyright @2016 University of Alaska Southeast
// License TBD - contact author. All rights reserved.
define([
    // Standard items that export a variable
    'require',
    'jquery',
    'underscore',

    // Transition modules to support existing functionality
    'transitional/forms',

    // Add-ons to the above
    'jquery.xml2json'
], function(require, $, _, TransitionalForms) {
    'use strict';

    var modules = [];

    var initModules = function (options) {
        $('div[data-module]').each(function () {
            // Save away the jQuery version of this element
            var el = this,
                $defaults = $($(el).data('defaults')).first(),
                type = _.last(/^(?:text|application)\/(json|xml)$/.exec($defaults.attr('type'))) || 'noop';

            require(
                ['modules/' + $(el).data('module')],
                function (mod) {
                    var module = new mod(
                        // Build the options object by combining data- attributes,
                        // module config options, and defaults specified in the DOM (if available)
                        _.defaults(
                            // Start with the data- attributes, omitting the module name and the defaults setting
                            _.omit($(el).data(), ['module', 'defaults']),
                            // Add in some default options
                            {
                                el: el,
                                baseTemplateUrl: options.baseTemplateUrl,
                                templateScheme: options.templateScheme
                            },
                            // Merge with defaults specified in the DOM (if available)
                            {
                                defaults: {
                                    'json': $.parseJSON,
                                    'xml': $.xml2json,
                                    'noop': _.noop
                                }[type]($defaults.html()) || {}
                            }
                        )
                    );

                    // Push the newly created module on the stack
                    // We could do some sort of event here to alert subscribers in the future
                    modules.push(module);
                }
            );
        });
    };

    var initTransitionalModules = function (options) {
        TransitionalForms.initialize();
    };

    var main = {
        initialize: function (options) {
            initModules(options);
            initTransitionalModules(options);
        }
    };

    return main;
});
