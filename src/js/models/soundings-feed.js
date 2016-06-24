/**
* @Author: Colin Osterhout <ctosterhout>
* @Date:   2016-06-23T13:54:17-08:00
* @Email:  ctosterhout@alaska.edu
* @Project: BERT
* @Last modified by:   ctosterhout
* @Last modified time: 2016-06-23T14:03:55-08:00
* @License: Released under MIT License. Copyright 2016 University of Alaska Southeast.  For more details, see https://opensource.org/licenses/MIT
*/

define([
    'models/base',
], function (BaseModel) {
    'use strict';

    // Create the model factory. At this time we're not adding anything to the BaseModel class
    var SoundingsFeedModel = BaseModel.extend({});

    // Return the model to the controller
    return SoundingsFeedModel;
});
