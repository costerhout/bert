/**
* @Author: Colin Osterhout <ctosterhout>
* @Date:   2016-05-20T08:17:09-08:00
* @Email:  ctosterhout@alaska.edu
* @Project: BERT
* @Last modified by:   ctosterhout
* @Last modified time: 2016-06-01T23:05:39-08:00
* @License: Released under MIT License. Copyright 2016 University of Alaska Southeast.  For more details, see https://opensource.org/licenses/MIT
*/


define(
    ['jquery'], function ($) {
    'use strict';

    var moveModals = function () {
        /* Only run if the DOM has finished loading */
        $(function () {
            /* Find all modal windows that are more than one level below <body> */
            var $modals = $(".modal:not(body > .modal)").appendTo('body');
        });
    };


    // Instead of a constructor function we are returning a singleton module
    var module = {
        initialize: function () {
            // Move the modals around to the end of the body
            moveModals();

            // Future expandability idea: hook onto events object to move around modals whenever an event is triggered
        }
    };

    return module;
});
