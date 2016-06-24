/**
* @Author: Colin Osterhout <ctosterhout>
* @Date:   2016-05-17T09:09:22-08:00
* @Email:  ctosterhout@alaska.edu
* @Project: BERT
* @Last modified by:   ctosterhout
* @Last modified time: 2016-06-24T08:04:52-08:00
* @License: Released under MIT License. Copyright 2016 University of Alaska Southeast.  For more details, see https://opensource.org/licenses/MIT
*/


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
    'transitional/placeholder',

    // Handlebars helpers to be explicitly added
    'hbs/handlebars',
    'vendor/handlebars.form-helpers',
    'templates/debug',

    // Add polyfill items
    'lib/polyfill',

    // Add-ons to any of the above
    'jquery.xml2json'
], function (
    // Standard stuff
    module,
    require,
    $,
    _,

    // Stuff to handle transitional things - e.g. may very well change as browsers get updated and the XSLT generation tools change
    // Make sure to add these to the list of modulesTransitional.
    TransitionalForms,
    TransitionalTabs,
    TransitionalModals,
    TransitionalPlaceholder,

    // Load up the Handlebars object
    Handlebars,

    // Make sure to add these to the list of modulesHandlebars.
    HandlebarsFormHelpers,
    HandlebarsDebug
) {
    'use strict';

    var modules = [],
        modulesTransitional = [
            TransitionalForms,
            TransitionalTabs,
            TransitionalModals,
            TransitionalPlaceholder
        ],
        modulesHandlebars = [
            HandlebarsFormHelpers,
            HandlebarsDebug
        ],

        initModules = function (options) {
            // Reset the list of modules
            modules.length = 0;

            $('div[data-module]').each(function () {
                // Save away the jQuery version of this element
                var el = this,
                    $defaults = $($(el).data('defaults')).first(),
                    type = _.last(/^(?:text|application)\/(json|xml)$/.exec($defaults.attr('type'))) || 'noop';

                require(
                    ['modules/' + $(el).data('module')],
                    function (Mod) {
                        // Push the newly created module on the stack
                        // We could do some sort of event here to alert subscribers in the future
                        modules.push(
                            new Mod(
                                // Build the options object by combining data- attributes,
                                // module config options, and defaults specified in the DOM (if available)
                                _.defaults(
                                    // Start with the data- attributes, omitting the module name and the defaults setting
                                    _.omit($(el).data(), ['module', 'defaults']),
                                    // Add in some default options
                                    {
                                        el: el,
                                        baseTemplateUrl: module.config().baseTemplateUrl,
                                        baseTemplateUrlInternal: module.config().baseTemplateUrlInternal,
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
        },

        // Extend the _ object for easier argument management
        // We only need to do this job once ever
        initUnderscore = _.once(function () {
            var assertDefined = function (val, key) {
                if (_.isUndefined(val)) {
                    throw new Error("arguments[" + key + "] is undefined");
                }
            };

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

                splitArg: function (options, key, separator) {
                    // Only split if there's really an option there by this key
                    if (_.has(options, key)) {
                        options[key] = _.isString(options[key])
                            ? options[key].split(_.isUndefined(separator) ? ',' : separator)
                            : options[key];
                    }

                    return options;
                },

                swapKeys: function (options, objKeyMap) {
                    _.map(arguments, assertDefined);

                    _.map(objKeyMap, function (val, key) {
                        options[val] = options[key];
                        delete options[key];
                    });

                    return options;
                },

                toNumber: function (options, a_key) {
                    return _.mapObject(options, function (val, key) {
                        return _.contains(a_key, key) ? Number(val) : val;
                    });
                },

                toString: function (options, a_key) {
                    return _.mapObject(options, function (val, key) {
                        return _.contains(a_key, key) ? String(val) : val;
                    });
                },

                /* Markup helpers - modified from handlebars.form-helpers.js
                * https://github.com/badsyntax/handlebars-form-helpers
                * Copyright (c) 2013 Richard Willis; Licensed MIT
                *****************************************/
                // type: type of tag
                // closing: tag requires self closing, e.g. '<br/>'
                // attr: A falsy value is used to remove the attribute.
                //  EG: attr[false] to remove, attr['false'] to add

                openTag: function (name, selfClose, attributes) {
                    var aAttr = _.map(attributes, function (value, key) {
                        if (value) {
                            return key + '=' + "'" + value + "'";
                        }
                    });

                    return '<' + name + ' ' + aAttr.join(' ') + (selfClose ? ' /' : '') + '>';
                },

                closeTag: function (name) {
                    return '</' + name + '>';
                },

                createElement: function (content, name, selfClose, attributes) {
                    return _.openTag(name, selfClose, attributes) + (selfClose ? '' : (content || '') + _.closeTag(name));
                },

                appendElement: function (content, name, selfClose, attributes) {
                    return content + _.createElement(content, name, selfClose, attributes);
                },

                wrapElement: function (content, name, attributes) {
                    return _.openTag(name, false, attributes) + (content || '') + _.closeTag(name);
                },

                prependString: function (content, string) {
                    return string + content;
                },

                appendString: function (content, string) {
                    return content + string;
                }
            });
        }),

        main = {
            initialize: function (options) {
                // Build up some helper functions within Underscore
                initUnderscore();

                // Set up the Handlebars helpers
                _.each(modulesHandlebars, function (module) {
                    module.register(Handlebars);
                });

                // Initialize our mainline modules
                initModules(options);

                // Perform various transitional tasks, which may operate on the output of our mainline modules
                _.each(modulesTransitional, function (module) {
                    module.initialize();
                });
            }
        };

    return main;
});
