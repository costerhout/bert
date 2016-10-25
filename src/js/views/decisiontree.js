/**
* @Author: Colin Osterhout <ctosterhout>
* @Date:   2016-10-21T13:54:07-08:00
* @Email:  ctosterhout@alaska.edu
* @Project: BERT
* @Last modified by:   ctosterhout
* @Last modified time: 2016-10-25T11:20:00-08:00
* @License: Released under MIT License. Copyright 2016 University of Alaska Southeast.  For more details, see https://opensource.org/licenses/MIT
*/

define([
    'jquery',
    'underscore',
    'backbone',
    'lib/debug',

    // Include template for display of decision tree step
    'hbs!templates/decisiontree'
], function ($, _, Backbone, debug, template) {
    'use strict';

    // Define the DecisionTree class
    var DecisionTree = function (data) {
        var that = this,
            getInitial = function () {
                return that.initial;
            },
            getChoice = function (id) {
                return that.choices[id];
            },
            getChildrenId = function (idParent) {
                return _.filter(_.flatten([getChoice(idParent).child]), _.identity);
            },
            getParentId = function (idChild) {
                var choice = getChoice(idChild);

                return _.isUndefined(choice) ? undefined : choice.parent;
            },
            initialize = function () {
                _.extend(that, {
                    initial: data.initial,
                    choices: _.object(_.pluck(data.choice, 'id'), data.choice)
                });

                // Walk through all choices' children and assign their parent
                _.each(_.keys(that.choices), function (idParent) {
                    _.each(getChildrenId(idParent), function (idChild) {
                        var choice = getChoice(idChild);

                        if (_.isUndefined(choice)) {
                            debug.error('DecisionTree: choice is undefined: ' + idChild);
                        } else if (!(_.isUndefined(choice.parent))) {
                            debug.warn('DecisionTree: choice already has parent assigned: ' + idChild);
                        } else {
                            choice.parent = idParent;
                        }
                    });
                });

                debug.log('DecisionTree: initial: ' + that.initial + ', choices: ' + _.keys(that.choices).join(','));
            };

        initialize();

        return {
            getInitial: getInitial,
            getChoice: getChoice,
            getChildrenId: getChildrenId,
            getParentId: getParentId
        };
    }, DecisionTreeView = Backbone.View.extend({
        tagName: 'div',

        initialize: function (options) {
            var that = this;

            that.viewOptions = _.chain(options)
                // Filter out non-view arguments
                .filterArg(['animationDuration'])
                .value();

            // Set up view variables to connect us to the model and the DOM
            that.model = options.model;
            that.el = options.el;
        },

        // The background model doesn't change in the decision tree
        // Normal usage is for the calling module to call render whenever the tree data has loaded
        // Actual decision tree data structure is kept as local variable to this function
        render: function () {
            // Create a new location in an array and populate
            // based on the values in the XML response
            var that = this,
                tree = new DecisionTree(that.model.attributes),
                // Clear out the contents of the DIV and associated modals and then stick in the output of the template
                renderChoice = function (idChoice, skipAnimation) {
                        // Initialize choice object and parent ID
                    var choice = tree.getChoice(idChoice),
                        idParent = tree.getParentId(idChoice),
                        // Populate context with:
                        //     title: string
                        //     description: string
                        //     id_parent: string
                        //     children: [] (to be filled out later)
                        //
                        // Hook up the reset button
                        context = {
                            title: choice.title,
                            description: choice.description || '',
                            children: [],
                            id_parent: idParent
                        },
                        skipAnimation = skipAnimation || that.viewOptions.animationDuration === 0 ? true : false;

                    // Populate children item in the context to be used for linkage
                    //      {
                    //          id: string
                    //          title: string
                    //      }
                    _.each(tree.getChildrenId(idChoice), function (idChild) {
                        var child = tree.getChoice(idChild);
                        context.children.push({
                            id: idChild,
                            title: child.title,
                            help: child.help
                        });
                    });
                    // Fade out,
                    // Apply handlebars template and assign the result to the result element,
                    // Fade in
                    if (!skipAnimation) {
                        $(that.el).animate({'opacity': 0}, that.viewOptions.animationDuration, function () {
                            $(that.el).html(template(context));
                        }).animate({'opacity': 1}, that.viewOptions.animationDuration);
                    } else {
                        $(that.el).html(template(context));
                    }
                },
                initialize = function () {
                    renderChoice(tree.getInitial(), true);
                };

            // Hook up the next-choice link events
            $(that.el).on('click', 'ul.decisiontree-nav a[data-choice]', function (ev) {
                renderChoice($(this).data('choice'));
                ev.preventDefault();
            });

            // Hook up the reset button event
            $(that.el).on('click', 'a.decisiontree-reset', function (ev) {
                initialize();
                ev.preventDefault();
            });

            // Initialize the data tree
            initialize();

            // Tell the world that we're done with setting this up
            that.trigger('render');
        }
    });

    // Assign constructor to the DecisionTree prototype
    DecisionTree.prototype = {
        constructor: DecisionTree
    };

    return DecisionTreeView;
});
