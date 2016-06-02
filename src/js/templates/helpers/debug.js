/**
* @Author: Colin Osterhout <ctosterhout>
* @Date:   2016-05-27T14:15:29-08:00
* @Email:  ctosterhout@alaska.edu
* @Project: BERT
* @Last modified by:   ctosterhout
* @Last modified time: 2016-06-01T22:59:39-08:00
* @License: Released under MIT License. Copyright 2016 University of Alaska Southeast.  For more details, see https://opensource.org/licenses/MIT
*/



define(['underscore', 'hbs/handlebars', 'hbs/json2'], function (_, Handlebars, JSON) {
    // Guard against the case where hbs/json2 is stubbed out
    var stringify = _.isObject(JSON) && _.isFunction(JSON.stringify) ?
        JSON.stringify :
        function () {
            return '(Debug information optimized out)';
        },
        dumpObj = function (context, options) {
        return new Handlebars.SafeString(
            '<div class="debug">' + stringify(this) + '</div>'
        );
    };

    Handlebars.registerHelper('debug', dumpObj);

    return dumpObj;
});
