/**
* @Author: Colin Osterhout <ctosterhout>
* @Date:   2016-03-30T15:56:16-08:00
* @Email:  ctosterhout@alaska.edu
* @Project: BERT
* @Last modified by:   ctosterhout
* @Last modified time: 2016-06-01T22:49:06-08:00
* @License: Released under MIT License. Copyright 2016 University of Alaska Southeast.  For more details, see https://opensource.org/licenses/MIT
*/



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
