/**
* @Author: Colin Osterhout <ctosterhout>
* @Date:   2016-05-17T09:56:04-08:00
* @Email:  ctosterhout@alaska.edu
* @Project: BERT
* @Last modified by:   ctosterhout
* @Last modified time: 2016-06-23T18:17:56-08:00
* @License: Released under MIT License. Copyright 2016 University of Alaska Southeast.  For more details, see https://opensource.org/licenses/MIT
*/

require([
    // Standard items that export a variable
    'jquery',
    'main',
    'templates/bs2',
    'bootstrap2',
], function ($, main, HandlebarsBootstrap) {
    'use strict';

    HandlebarsBootstrap.register();

    // Wait for the DOM to load
    $(function () {
        main.initialize(
            {
                templateScheme: 'bs2',
            }
        );
    });
});
