/**
* @Author: Colin Osterhout <ctosterhout>
* @Date:   2016-05-17T09:56:04-08:00
* @Email:  ctosterhout@alaska.edu
* @Project: BERT
* @Last modified by:   ctosterhout
* @Last modified time: 2017-03-29T10:31:39-08:00
* @License: Released under MIT License. Copyright 2016 University of Alaska Southeast.  For more details, see https://opensource.org/licenses/MIT
*/

require([
    // Standard items that export a variable
    'jquery',
    'underscore',
    'main',
    'helpers/bs2',
    'bootstrap2'
], function ($, _, main, HandlebarsBootstrap) {
    'use strict';

    HandlebarsBootstrap.register();

    // Wait for the DOM to load
    $(function () {
        main.initialize(
            {
                templateScheme: 'bs2',
            }
        );

        // Manually start carousel components (not necessary in BS3)
        // Pass in the data associated with this element to initialize the carousel,
        // omitting the carousel and ride variables.
        $("[data-ride='carousel']").each(function () {
            $(this).carousel(_.omit($(this).data(), ['carousel', 'ride']));
        });
    });
});
