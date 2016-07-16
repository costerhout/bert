/**
* @Author: Colin Osterhout <ctosterhout>
* @Date:   2016-06-29T15:18:02-08:00
* @Email:  ctosterhout@alaska.edu
* @Project: BERT
* @Last modified by:   ctosterhout
* @Last modified time: 2016-07-15T23:45:37-08:00
* @License: Released under MIT License. Copyright 2016 University of Alaska Southeast.  For more details, see https://opensource.org/licenses/MIT
*/

define([
    'jquery',
    'underscore',
    '/tests/base.js',
    'mocha',
    'chai',
], function ($, _, BaseTest, mocha, chai) {
    'use strict';

    var Test = BaseTest.extend({
        initialize: function (appinit, $testbed) {
            var expect = chai.expect, that = this;

            describe('Soundings Feed', function() {
                var isLoaded = $.Deferred();

                // Prior to test run: load up the module into the document
                before(function () {
                    // Define the module HTML code
                    var htmlModule = '<div data-count="10" data-url="tests/soundings-feed/soundings-feed-data.xml" data-module="soundings-feed" class="soundings-feed" data-departments="School of Management,School of Education"></div>';

                    $testbed.empty();
                    $testbed.append(htmlModule);

                    // Initialize the application, letting it know that in the event of success to resolve our deferred object so our tests can start
                    appinit({
                        success: isLoaded.resolve
                    });
                });

                // Set the list of tests we need to run. Each one consists of a
                // description string (desc) and a function (fn) which contains a
                // simple set of chai statements
                //
                // Wait for loading to complete before running
                that.queueTests([
                    {
                        desc: 'should have correct number of articles',
                        fn: function () {
                            expect($('article').length).to.eql(9);
                        }
                    },
                    {
                        desc: 'modals should be moved to the end of the body',
                        fn: function () {
                            expect($('article .modal').length).to.eql(0);
                            expect($('body > .modal').length).to.eql(9);
                        }
                    }
                ], isLoaded.promise());

                // Cleanup after test run
                after(function () {
                    // Clear out all the modal windows (they get moved to the end of the body)
                    $('body .modal').remove();
                });
            });
        }
    });

    return Test;
});
