define([
    'jquery',
    'underscore',
    'models/base',
    'jquery.xml2json'
], function ($, _, Base) {
    'use strict';

    // Create the model factory
    var MapDisplay = Base.extend({
        // Set sane defaults
        defaults: {
            type: 'roadmap',
            zoom: 4,
            dataType: 'xml'
        }
    });

    // Return the model to the controller
    return MapDisplay;
});
