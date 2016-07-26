/**
* @Author: Colin Osterhout <ctosterhout>
* @Date:   2016-03-25T09:46:50-08:00
* @Email:  ctosterhout@alaska.edu
* @Project: BERT
* @Last modified by:   ctosterhout
* @Last modified time: 2016-07-25T17:37:12-08:00
* @License: Released under MIT License. Copyright 2016 University of Alaska Southeast.  For more details, see https://opensource.org/licenses/MIT
*/


/**
 * Grunt Module
 */

module.exports = function(grunt) {
    grunt.initConfig({
        pkg: grunt.file.readJSON('package.json'),

        /**
        * Set project object
        */
        project: {
            basedir: '.',
            // global: {
            //     scss: '../include/scss'
            // },
            preflight: {
                cmspath: '/_assets/stylesheets/bert',
                stylesheet: '<%= project.basedir %>/util/cms-preflight.xslt',
                strip: 'src/xslt'
            },
            src: {
                xslt: '<%= project.basedir %>/src/xslt',
                js: '<%= project.basedir %>/src/js',
                fontawesome: '<%= project.basedir %>/src/font-awesome',
                handlebars: '<%= project.basedir %>/src/templates',
                bootstrap2: '<%= project.basedir %>/src/bootstrap2',
                bootstrap3: '<%= project.basedir %>/src/bootstrap3',
                jquery:  '<%= project.basedir %>/src/jquery',
                scss: '<%= project.basedir %>/src/scss',
                templates: {
                    helpers: '<%= project.basedir %>/src/js/templates/helpers',
                }
            },
            build: {
                dev: '<%= project.basedir %>/build/dev',
                dist: '<%= project.basedir %>/build/dist'
            },
            dist: {
                xslt: '<%= project.basedir %>/dist/xslt',
                js: '<%= project.basedir %>/dist/js',
                css: '<%= project.basedir %>/dist/css'
            },
            dev: {
                js: '<%= project.basedir %>/dev/js',
                css: '<%= project.basedir %>/dev/css'
            },
            requirejs: {
            },
            test: '<%= project.basedir %>/test'
        },
        /*
        * Todo here: put in the version string on the file from Git if possible
        */
        xsltproc: {
            options: {
                stylesheet: '<%= project.preflight.stylesheet %>',
                stringparams: {
                    'sPathBase': '<%= project.preflight.cmspath %>',
                    'sPathStrip': '<%= project.preflight.strip %>'
                },
                filepath: true
            },
            compile: {
                files: [{
                    expand: true,
                    cwd: '<%= project.src.xslt %>',
                    src: './**/*.xslt',
                    dest: '<%= project.dist.xslt %>'
                }]
            }
        },
        // Used to generate theme CSS as a synthesis of Bootstrap, FontAwesome, and project files
        sass: {
            dev: {
                options: {
                    precision: 8,
                    style: 'expanded',
                    loadPath: [
                        '<%= project.src.scss %>',
                        '<%= project.src.scss %>/dev',
                        '<%= project.src.bootstrap3 %>/assets/stylesheets',
                        '<%= project.src.fontawesome %>/scss'
                    ]
                },
                files: [
                    {
                    expand: true,
                    cwd: '<%= project.src.scss %>/',
                    src: ['**/*.scss'],
                    dest: '<%= project.dev.css %>/',
                    ext: '.css',
                    extDot: 'first'
                    }
                ]
            },
            dist: {
                options: {
                    precision: 8,
                    style: 'compact',
                    loadPath: [
                        '<%= project.src.scss %>',
                        '<%= project.src.scss %>/dist',
                        '<%= project.src.bootstrap3 %>/assets/stylesheets',
                        '<%= project.src.fontawesome %>/scss'
                    ]
                },
                files: [
                    {
                    expand: true,
                    cwd: '<%= project.src.scss %>/',
                    src: ['**/*.scss'],
                    dest: '<%= project.dist.css %>/',
                    ext: '.css',
                    extDot: 'first'
                    }
                ]
            }
        },
        // Process CSS files after generation to minimize, add browser prefixes
        postcss: {
            dist: {
                options: {
                    processors: [
                        require('pixrem')(), // add fallbacks for rem units
                        require('autoprefixer')({
                            browsers: [
                                "Android 2.3",
                                "Android >= 4",
                                "Chrome >= 20",
                                "Firefox >= 24",
                                "Explorer >= 8",
                                "iOS >= 6",
                                "Opera >= 12",
                                "Safari >= 6"
                            ]
                        }), // add vendor prefixes
                        require('cssnano')() // minify the result
                    ]
                },
                src: '<%= project.dist.css %>/**/*.css'
            },
            dev: {
                options: {
                    processors: [
                        require('pixrem')(), // add fallbacks for rem units
                        require('autoprefixer')({
                            browsers: [
                                "Android 2.3",
                                "Android >= 4",
                                "Chrome >= 20",
                                "Firefox >= 24",
                                "Explorer >= 8",
                                "iOS >= 6",
                                "Opera >= 12",
                                "Safari >= 6"
                            ]
                        }), // add vendor prefixes
                    ]
                },
                src: '<%= project.dev.css %>/**/*.css'
            }
        },
        // Preen the javascript files
        jshint: {
            all: [
                '<%= project.src.js %>/*.js',
                '<%= project.src.js %>/models/**/*.js',
                '<%= project.src.js %>/modules/**/*.js',
                '<%= project.src.js %>/views/**/*.js',
                '<%= project.src.js %>/include/**/*.js',
                '<%= project.src.js %>/head/**/*.js',
            ],
            options: {
                globals: {
                    'google': false,
                    'window': false,
                    'document': false,
                    'Handlebars': false,
                    'console': false,
                    'location': false,
                    'require': false,
                    'requirejs': false,
                    'define': false,
                    'UAS': false
                },
                strict: true,
                undef: true,
                unused: 'vars',
                latedef: 'nofunc',
                futurehostile: true,
                eqeqeq: true,
                curly: true,
                bitwise: true
            }
        },
        // Placeholder config
        requirejs_options: {
            dev: {},
            dist: {}
        },
        // Build modernizr tool to check for browser features
        modernizr: {
            dist: {
                // Put the built file in the list of things to run in the <head>
                dest: '<%= project.src.js %>/lib/modernizr.js',
                crawl: true,
                uglify: false,
                files: {
                    src: [
                        '<%= project.src.js %>/**/*.js',
                        '!<%= project.src.js %>/lib/**/*',
                        '!<%= project.src.js %>/vendor/**/*'
                    ]
                }
            }
        },
        /**
        * Combine multiple JS files into one. Current targets:
        *
        * head.js: Includes JS that should be included in the HEAD of the HTML
        *   document. Not specific to BS2 or BS3.
        * bs3-widgets.js: Includes common include files, ancillary bs3 javascript,
        *   and common widget code.
        * bs2-widgets.js: Includes common include files, ancillary bs2 javascript,
        *   and common widget code.
        *
        * Neither of these two targets includes their respective Bootstrap
        * framework JS at this time - this just includes helper pieces of JS to
        * augment functionality.
        */
        concat: {
            dev: {
                files: {
                    // ****************************************
                    // Development / test files
                    // ****************************************

                    // Head.js - include in <head> of document
                    '<%= project.dev.js %>/head.js': '<%= project.src.js %>/head/**.js',

                    // bs3-widgets.js - Bootstrap 3 + jQuery + widgets + templates + dependency files
                    '<%= project.dev.js %>/bert-theme.bs3.js': [
                        '<%= project.src.jquery %>/jquery*.js',
                        '<%= project.build.dev %>/bert.bs3.js'
                    ],

                    // bs2-widgets.js - widgets + templates + dependency files - requires Bootstrap 2 and jQuery to be included separately
                    '<%= project.dev.js %>/bert-theme.bs2.js': [
                        '<%= project.src.jquery %>/jquery*.js',
                        '<%= project.build.dev %>/bert.bs2.js'
                    ],
                }
            },
            dist: {
                files: {
                    // ****************************************
                    // Distribution files
                    // ****************************************

                    // Head.js - include in <head> of document
                    '<%= project.dist.js %>/head.js': '<%= project.src.js %>/head/**.js',

                    // bs3-widgets.js - Bootstrap 3 + jQuery + widgets + templates + dependency files
                    '<%= project.dist.js %>/bert-theme.bs3.js': [
                        '<%= project.src.jquery %>/jquery*.js',
                        '<%= project.build.dist %>/bert.bs3.js'
                    ],

                    // bs2-widgets.js - widgets + templates + dependency files - requires Bootstrap 2 and jQuery to be included separately
                    '<%= project.dist.js %>/bert-theme.bs2.js': [
                        '<%= project.src.jquery %>/jquery*.js',
                        '<%= project.build.dist %>/bert.bs2.js'
                    ]
                }
            }
        },
        /**
        * Uglify (minification of JS)
        *
        * Options:
        *   banner - This string gets prepended on to any output
        */
        uglify: {
            options: {
                banner: '/* Copyright 2016 University of Alaska Southeast (http://uas.alaska.edu) */',
                sourceMap: true,
                sourceMapIncludeSources: true
            },
            dynamic_mappings: {
                files: [
                    {
                        src: ['*.js', '!*.min.js'],
                        dest: '<%= project.dist.js %>',
                        cwd: '<%= project.dist.js %>',
                        ext: '.min.js',
                        extDot: 'last',
                        expand: true
                    }
                ]
            }
        },
        /**
        * Watch
        */
        watch: {
            xslt: {
                files: [ '<%= project.src.xslt %>/**/*.xslt' ],
                tasks: ['xsltproc'],
            },
            scss: {
                files: [ '<%= project.src.scss %>/**/*.scss' ],
                tasks: ['sass', 'postcss'],
            },
            js: {
                files: [ '<%= project.src.js %>/**/*.js' ],
                tasks: ['js-dev'],
            },
            livereload: {
                options: {
                    livereload: true
                },
                files: [
                    '<%= project.basedir %>/**/*.html',
                    '<%= project.dev.css %>/**/*.css',
                    '<%= project.src.js %>/**/*.js'
                    ]
            }
        },
        // HTTP server for testing
        connect: {
            server: {
                options: {
                    base: ['<%= project.test %>'],
                    middleware: function(connect, options, middlewares) {
                        var connectSSI = require('connect-ssi');

                        if (!Array.isArray(options.base)) {
                            options.base = [options.base];
                        }
                        var directory = options.directory || options.base[options.base.length - 1];

                        middlewares.unshift(connectSSI({
                            baseDir: directory,
                            ext: '.html'
                        }));
                        return middlewares;
                    },
                    livereload: true,
                    open: {
                        target: 'http://localhost:8000',
                        appName: 'open',
                        callback: function() {}
                    }
                }
            }
        },
        // Build documentation for XSLT files
        shell: {
            xsltdoc: {
                command: 'java -jar node_modules/xsltdoc/vendor/net/sf/saxon/Saxon-HE/9.6.0-7/Saxon-HE-9.6.0-7.jar xsltdoc-config.xml node_modules/xsltdoc/xsl/xsltdoc.xsl'
            }
        }
    });

    grunt.loadNpmTasks('grunt-contrib-watch');
    grunt.loadNpmTasks('grunt-contrib-sass');
    grunt.loadNpmTasks('grunt-postcss');
    grunt.loadNpmTasks('grunt-contrib-connect');
    grunt.loadNpmTasks('grunt-contrib-jshint');
    grunt.loadNpmTasks("grunt-modernizr");
    grunt.loadNpmTasks('grunt-contrib-uglify');
    grunt.loadNpmTasks('grunt-contrib-concat');
    grunt.loadNpmTasks('grunt-contrib-handlebars');
    grunt.loadNpmTasks('grunt-contrib-requirejs');
    grunt.loadNpmTasks('grunt-xsltproc');
    grunt.loadNpmTasks('grunt-shell');

    // Set up the RequireJS include variable, which consists of the main module
    // plus all Handlebars templates
    function setRequireJSOptions (target) {
        var _ = require('underscore'),
            templates = _.map(
                grunt.file.expand(
                    {
                        cwd: grunt.config.get('project.src.js')
                    },
                    'templates/**/*.hbs'
                ),
                function (filename) {
                    // Strip off the extension and prepend with 'hbs!', the plugin name
                    return 'hbs!' + _.initial(filename.split('.')).join('.');
                }
            ),
            modules = _.map(
                grunt.file.expand(
                    {
                        cwd: grunt.config.get('project.src.js')
                    },
                    '{modules,models,views,transitional,helpers}/**/*.js'
                ),
                function (filename) {
                    // Strip off the extension
                    return _.initial(filename.split('.')).join('.');
                }
            ),
            optionsDef = {
                baseUrl: '<%= project.src.js %>',

                // Which requirejs optimizer to use
                name: 'vendor/require',

                // Certain modules are only needed in the development build. Others can be "stubbed out", meaning they're not included but a reference is made for them to an empty object.
                stubModules: {
                    dev: [],
                    dist: ['hbs/json2']
                }[target],

                // We're going to run the optimizer later on
                optimize: 'none',

                // Uncomment to wrap up RequireJS functions into an IIFE to protect the global space
                // This is currently commented so that the Juicebox object can be properly registered in the global
                // space, although we could include this as part of the concat operation and shim it.
                // wrap: true
            },
            configTarget = {
                bs2: {
                    options: _.defaults(
                        {
                            mainConfigFile:
                                {
                                    dev: '<%= project.src.js %>/config-dev.js',
                                    dist: '<%= project.src.js %>/config.js'
                            }[target],
                            out: {
                                dev: '<%= project.build.dev %>/bert.bs2.js',
                                dist: '<%= project.build.dist %>/bert.bs2.js'
                            }[target],

                            // Include all of the template files as well as the entry point
                            include: _.union(
                                templates,
                                modules,
                                [
                                    {
                                        dev: 'config-dev',
                                        dist: 'config'
                                    }[target],
                                    'bs2'
                                ]
                            )
                        }, optionsDef)
                },
                bs3: {
                    options: _.defaults(
                        {
                            mainConfigFile:
                                {
                                    dev: '<%= project.src.js %>/config-dev.js',
                                    dist: '<%= project.src.js %>/config.js'
                            }[target],
                            out: {
                                dev: '<%= project.build.dev %>/bert.bs3.js',
                                dist: '<%= project.build.dist %>/bert.bs3.js'
                            }[target],

                            // Include all of the template files as well as the entry point
                            include: _.union(
                                templates,
                                modules,
                                [
                                    {
                                        dev: 'config-dev',
                                        dist: 'config'
                                    }[target],
                                    'bs3'
                                ]
                            )
                        }, optionsDef)
                }
            };

            grunt.log.debug(JSON.stringify(configTarget, null, '    '));
            grunt.config.set('requirejs', configTarget);
    }

    grunt.registerMultiTask('requirejs_options', function() {
        setRequireJSOptions(this.target);
    });

    // The default task spins up a server and watches for files to change for reload
    grunt.registerTask('default', [
        'connect', 'watch'
    ]);

    // Create documentation from source
    grunt.registerTask('doc', [
        'shell:xsltdoc'
    ]);

    // Create distribution XSLT from source
    grunt.registerTask('xslt', [
        'xsltproc'
    ]);

    // Compile the Javascript components
    grunt.registerTask('js-dev', [
        'modernizr',
        'requirejs_options:dev',
        'requirejs:bs2', 'requirejs:bs3', 'concat:dev'
    ]);

    grunt.registerTask('js-dist', [
        'modernizr',
        'requirejs_options:dist',
        'requirejs:bs2', 'requirejs:bs3', 'concat:dist', 'uglify'
    ]);

    // Compile the CSS components
    grunt.registerTask('css', [
        'sass', 'postcss'
    ]);

    // Preflight is used to do it all in preparation for loading up into CMS
    grunt.registerTask('preflight', [ 'doc', 'xslt', 'js-dist', 'css' ]);
}
