/**
* @Author: Colin Osterhout <ctosterhout>
* @Date:   2016-05-18T09:42:01-08:00
* @Email:  ctosterhout@alaska.edu
* @Project: BERT
* @Last modified by:   ctosterhout
* @Last modified time: 2016-06-01T23:05:35-08:00
* @License: Released under MIT License. Copyright 2016 University of Alaska Southeast.  For more details, see https://opensource.org/licenses/MIT
*
* Uses work obtained from http://www.hagenburger.net/BLOG/HTML5-Input-Placeholder-Fix-With-jQuery.html
* Nico Hagenburger (https://twitter.com/hagenburger) with contributions from Robin Mehner (https://twitter.com/rmehner)
*/

define(
    ['jquery', 'underscore', 'modernizr'],
    function ($, _, Modernizr) {
        'use strict';

        var initialize = function () {
            $('[placeholder]').focus(function () {
                var input = $(this);
                if (input.val() === input.attr('placeholder')) {
                    input.val('');
                    input.removeClass('placeholder');
                }
            }).blur(function () {
                var input = $(this);
                if (input.val() === '' || input.val() === input.attr('placeholder')) {
                    input.addClass('placeholder');
                    input.val(input.attr('placeholder'));
                }
            }).blur();

            $('[placeholder]').parents('form').submit(function () {
                $(this).find('[placeholder]').each(function () {
                    var input = $(this);
                    if (input.val() === input.attr('placeholder')) {
                        input.val('');
                    }
                });
            });
        };

        // Instead of a constructor function we are returning a singleton module
        // Only pass in the real initialization function if we determine that we
        // really need it (i.e. IE < v10). Otherwise, provide a noop.
        return {
            initialize: Modernizr.input.placeholder ? _.noop : initialize
        };
    }
);
