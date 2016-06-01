define([
    'jquery',
    'underscore',
    'models/base',
    'jquery.xml2json'
], function ($, _, BaseModel) {
    'use strict';

    // Create the model factory
    var MapDisplayModel = BaseModel.extend({
        // Set sane defaults
        mapOptions: {
            type: 'roadmap',
            zoom: 4,
            dataType: 'xml'
        }
    });

    // Return the model to the controller
    return MapDisplayModel;
});
