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
