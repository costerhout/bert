/**
* @Author: Colin Osterhout <ctosterhout>
* @Date:   2016-06-14T20:58:34-08:00
* @Email:  ctosterhout@alaska.edu
* @Project: BERT
* @Last modified by:   ctosterhout
* @Last modified time: 2016-06-23T18:57:02-08:00
* @License: Released under MIT License. Copyright 2016 University of Alaska Southeast.  For more details, see https://opensource.org/licenses/MIT
*/

define(['underscore', 'hbs/handlebars'], function (_, Handlebars) {
    'use strict';

    //  {{#modal id title}}Content goes here{{/modal}}
    var helperModal = function (id, title, options) {
            var idLabel = id + '_label',
                htmlBody = _.createElement(options.fn(this), 'div', false,
                    {
                        class: 'modal-body'
                    }),
                htmlButtonCloseX = _.createElement('x', 'button', false,
                    {
                        class: 'close',
                        'data-dismiss': 'modal',
                        'aria-hidden': 'true'
                    }),
                htmlTitle = _.createElement(title, 'h3', false,
                    {
                        id: idLabel
                    }),
                htmlButtonClose = _.createElement('Close', 'button', false,
                    {
                        'data-dismiss': 'modal',
                        'aria-hidden': 'true'
                    }),
                htmlHeader = _.createElement(htmlButtonCloseX + htmlTitle, 'div', false,
                    {
                        class: 'modal-header'
                    }),
                htmlFooter = _.createElement(htmlButtonClose, 'div', false,
                    {
                        class: 'modal-footer'
                    }),
                htmlModal = _.createElement(htmlHeader + htmlBody + htmlFooter, 'div', false,
                    {
                        id: id,
                        class: 'modal hide fade',
                        tabindex: '-1',
                        role: 'dialog',
                        'aria-labelledby': idLabel,
                        'aria-hidden': true
                    });

            return new Handlebars.SafeString(htmlModal);
        },
        // {{#thumbnail img_src}}Caption content goes here{{/thumbnail}}
        helperThumbnail = function (urlImage, options) {
            // Options supported:
            //     alt_img
            //     link_img

            // Process the caption contents
            var htmlCaption = _.createElement(options.fn(this), 'div', false,
                {
                    class: 'caption'
                }),
                // Process the image + its attributes
                htmlImage = _.createElement('', 'img', true,
                    _.extend(
                        _.has(options.hash, 'alt_img') ? { alt: options.hash.alt_img } : {},
                        {
                            src: urlImage
                        }
                    )),
                // If there's a link specified than wrap the image in the link
                htmlImageWrap = _.has(options.hash, 'link_img')
                ? _.createElement(htmlImage, 'a', false,
                    {
                        href: options.hash.link_img
                    }
                    )
                : htmlImage;

            return new Handlebars.SafeString(_.createElement(htmlImageWrap + htmlCaption, 'div', false,
                {
                    class: 'thumbnail'
                }));
        },

        // Define the relationship between helper names and their functions
        helpers = {
            modal: helperModal,
            thumbnail: helperThumbnail
        },

        // Define function to register the helpers
        register = function () {
            _.each(helpers, function (fn, name) {
                Handlebars.registerHelper(name, fn);
            });
        };

    return {
        register: register
    };
});
