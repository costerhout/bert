/**
* @Author: Colin Osterhout <ctosterhout>
* @Date:   2016-05-07T21:07:51-08:00
* @Email:  ctosterhout@alaska.edu
* @Project: BERT
* @Last modified by:   ctosterhout
* @Last modified time: 2016-07-06T13:05:12-08:00
* @License: Released under MIT License. Copyright 2016 University of Alaska Southeast.  For more details, see https://opensource.org/licenses/MIT
*/

define([
    'jquery',
    'underscore',
    'backbone',

    // Include the standard template for display
    'hbs!templates/soundings-feed'
], function ($, _, Backbone, template) {
    'use strict';

    var SoundingsFeedView = Backbone.View.extend({
        tagName: 'div',

        initialize: function (options) {
            var that = this;

            that.viewOptions = _.chain(options)
                // Filter out non-view arguments
                .filterArg(['count', 'departments'])
                // Apply sensible view defaults
                .defaults({
                    count: '0'
                })
                // Split up departments into an array (if present)
                .splitArg('departments')
                // Convert selected keys to number values
                .toNumber(['count'])
                .value();

            // Set up view variables to connect us to the model and the DOM
            that.model = options.model;
            that.el = options.el;
        },

        render: function () {
            // Create a new location in an array and populate
            // based on the values in the XML response
            var that = this,
                // Get the array of stories from the model (got some plural confusion here) and then operate upon it
                stories = _.chain(that.model.attributes.story)
                    // If there's a list of departments, then filter based on that
                    .filter(_.has(that.viewOptions, 'departments')
                        // We have departments that we're filtering on - only bring forth the stories that contain those departments
                        ? function (story) {
                            // Cast the story.department into an array (the _.flatten call takes care of the case where story.department is already an array)
                            return (_.intersection(that.viewOptions.departments, _.flatten([ story.department ])).length > 0);
                        }
                        // Or else return every story (this function always satisfies the filter)
                        : _.constant(true))
                    .value(),
                // Clear out the contents of the DIV and then stick in the output of the template
                renderTemplate = function (template, stories) {
                    $(that.el).empty();
                    $(that.el).append(template(stories));

                    return that;
                };

            // Render the template with the filtered set of stories
            renderTemplate(template, { story: stories });
            that.trigger('render');
        }
    });

    return SoundingsFeedView;
});
