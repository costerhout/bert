// Created by Colin Osterhout
// University of Alaska Southeast
// ctosterhout@alaska.edu
//
// Copyright @2016 University of Alaska Southeast
// License TBD - contact author. All rights reserved.
requirejs.config({
    baseUrl: 'src/js',
    // Here's how we would add module-specific configuration:
    config: {
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
                baseUrl: '/a_assets/juicebox/',
                themeUrl: '/a_assets/juicebox/jbcore/classic/theme.css',

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
        'backbone': {
            deps: ['underscore', 'jquery'],
            exports: 'Backbone'
        },
        'underscore': {
            exports: '_'
        },
        'bootstrap2': ['jquery'],
        'bootstrap3': ['jquery'],
        'jquery.slinky': ['jquery'],
        'jquery.xml2json': ['jquery'],
        'google_maps': {
            exports: 'google'
        },
        'juicebox': {
            exports: 'juicebox'
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
        'handlebars': 'vendor/handlebars.runtime',
        'handlebars.form-helpers': 'vendor/handlebars.form-helpers',

        // --------------------------------------------------------
        // External Dependencies
        // --------------------------------------------------------
        'juicebox': '//uas.alaska.edu/a_assets/juicebox/jbcore/juicebox',

        // Note that we use a different API key for the production site
        'google_maps': 'https://maps.googleapis.com/maps/api/js?key=' + 'AIzaSyAipGT3G8PlkSYyzSovadl_X_TWckS4GkE'
    }
});
