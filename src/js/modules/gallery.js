define([
    'module',
    'jquery',           // handy util
    'underscore',             // models / view framework
    'juicebox'
], function(module, $, _, Juicebox) {
    'use strict';

    // Valid data options:
    //     id: ID of the photo set
    //     type: Type of gallery.  Currently only 'flickr' is permitted
    function Gallery (options) {
        var argMandatory = ['type'],
            argAllowed = [
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
            ],
            argSpecial = [ 'sharelink' ],
            argMissing = _.difference(argMandatory, _.keys(options)),
            jbOptions = _.defaults(
                // Deal with the special options first
                {
                    shareURL: _.isUndefined(options.sharelink) ? '' : options.sharelink,
                    containerId: $(options.el).attr('id')
                },
                // Then all the other options as specified by user (minus the special arguments)
                _.omit(
                    _.pick(
                        options,
                        argAllowed
                    ),
                    argSpecial
                ),
                // Fill in the gaps with the module config
                module.config()[options.type]
            );

        // Check for any missing mandatory options
        if (!_.isEmpty(argMissing)) {
            throw new Error('Arguments missing: ' + argMissing.toString());
        }

        // Return a brand new the juicebox component (which handles the view)
        return new Juicebox(jbOptions);
    }

    Gallery.prototype = {
        constructor: Gallery
    };

    // Return the initialization routine to the main controller
    return Gallery;
});
