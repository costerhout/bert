/**
* @Author: Colin Osterhout <ctosterhout>
* @Date:   2016-05-19T18:23:04-08:00
* @Email:  ctosterhout@alaska.edu
* @Project: BERT
* @Last modified by:   ctosterhout
* @Last modified time: 2016-06-23T17:43:48-08:00
* @License: Released under MIT License. Copyright 2016 University of Alaska Southeast.  For more details, see https://opensource.org/licenses/MIT
*/



define([
    'module',
    'jquery',           // handy util
    'underscore',             // models / view framework
    'juicebox'
], function (module, $, _, Juicebox) {
    'use strict';

    // Valid data options:
    //     id: ID of the photo set
    //     type: Type of gallery.  Currently only 'flickr' is permitted
    function Gallery(options) {
        var jbOptions = _.chain(options)
            .checkArgMandatory(['type'])
            .filterArg([
                'flickrSetId',
                'sharelink',
                'enableLooping',
                'showAutoPlayStatus',
                'displayTime',
                'buttonBarPosition',
                'captionPosition',
                'backgroundColor',
                'autoPlayOnLoad',
                'showThumbsOnLoad'
            ])
            .swapKeys({
                sharelink: 'shareURL'
            })
            .extend({
                containerId: $(options.el).attr('id')
            })
            .defaults(module.config()[options.type])
            .value();

        // Return a brand new the juicebox component (which handles the view)
        return new Juicebox(jbOptions);
    }

    Gallery.prototype = {
        constructor: Gallery
    };

    // Return the initialization routine to the main controller
    return Gallery;
});
