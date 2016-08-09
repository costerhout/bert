/**
* @Author: Colin Osterhout <ctosterhout>
* @Date:   2016-06-29T15:18:02-08:00
* @Email:  ctosterhout@alaska.edu
* @Project: BERT
* @Last modified by:   ctosterhout
* @Last modified time: 2016-07-27T12:15:04-08:00
* @License: Released under MIT License. Copyright 2016 University of Alaska Southeast.  For more details, see https://opensource.org/licenses/MIT
*/

define([
    'jquery',
    'underscore',
    '/tests/base.js',
    'text!/tests/zopim/sitka.txt',
    'mocha',
    'chai',
], function ($, _, BaseTest, htmlModule, mocha, chai) {
    'use strict';

    var Test = BaseTest.extend({
        initialize: function (appinit, $testbed) {
            var expect = chai.expect,
                that = this,
                runTest = function(htmlModule) {
                    var isLoaded = $.Deferred();

                    // Initialize the testbed with the module definition
                    $testbed.append(htmlModule);

                    // Initialize the application, letting it know that in the event of success to resolve our deferred object so our tests can start
                    appinit({
                        success: isLoaded.resolve
                    });

                    // Set the list of tests we need to run. Each one consists of a
                    // description string (desc) and a function (fn) which contains a
                    // simple set of chai statements
                    //
                    // Wait for loading to complete before running
                    that.queueTests([
                        {
                            desc: 'should have two Zopim iframe elements',
                            fn: function () {
                                expect($('.zopim iframe').length).to.eql(2);
                            }
                        }
                    ], isLoaded.promise());
                };

            describe('Zopim', function () {
                this.timeout(10000);

                before(function () {
                    $testbed.empty();
                });
                after(function() {
                    // Clear out all the iframes
                    $('.zopim iframe').each(function (i, el) {
                        var $parent = $(el).parent();
                        $(el).remove();
                        $parent.remove();
                    });

                    // Remove the external Zopim module from the global space
                    delete window.$zopim;

                    $testbed.empty();
                })

                describe('Sitka', _.partial(runTest, htmlModule));
            });
        }
    });

    return Test;
});
