/**
* @Author: Colin Osterhout <ctosterhout>
* @Date:   2016-05-17T13:26:54-08:00
* @Email:  ctosterhout@alaska.edu
* @Project: BERT
* @Last modified by:   ctosterhout
* @Last modified time: 2016-06-23T18:41:44-08:00
* @License: Released under MIT License. Copyright 2016 University of Alaska Southeast.  For more details, see https://opensource.org/licenses/MIT
*/

require([
    // Standard items that export a variable
    'jquery',
    'main',
    'templates/bs3',
    'bootstrap3'
], function ($, main, HandlebarsBootstrap) {
    'use strict';

    HandlebarsBootstrap.register();

    // Wait for the DOM to load
    $(function () {
        main.initialize(
            {
                templateScheme: 'bs3'
            }
        );
    });
});
