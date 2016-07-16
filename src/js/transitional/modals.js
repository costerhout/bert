/**
* @Author: Colin Osterhout <ctosterhout>
* @Date:   2016-05-20T08:17:09-08:00
* @Email:  ctosterhout@alaska.edu
* @Project: BERT
* @Last modified by:   ctosterhout
* @Last modified time: 2016-07-06T16:03:08-08:00
* @License: Released under MIT License. Copyright 2016 University of Alaska Southeast.  For more details, see https://opensource.org/licenses/MIT
*/


define(
    ['jquery', 'underscore'], function ($, _) {
    'use strict';

    // Instead of a constructor function we are returning a singleton module
    var module = {
        initialize: function (options) {
            var moveModals = function () {
                // Find all modal windows that are more than one level below <body>
                var $modals = $(".modal:not(body > .modal)").appendTo('body');

                // Make sure they're hidden
                $modals.hide();
            };

            // Move the modals around to the end of the body
            try {
                /* Only run if the DOM has finished loading */
                $(function () {
                    moveModals();
                    
                    if (_.isFunction(options.success)) {
                        options.success();
                    }
                });
            }
            catch (e) {
                if (_.isFunction(options.fail)) {
                    options.fail(e.message);
                }
            }
        }
    };

    return module;
});
