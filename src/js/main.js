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
    'module',
    'require',
    'jquery',
    'underscore',

    // Transition modules to support existing functionality
    'transitional/forms',
    'transitional/tabs',
    'transitional/modals',

    // Handlebars helpers to be explicitly added
    'hbs/handlebars',
    'vendor/handlebars.form-helpers',

    // Add-ons to the above
    'jquery.xml2json'
], function(module, require, $, _, TransitionalForms, TransitionalTabs, TransitionalModals, Handlebars, HandlebarsFormHelpers) {
    'use strict';

    var modules = [];

    var initModules = function (options) {
        // Reset the list of modules
        modules.length = 0;

        $('div[data-module]').each(function () {
            // Save away the jQuery version of this element
            var el = this,
                $defaults = $($(el).data('defaults')).first(),
                type = _.last(/^(?:text|application)\/(json|xml)$/.exec($defaults.attr('type'))) || 'noop';

            require(
                ['modules/' + $(el).data('module')],
                function (mod) {
                    // Push the newly created module on the stack
                    // We could do some sort of event here to alert subscribers in the future
                    modules.push(
                        new mod(
                            // Build the options object by combining data- attributes,
                            // module config options, and defaults specified in the DOM (if available)
                            _.defaults(
                                // Start with the data- attributes, omitting the module name and the defaults setting
                                _.omit($(el).data(), ['module', 'defaults']),
                                // Add in some default options
                                {
                                    el: el,
                                    baseTemplateUrl: module.config()['baseTemplateUrl'],
                                    baseTemplateUrlInternal: module.config()['baseTemplateUrlInternal'],
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
                        )
                    );
                }
            );
        });
    };

    var assertDefined = function (val, key) {
        if (_.isUndefined(val)) {
            throw new Error("arguments[" + key + "] is undefined");
        }
    };

    // Extend the _ object for easier argument management
    // We only need to do this job once ever
    var initUnderscore = _.once(function () {
        _.mixin({
            checkArgMandatory: function (options, argMandatory) {
                _.map(arguments, assertDefined);

                var argMissing =  _.difference(argMandatory, _.keys(options));

                if (!(_.isEmpty(argMissing))) {
                    throw new Error('Arguments missing: ' + argMissing.toString());
                }

                return options;
            },

            filterArg: function (options, argAllowed, fnAlert) {
                _.map(Array.prototype.slice.call(arguments, 0, 2), assertDefined);

                if (fnAlert === true) {
                    fnAlert = _.bind(console.log, console);
                } else if (!(_.isFunction(fnAlert))) {
                     fnAlert = _.noop;
                }

                fnAlert('Extra arguments: ' +
                    _.difference(_.keys(options), argAllowed).toString()
                );

                return _.pick(
                    options,
                    argAllowed
                );
            },

            swapKeys: function (options, objKeyMap) {
                _.map(arguments, assertDefined);

                _.map(objKeyMap, function (val, key) {
                    options[val] = options[key];
                    delete options[key];
                });

                return options;
            }
        });
    });

    var initTransitionalModules = function (options) {
        TransitionalForms.initialize();
        TransitionalTabs.initialize();
        TransitionalModals.initialize();
    };

    var main = {
        initialize: function (options) {
            HandlebarsFormHelpers.register(Handlebars);
            initUnderscore();
            initModules(options);
            initTransitionalModules(options);
        }
    };

    return main;
});
