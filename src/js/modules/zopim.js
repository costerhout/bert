/**
* @Author: Colin Osterhout <ctosterhout>
* @Date:   2016-05-19T18:23:04-08:00
* @Email:  ctosterhout@alaska.edu
* @Project: BERT
* @Last modified by:   ctosterhout
* @Last modified time: 2016-08-01T16:01:24-08:00
* @License: Released under MIT License. Copyright 2016 University of Alaska Southeast.  For more details, see https://opensource.org/licenses/MIT
*/



define([
    'module',
    'jquery',
    'underscore'
], function (module, $, _) {
    'use strict';

    // Valid data options:
    //     id: ID of the photo set
    //     type: Type of gallery.  Currently only 'flickr' is permitted
    function Zopim(options) {
        var moduleOptions = _.chain(_.clone(options))
            .checkArgMandatory(['key'])
            .filterArg(['key', 'departments', 'defaultDepartment', 'timeoutPopup', 'position'])
            .swapValues('position', {
                'Bottom right': 'br',
                'Bottom left': 'bl',
                'Top right': 'tr',
                'Top left': 'tl'
            })
            .toNumber('timeoutPopup')
            .splitArg('departments')
            .defaults(module.config())
            .value(),
            // Take a subset of those options for the ones we're to send Zopim directly
            zopimOptionsInit = { language: 'en' },

            setDepartments = function ($zopim) {
                var departments = _.chain($zopim.livechat.departments.getAllDepartments())
                    .where({ status: 'online' })
                    .pluck('name')
                    .intersection(moduleOptions.departments)
                    .value(),
                    // The department to show will be the default one (if online), or the first online one
                    // If there are none online, this value will be undefined
                    departmentToShow = _.indexOf(departments, moduleOptions.defaultDepartment) > -1
                    ? moduleOptions.defaultDepartment
                    : departments[0];

                // If we have a department online, filter the Zopim display and let the caller know we've been successful
                if (_.isString(departmentToShow)) {
                    // Set the department list
                    $zopim.livechat.departments.filter.apply($zopim, departments);
                    $zopim.livechat.departments.setVisitorDepartment(departmentToShow);
                    return true;
                }

                return false;
            },

            setDisplay = function ($zopim) {
                // Set window and button position
                $zopim.livechat.button.setPosition(moduleOptions.position);
                $zopim.livechat.window.setPosition(moduleOptions.position);

                // Display the button on the screen
                $zopim.livechat.button.show();

                // Set the window to popup, if set in parameters
                if (moduleOptions.timeoutPopup > 0) {
                    setTimeout($zopim.livechat.window.show, moduleOptions.timeoutPopup);
                }
            },

            // Set up a deferred to kick off init of the Zopim module
            initialize = function ($zopim) {
                // If we have a department online, go through the department setup of the widget
                //  and then set the display if the requested department is online.
                // or else just display the widget.
                if (_.has(moduleOptions, 'departments')) {
                    if (setDepartments($zopim)) {
                        setDisplay($zopim);
                    }
                } else {
                    setDisplay($zopim);
                }

                // Set up the callback notification when $zopim has finished connecting to server
                if (_.isFunction(options.success)) {
                    options.success();
                }
            },
            deferred = $.Deferred(),
            // Modified from snippet provided by Zopim to allow for configuration of the src parameter
            // The zopimFactory creates the global $zopim variable, creates a script tag,
            //  attaches a work queue to it and is in itself a function to push functions on to the queue
            //  to be executed after the zopim component has downloaded
            $zopim = _.isUndefined(window.$zopim)
            ? (function (d, s) {
                var z = window.$zopim = function (c) {
                        z._.push(c);
                    },
                    $ = z.s = d.createElement(s),
                    e = d.getElementsByTagName(s)[0];

                z.set = function (o) {
                    z.set._.push(o);
                };
                z._ = [];
                z.set._ = [];
                $.async = true;
                $.setAttribute("charset", "utf-8");
                $.src = "//v2.zopim.com/?" + moduleOptions.key;
                z.t = +new Date();
                $.type = "text/javascript";
                e.parentNode.insertBefore($, e);

                // Return the global Zopim function to the module
                return z;
            }(document, "script"))
            : window.$zopim;

        // When the zopim shim has finished loading run the queued function
        $zopim(function () {
            var z = window.$zopim;

            // Queue up the initialization function, the failure pathway, and then
            // set the timeout function
            deferred.then(_.partial(initialize, z));
            deferred.fail(_.isFunction(options.fail) ? options.fail : _.noop);
            setTimeout(deferred.reject, moduleOptions.timeoutLoad);

            // Set our livechat options and hide the window
            z.livechat.set(zopimOptionsInit);
            z.livechat.hideAll();

            // Tell Zopim to kick off the init routines after connection
            z.livechat.setOnConnected(deferred.resolve);
        });
    }

    Zopim.prototype = {
        constructor: Zopim
    };

    // Return the initialization routine to the main controller
    return Zopim;
});
