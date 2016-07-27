/**
* @Author: Colin Osterhout <ctosterhout>
* @Date:   2015-03-16T09:59:41-08:00
* @Email:  ctosterhout@alaska.edu
* @Project: BERT
* @Last modified by:   ctosterhout
* @Last modified time: 2016-07-26T16:25:54-08:00
* @License: Released under MIT License. Copyright 2016 University of Alaska Southeast.  For more details, see https://opensource.org/licenses/MIT
*/


require([
    'jquery',
    'underscore',
    'mocha',
    'chai',
    'main',
    'helpers/bs2',
    '/tests/soundings-feed/test.js',
    '/tests/zopim/test.js',
    '/tests/mapdisplay/test.js'
], function ($, _, mocha, chai, app, HandlebarsBootstrap, TestSoundingsFeed, TestZopim, TestMapdisplay) {
    var aTests = [
        TestSoundingsFeed,
        TestZopim,
        TestMapdisplay
    ];

    HandlebarsBootstrap.register();

    // Start whenever the DOM is ready
    $(function () {
        var assert = chai.assert,
            // We'll pass a "testinit" function to wrap around the app initialization
            appinit = function (options) {
                app.initialize(_.defaults(options,
                    {
                        templateScheme: 'bs2',
                        fail: function (err) { console.log(err); }
                    }
                ))
            },
            // Testbed is where we'd like to have tests put their information
            $testbed = $('#testbed').first();

        // Sanity check
        assert($testbed.length > 0);

        // Setup and run tests
        mocha.setup('bdd');

        // Initialize the test modules
        _.each(aTests, function (Test) {
            var test = new Test(appinit, $testbed);
        });

        // test = new TestSoundingsFeed(appinit, $testbed);

        // Run all the registered tests
        mocha.run();
    });
});
