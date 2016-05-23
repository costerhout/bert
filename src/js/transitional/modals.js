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
