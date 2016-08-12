/**
* @Author: Colin Osterhout <ctosterhout>
* @Date:   2016-07-26T08:56:02-08:00
* @Email:  ctosterhout@alaska.edu
* @Project: BERT
* @Last modified by:   ctosterhout
* @Last modified time: 2016-07-26T10:39:33-08:00
* @License: Released under MIT License. Copyright 2016 University of Alaska Southeast.  For more details, see https://opensource.org/licenses/MIT
*/

// Singleton object to handle logging and debug duties. Config received from Require.js informs
// this module whether or not to actually move things along to the user.
//
// Future enhancements could include logging things via Google Analytics.
define([
    'module',
    'underscore'
], function (module, _) {
    'use strict';

    // If debug is enabled in the build, then create a simple debug object that
    // exposes console logging services.
    var obj = module.config().enable
        ? {
            assert: _.bind(window.console.assert, window.console),
            log: _.bind(window.console.log, window.console),
            warn: _.bind(window.console.warn, window.console),
            error: _.wrap(_.bind(window.console.error, window.console), function (func, e) {
                var msg = _.isString(e) ? e : 'Unspecified error';
                func(msg);
                throw new Error(msg);
            }),
            trace: _.isFunction(window.console.trace)
                ? _.bind(window.console.trace, window.console)
                : _.partial(_.bind(window.console.warn, window.console), 'Trace function unsupported')
        }
        : {
            assert: _.noop,
            log: _.noop,
            warn: _.noop,
            error: _.noop,
            trace: _.noop
        };

    return obj;
});
