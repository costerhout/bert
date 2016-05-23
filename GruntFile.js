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
                scss: '<%= project.basedir %>/src/scss'
            },
            build: '<%= project.basedir %>/build',
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
            js: {
                files: {
                    // ****************************************
                    // Distribution files
                    // ****************************************

                    // Head.js - include in <head> of document
                    '<%= project.dist.js %>/head.js': '<%= project.src.js %>/head/**.js',

                    // bs3-widgets.js - Bootstrap 3 + jQuery + widgets + templates + dependency files
                    '<%= project.dist.js %>/bert-theme.bs3.js': [
                        '<%= project.src.jquery %>/jquery*.js',
                        '<%= project.src.js %>/vendor/underscore.js',
                        '<%= project.src.js %>/vendor/backbone.js',
                        '<%= project.build %>/bert.bs3.js'
                    ],

                    // bs2-widgets.js - widgets + templates + dependency files - requires Bootstrap 2 and jQuery to be included separately
                    '<%= project.dist.js %>/bert-theme.bs2.js': [
                        '<%= project.src.jquery %>/jquery*.js',
                        '<%= project.src.js %>/vendor/underscore.js',
                        '<%= project.src.js %>/vendor/backbone.js',
                        '<%= project.build %>/bert.bs2.js'
                    ],

                    // ****************************************
                    // Development / test files
                    // ****************************************

                    // Head.js - include in <head> of document
                    '<%= project.dev.js %>/head.js': '<%= project.src.js %>/head/**.js',

                    // bs3-widgets.js - Bootstrap 3 + jQuery + widgets + templates + dependency files
                    '<%= project.dev.js %>/bert-theme.bs3.js': [
                        '<%= project.src.jquery %>/jquery*.js',
                        '<%= project.src.js %>/vendor/underscore.js',
                        '<%= project.build %>/bert.bs3.js'
                    ],

                    // bs2-widgets.js - widgets + templates + dependency files - requires Bootstrap 2 and jQuery to be included separately
                    '<%= project.dev.js %>/bert-theme.bs2.js': [
                        '<%= project.src.jquery %>/jquery*.js',
                        '<%= project.src.js %>/vendor/underscore.js',
                        '<%= project.build %>/bert.bs2.js'
                    ],
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
            // js: {
            //     files: [ '<%= project.src.js %>/**/*.js' ],
            //     tasks: ['uglify'],
            // },
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
    grunt.loadNpmTasks('grunt-contrib-uglify');
    grunt.loadNpmTasks('grunt-contrib-concat');
    grunt.loadNpmTasks('grunt-contrib-handlebars');
    grunt.loadNpmTasks('grunt-contrib-requirejs');
    grunt.loadNpmTasks('grunt-xsltproc');
    grunt.loadNpmTasks('grunt-shell');

    // Set up the RequireJS include variable, which consists of the main module
    // plus all Handlebars templates
    grunt.registerTask('requirejs_options', function () {
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
                    '{modules,models,views}/**/*.js'
                ),
                function (filename) {
                    // Strip off the extension
                    return _.initial(filename.split('.')).join('.');
                }
            ),
            // Set up the default RequireJS options
            optionsDef = {
                baseUrl: '<%= project.src.js %>',
                mainConfigFile: '<%= project.src.js %>/config.js',

                // Which requirejs to use
                name: 'vendor/require',

                // Predefine some paths for the require-handlebars-plugin
                paths: {
                        hbs: 'vendor/require-handlebars-plugin/hbs',
                        handlebars: 'vendor/require-handlebars-plugin/hbs/handlebars.runtime',
                        'handlebars.form-helpers': 'vendor/handlebars.form-helpers'

                },

                // Override some options for the require-handlebars-plugin
                hbs: {
                    templateExtension: 'hbs',
                    helperDirectory: 'templates/helpers',
                    handlebarsPath: 'handlebars'
                },

                // These are stubbed out in the output file to reduce final size
                stubModules: ['hbs', 'hbs/underscore', 'hbs/json2', 'hbs/handlebars', 'vendor/handlebars.form-helpers'],

                // We're going to run the optimizer later on
                optimize: 'none',

                // Wrap up RequireJS functions into an IIFE to protect the global space
                wrap: true
            },
            configTarget = {
                bs2: {
                    options: _.defaults(
                        {
                            mainConfigFile: '<%= project.src.js %>/config.js',
                            out: '<%= project.build %>/bert.bs2.js',

                            // Include all of the template files as well as the entry point
                            include: _.union(
                                templates,
                                modules,
                                [ 'config', 'bs2' ]
                            )
                        }, optionsDef)
                },
                bs3: {
                    options: _.defaults(
                        {
                            mainConfigFile: '<%= project.src.js %>/config.js',
                            out: '<%= project.build %>/bert.bs3.js',

                            // Include all of the template files as well as the entry point
                            include: _.union(
                                templates,
                                modules,
                                [ 'config', 'bs3' ]
                            )
                        }, optionsDef)
                }
            };

            grunt.config.set('requirejs', configTarget);
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
    grunt.registerTask('js', [
        'requirejs_options', 'requirejs:bs2', 'requirejs:bs3', 'concat', 'uglify'
    ]);

    // Compile the CSS components
    grunt.registerTask('css', [
        'sass', 'postcss'
    ]);

    // Preflight is used to do it all in preparation for loading up into CMS
    grunt.registerTask('preflight', [ 'doc', 'xslt', 'js', 'css' ]);
}
