/**
* @Author: Colin Osterhout <ctosterhout>
* @Date:   2016-05-20T08:17:09-08:00
* @Email:  ctosterhout@alaska.edu
* @Project: BERT
* @Last modified by:   ctosterhout
* @Last modified time: 2017-05-09T11:25:20-08:00
* @License: Released under MIT License. Copyright 2016 University of Alaska Southeast.  For more details, see https://opensource.org/licenses/MIT
*/


define([
    'module',
    'jquery',
    'underscore',
    'datatables'
], function (module, $, _) {
    'use strict';

    // Instead of a constructor function we are returning a singleton module
    return {
        initialize: function (options) {
            var initFilterTables = function () {
                    // 'table-filtered' is the preferred class for tables which should be filtered
                    $('.table-filtered')
                    // There are some tables out there with this class as well
                        .add('.data-table')
                        .DataTable({
                            searching: true
                        });
                },
                initSortTables = function () {
                    $("table[class*='table-autosort']").DataTable({
                        ordering: true,
                        searching: true
                    });
                };

            // Move the modals around to the end of the body
            try {
                /* Only run if the DOM has finished loading */
                $(function () {
                    // Initialize the DataTable function within jQuery
                    $.extend(true, $.fn.dataTable.defaults, module.config());

                    // Find and initialize tables on the page
                    initFilterTables();
                    initSortTables();

                    if (_.isFunction(options.success)) {
                        options.success();
                    }
                });
            } catch (e) {
                if (_.isFunction(options.fail)) {
                    options.fail(e.message);
                }
            }
        }
    };
});
