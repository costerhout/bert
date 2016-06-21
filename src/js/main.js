/**
* @Author: Colin Osterhout <ctosterhout>
* @Date:   2016-05-17T09:09:22-08:00
* @Email:  ctosterhout@alaska.edu
* @Project: BERT
* @Last modified by:   ctosterhout
* @Last modified time: 2016-06-01T23:06:25-08:00
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

    // Add-ons to the above
    'jquery.xml2json'
], function(
    // Standard stuff
    module, require, $, _,

    // Stuff to handle transitional things - e.g. may very well change as browsers get updated and the XSLT generation tools change
    TransitionalForms, TransitionalTabs, TransitionalModals, TransitionalPlaceholder,

    // Load up the Handlebars stuff
    Handlebars, HandlebarsFormHelpers) {
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
    });

    var initTransitionalModules = function (options) {
        TransitionalForms.initialize();
        TransitionalTabs.initialize();
        TransitionalModals.initialize();
        TransitionalPlaceholder.initialize();
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
