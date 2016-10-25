/**
* @Author: Colin Osterhout <ctosterhout>
* @Date:   2016-05-07T19:34:58-08:00
* @Email:  ctosterhout@alaska.edu
* @Project: BERT
* @Last modified by:   ctosterhout
* @Last modified time: 2016-10-21T14:28:41-08:00
* @License: Released under MIT License. Copyright 2016 University of Alaska Southeast.  For more details, see https://opensource.org/licenses/MIT
*/


requirejs.config({
    baseUrl: 'src/js',
    // Here's how we would add module-specific configuration:
    config: {
        'main': {
            // We set this to an absolute path that exists under the production server's root directory
            baseTemplateUrl: '/a_assets/templates',
            baseTemplateUrlInternal: 'templates',
            timeoutModuleLoad: 10000
        },
        'lib/debug': {
            enable: false
        },
        'modules/zopim': {
            position: 'bl',
            timeoutLoad: 5000,
            timeoutPopup: 0
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
        },
        'modules/decisiontree': {
            animationDuration: 200
        },
        'transitional/datatables': {
            paging: false,
            ordering: false,
            searching: false
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
        'zopim': {
            exports: '$zopim'
        },
        'modernizr': {
            exports: 'Modernizr'
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
        'datatables': 'vendor/datatables',
        'modernizr': 'lib/modernizr',

        // --------------------------------------------------------
        // External Dependencies
        // --------------------------------------------------------
        'juicebox': '//uas.alaska.edu/a_assets/juicebox/jbcore/juicebox',
        'zopim': 'vendor/zopim',

        // Note that we use a different API key for the production site
        'google_maps': 'https://maps.googleapis.com/maps/api/js?key=' + 'AIzaSyAipGT3G8PlkSYyzSovadl_X_TWckS4GkE'
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
