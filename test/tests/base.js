/**
* @Author: Colin Osterhout <ctosterhout>
* @Date:   2016-07-15T20:41:14-08:00
* @Email:  ctosterhout@alaska.edu
* @Project: BERT
* @Last modified by:   ctosterhout
* @Last modified time: 2016-07-15T23:45:39-08:00
* @License: Released under MIT License. Copyright 2016 University of Alaska Southeast.  For more details, see https://opensource.org/licenses/MIT
*/

define([
    'jquery',
    'underscore',
    'backbone'
], function ($, _, Backbone) {
    var BaseTest = function () {
        // Call the initialization function, either as supplied or the default variety
        this.initialize.apply(this, arguments);
    };

    // Copy Backbone's extend function into our function as well
    BaseTest.extend = Backbone.Collection.extend;

    // Build the class prototype
    _.extend(BaseTest.prototype,  {
        // Link the constructor function
        constructor: BaseTest,

        // initialize shim - typically overridden in child
        initialize: function () {},

        // registerTests
        // Create an internal set of test functions all set to start
        // whenever the promise parameter is resolved
        //
        // Parameters
        //     aTests (array) - Array of tests to be run, each of which must conform to this pattern:
        //         {
        //             desc: 'description of test',
        //             fn: function () {   // function with test statements, e.g.:
        //                 expect($('.someel').length).to.eql(4);
        //             }
        //         }
        //     promise (object) - Promise object which will be used to queue the test functions
        //
        //     Returns deferred object that will resolve when all tests are done.
        queueTests: function (aTests, promise) {
            // dfd = array of deferred objects created by the test registration loop
            //  dfd is created via a chain process, operating on the aTests parameter
            var dfd = _.chain(aTests)
                // Filter out all tests which do not have the required members
                .filter(function (obj) {
                    return _.has(obj, 'fn') && _.has(obj, 'desc');
                })
                // Now for each test definition create a deferred object and
                // set up the test. Return the deferred object in place of the
                // original entry
                .map(function (test) {
                    var deferred = $.Deferred();

                    it(test.desc, function (done) {
                        // Set up the upstream done handlers to queue off of our deferred object
                        deferred.then(function () { done(); });
                        deferred.fail(function (e) { done(e); });

                        // Wait for when the promise resolves
                        $.when(promise)
                            .then(function () {
                            try {
                                // And then execute the defined function and
                                // resolve this test's deferred object
                                test.fn();
                                deferred.resolve();
                            }
                            catch (e) {
                                // Upon an error barf to the console and fail
                                // the deferred object
                                console.log('Mocha test error: ' + e.message);
                                deferred.reject(e);
                            }
                        });
                    });

                    return deferred;
                })
                .value();

            // Aggregate all of the deferred objects into one promise
            // and returned to the caller, should they need it.
            return $.when.apply($, dfd).promise();
        }
    });

    return BaseTest;
});
