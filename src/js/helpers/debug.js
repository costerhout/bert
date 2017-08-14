/**
* @Author: Colin Osterhout <ctosterhout>
* @Date:   2016-05-27T14:15:29-08:00
* @Email:  ctosterhout@alaska.edu
* @Project: BERT
 * @Last modified by:   ctosterhout
 * @Last modified time: 2017-08-06T18:04:22-08:00
* @License: Released under MIT License. Copyright 2016 University of Alaska Southeast.  For more details, see https://opensource.org/licenses/MIT
*/

define(['underscore', 'hbs/handlebars'], function (_, Handlebars) {
    'use strict';

    // Guard against the case where hbs/json2 is stubbed out
    var stringify = _.isObject(JSON) && _.isFunction(JSON.stringify)
        ? JSON.stringify
        : function () {
            return '(Debug information optimized out)';
        },
        dumpObj = function () { // context and options are also available from Handlebars here
            return new Handlebars.SafeString(
                '<div class="debug">' + stringify(this, null, 4) + '</div>'
            );
        },
        register = function () {
            Handlebars.registerHelper('debug', dumpObj);
        };

    return {
        register: register
    };
});
