/**
* @Author: Colin Osterhout <ctosterhout>
* @Date:   2016-10-21T13:53:20-08:00
* @Email:  ctosterhout@alaska.edu
* @Project: BERT
* @Last modified by:   ctosterhout
* @Last modified time: 2016-10-21T15:09:29-08:00
* @License: Released under MIT License. Copyright 2016 University of Alaska Southeast.  For more details, see https://opensource.org/licenses/MIT
*/

define([
    'models/base'
], function (BaseModel) {
    'use strict';

    // Create the model factory. At this time we're not adding anything to the BaseModel class
    var DecisionTreeModel = BaseModel.extend({});

    // Return the model to the controller
    return DecisionTreeModel;
});
