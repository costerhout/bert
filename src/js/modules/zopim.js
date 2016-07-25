/**
* @Author: Colin Osterhout <ctosterhout>
* @Date:   2016-05-19T18:23:04-08:00
* @Email:  ctosterhout@alaska.edu
* @Project: BERT
* @Last modified by:   ctosterhout
* @Last modified time: 2016-07-25T15:07:13-08:00
* @License: Released under MIT License. Copyright 2016 University of Alaska Southeast.  For more details, see https://opensource.org/licenses/MIT
*/



define([
    'module',
    'jquery',           // handy util
    'underscore',             // models / view framework
    'zopim'
], function (module, $, _, zopimFactory) {
    'use strict';

    // Valid data options:
    //     id: ID of the photo set
    //     type: Type of gallery.  Currently only 'flickr' is permitted
    function Zopim(options) {
        var moduleOptions = _.chain(_.clone(options))
            .checkArgMandatory(['departments'])
            .filterArg(['departments', 'defaultDepartment', 'timeoutPopup', 'position'])
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

            // Set up a deferred to kick off init of the Zopim module
            initialize = function(z) {
                // Department list from Zopim will be an array of objects like:
                //  { id: 17649, name: "Admissions", status: "offline" }
                // Get list of all departments, filter for ones which are online
                // and then get the ones we care about
                var departments = _.chain(z.livechat.departments.getAllDepartments())
                    .where({ status: 'online' })
                    .pluck('name')
                    .intersection(moduleOptions.departments)
                    .value(),
                    // The department to show will be the default one (if online), or the first online one
                    // If there are none online, this value will be undefined
                    departmentToShow = _.indexOf(departments, moduleOptions.defaultDepartment) > -1
                    ? moduleOptions.defaultDepartment
                    : departments[0];

                // If we have a department online, go through the setup of the widget
                if (_.isString(departmentToShow)) {
                    // Set window and button position
                    z.livechat.button.setPosition(moduleOptions.position);
                    z.livechat.window.setPosition(moduleOptions.position);

                    // Set the department list
                    z.livechat.departments.filter.apply(z, departments);
                    z.livechat.departments.setVisitorDepartment(departmentToShow);

                    // Display the button on the screen
                    z.livechat.button.show();

                    // Set the window to popup, if set in parameters
                    if (moduleOptions.timeoutPopup > 0) {
                        setTimeout(z.livechat.window.show, moduleOptions.timeoutPopup);
                    }
                }

                // Set up the callback notification when $zopim has finished connecting to server
                if (_.isFunction(options.success)) {
                    options.success();
                }
            },
            deferred = $.Deferred();

        // When the zopim shim has finished loading run the queued function
        zopimFactory(function(){
            // By this point the $zopim global object has been set
            var z = window.$zopim;
            // Queue up the initialization function, the failure pathway, and then
            // set the timeout function
            deferred.then(_.partial(initialize, z));
            deferred.fail(_.isFunction(options.fail) ? options.fail : _.noop)
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
