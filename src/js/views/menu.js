/**
* @Author: Colin Osterhout <ctosterhout>
* @Date:   2016-05-07T21:07:51-08:00
* @Email:  ctosterhout@alaska.edu
* @Project: BERT
* @Last modified by:   ctosterhout
* @Last modified time: 2017-04-18T13:40:53-08:00
* @License: Released under MIT License. Copyright 2016 University of Alaska Southeast.  For more details, see https://opensource.org/licenses/MIT
*/

define([
    'jquery',
    'underscore',
    'backbone',

    // Include story template for display
    'hbs!templates/menu'
], function ($, _, Backbone, templateMenu) {
    'use strict';

    var MenuView = Backbone.View.extend({
        tagName: 'div',

        initialize: function (options) {
            var that = this;

            that.viewOptions = _.chain(options)
                // Filter out non-view arguments
                .filterArg(['type', 'brandLogo', 'brandLink', 'brandLabel', 'id'])
                // Apply sensible view defaults
                .defaults({
                    type: 'simple'
                })
                .value();

            // Set up view variables to connect us to the model and the DOM
            that.model = options.model;
            that.el = options.el;
        },

        render: function () {
            // Create a new location in an array and populate
            // based on the values in the XML response
            var that = this,
                objectMenu = {
                    id: that.viewOptions.id,
                    brandLogo: that.viewOptions.brandLogo,
                    brandLabel: that.viewOptions.brandLabel,
                    brandLink: that.viewOptions.brandLink,
                    menuitem: _.flatten([ that.model.attributes.menuitem ]) // Make sure that menuitem is an array and not simply an object
                };

            $(that.el).append(templateMenu(objectMenu));

            // Allow for nested dropdown menus
            // Derived from: http://bootsnipp.com/snippets/featured/multi-level-navbar-menu
            $('.navbar a.dropdown-toggle', that.el).on('click', function(e) {
                var $el = $(this),
                    $parent = $(this).offsetParent(".dropdown-menu");

                $el.parent("li").toggleClass('open');

                if (!$parent.parent().hasClass('nav')) {
                    $el.next().css({
                        "top": $el.offsetTop,
                        "left": $parent.outerWidth() - 4
                    });
                }

                $('.nav li.open').not($el.parents("li")).removeClass("open");

                return false;
            });

            // Render the template with the filtered set of stories
            that.trigger('render');
        }
    });

    return MenuView;
});
