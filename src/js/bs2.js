/**
* @Author: Colin Osterhout <ctosterhout>
* @Date:   2016-05-17T09:56:04-08:00
* @Email:  ctosterhout@alaska.edu
* @Project: BERT
* @Last modified by:   ctosterhout
* @Last modified time: 2016-06-01T23:05:55-08:00
* @License: Released under MIT License. Copyright 2016 University of Alaska Southeast.  For more details, see https://opensource.org/licenses/MIT
*/

require([
    // Standard items that export a variable
    'jquery',
    'main',
    'bootstrap2'
], function($, main) {
    'use strict';

    var modules = [];

    // Wait for the DOM to load
    $(function () {
        modules = main.initialize(
            {
                templateScheme: 'bs2',
            }
        );
    });
});
