// Created by Colin Osterhout
// University of Alaska Southeast
// ctosterhout@alaska.edu
//
// Copyright @2016 University of Alaska Southeast
// License TBD - contact author. All rights reserved.
requirejs.config({
    baseUrl: 'src/js',
    // Here's how we would add module-specific configuration:
    // config: {
    //         'modules/mapdisplay': {
    //             'baseTemplateUrl': 'templates'
    //         }
    // },
    shim: {
        'backbone': {
            deps: ['underscore', 'jquery'],
            exports: 'Backbone'
        },
        'underscore': {
            exports: '_'
        },
        'bootstrap': ['jquery'],
        'jquery.slinky': ['jquery'],
        'jquery.xml2json': ['jquery'],
        'google_maps': {
            exports: 'google'
        }
    },
    paths: {
        'google_maps': 'https://maps.googleapis.com/maps/api/js?key=' + 'AIzaSyDsms9O16Ivd46UeWcd4UBcfFIAFdiFtYg',
        'hbs': 'vendor/require-handlebars-plugin/hbs',
        'jquery': 'vendor/jquery',
        'underscore': 'vendor/underscore',
        'backbone': 'vendor/backbone',
        'bootstrap': 'vendor/bootstrap',
        'jquery.slinky': 'vendor/jquery.slinky',
        'jquery.xml2json': 'vendor/jquery.xml2json',
        'handlebars': 'vendor/handlebars.runtime',
        'handlebars.form-helpers': 'vendor/handlebars.form-helpers.min'
    }
});
