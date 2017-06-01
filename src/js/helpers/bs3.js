/**
* @Author: Colin Osterhout <ctosterhout>
* @Date:   2016-06-14T20:58:34-08:00
* @Email:  ctosterhout@alaska.edu
* @Project: BERT
* @Last modified by:   ctosterhout
* @Last modified time: 2017-04-17T18:51:38-08:00
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
                    });

            return new Handlebars.SafeString(_.chain(htmlHeader + htmlBody + htmlFooter)
                .wrapElement('div', { class: 'modal-content' })
                .wrapElement('div', { class: 'modal-dialog' })
                .wrapElement('div', {
                    id: id,
                    class: 'modal fade',
                    tabindex: '-1',
                    role: 'dialog',
                    'aria-labelledby': idLabel
                }).value());
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
        // {{menuitem menuitem}}
        // Each menuitem should contain:
        //      label
        //      url
        //   -- or, the nested variety: --
        //      label
        //      menuitem
        helperMenuitem = function () {
            var generateMenuItem = function (o) {
                // Create the basic anchor element
                var htmlA = _.createElement(
                    // If we are a submenu item then tack a caret onto the label
                    _.has(o, 'menuitem')
                        ? o.label + _.createElement(
                            '&#8203;',
                            'span',
                            false,
                            {
                                class: 'caret'
                            }
                        )
                        : o.label,
                    'a',
                    false,
                    // We have different attributes for submenu items then basic menu items
                    _.has(o, 'menuitem')
                        ? {
                            href: 'javascript:void(0);',
                            class: 'dropdown-toggle',
                            'data-toggle': 'dropdown',
                            role: 'button',
                            'aria-haspopup': 'true',
                            'aria-expanded': 'false'
                        }
                        : {
                            href: o.url
                        }
                ),
                    // Create the list item that encapsulates the anchor element via wrapElement
                    // Submenus will take the anchor element and append the submenu to it, recursively generated.
                    htmlListItem = _.has(o, 'menuitem')
                    ? _.chain(htmlA)
                        .appendElement(
                            _.isArray(o.menuitem)
                                ? _.map(o.menuitem, generateMenuItem).join('')
                                : generateMenuItem(o.menuitem),
                            'ul',
                            false,
                            { class: 'dropdown-menu' }
                        )
                        .wrapElement(
                            'li',
                            { class: 'dropdown' }
                        )
                        .value()
                    : _.chain(htmlA)
                        .wrapElement(
                            'li',
                            {}
                        )
                        .value();

                return htmlListItem;
            };

            // Begin building the menu item with the current context
            return new Handlebars.SafeString(generateMenuItem(this));
        },

        // Define the relationship between helper names and their functions
        helpers = {
            modal: helperModal,
            thumbnail: helperThumbnail,
            menuitem: helperMenuitem
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
