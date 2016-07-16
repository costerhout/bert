/**
* @Author: Colin Osterhout <ctosterhout>
* @Date:   2016-05-20T06:55:24-08:00
* @Email:  ctosterhout@alaska.edu
* @Project: BERT
* @Last modified by:   ctosterhout
* @Last modified time: 2016-06-30T13:11:28-08:00
* @License: Released under MIT License. Copyright 2016 University of Alaska Southeast.  For more details, see https://opensource.org/licenses/MIT
*/


requirejs.config({
    baseUrl: 'src/js',
    // Here's how we would add module-specific configuration:
    config: {
        'main': {
            // We set this to an absolute path that exists under the test server's root directory
            baseTemplateUrl: '/templates',
            baseTemplateUrlInternal: 'templates'
        },
        'modules/gallery': {
            flickr: {
                // Options that we're not mutating at this time
                galleryWidth: "100%",
                galleryHeight: "100%",
                showLargeThumbs: "true",
                maxCaptionHeight: "100",
                showImageOverlay: "AUTO",
                useThumbDots: "false",
                showOverlayOnLoad: "true",
                shareFacebook: "true",
                sharePinterest: "true",
                screenMode: 'AUTO',

                // Path options (changes between dev and dist configuration)
                baseUrl: 'juicebox/',
                themeUrl: 'juicebox/jbcore/classic/theme.css',

                // These options can be set by runtime configuration
                enableLooping: 'true',
                showAutoPlayStatus: 'false',
                displayTime: '8',
                buttonBarPosition: 'OVERLAY',
                captionPosition: 'NONE',
                backgroundColor: "rgba(169,187,70,1)",
                autoPlayOnLoad: 'true',
                showThumbsOnLoad: 'false'
            }
        }
    },
    shim: {
        'bootstrap2': ['jquery'],
        'bootstrap3': ['jquery'],
        'jquery.slinky': ['jquery'],
        'jquery.xml2json': ['jquery'],
        'google_maps': {
            exports: 'google'
        },
        'juicebox': {
            exports: 'juicebox'
        },
        'modernizr': {
            exports: 'Modernizr'
        },
        'mocha': {
            exports: 'mocha'
        }
    },
    paths: {
        'bootstrap2': 'vendor/bootstrap2',
        'bootstrap3': 'vendor/bootstrap3',
        'hbs': 'vendor/require-handlebars-plugin/hbs',
        'jquery': 'vendor/jquery',
        'underscore': 'vendor/underscore',
        'backbone': 'vendor/backbone',
        'jquery.slinky': 'vendor/jquery.slinky',
        'jquery.xml2json': 'vendor/jquery.xml2json',
        'handlebars': 'vendor/handlebars',
        'handlebars.runtime': 'vendor/handlebars.runtime',
        'modernizr': 'lib/modernizr',

        // Testing specific requirements
        'mocha': 'vendor/mocha',
        'chai': 'vendor/chai',

        // --------------------------------------------------------
        // External Dependencies (different in production)
        // --------------------------------------------------------
        'juicebox': 'vendor/juicebox',

        // Note that we use a different API key for the production site
        'google_maps': 'https://maps.googleapis.com/maps/api/js?key=' + 'AIzaSyDsms9O16Ivd46UeWcd4UBcfFIAFdiFtYg'
    },
    map: {
        '*': {
            'hbs/underscore': 'underscore',
            'hbs/handlebars': 'handlebars'
        }
    },
    hbs: {
        // We don't allow hbs to figure out the helpers for us at this time, these will be registered as part of a module
        helpers: false,
        templateExtension: 'hbs',
    }
});
