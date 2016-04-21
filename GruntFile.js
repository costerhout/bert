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
                stylesheet: '<%= project.basedir %>/build/cms-preflight.xslt',
                strip: 'src/xslt'
            },
            src: {
                xslt: '<%= project.basedir %>/src/xslt',
                js: '<%= project.basedir %>/src/js',
                fontawesome: '<%= project.basedir %>/src/font-awesome',
                bootstrap: '<%= project.basedir %>/src/bootstrap',
                jquery:  '<%= project.basedir %>/src/jquery',
                scss: '<%= project.basedir %>/src/scss'
            },
            dist: {
                xslt: '<%= project.basedir %>/dist/xslt',
                js: '<%= project.basedir %>/dist/js',
                css: '<%= project.basedir %>/dist/css'
            },
            dev: {
                js: '<%= project.basedir %>/dev/js',
                css: '<%= project.basedir %>/dev/css'
            }
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
                        '<%= project.src.bootstrap %>/assets/stylesheets',
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
                        '<%= project.src.bootstrap %>/assets/stylesheets',
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
                '<%= project.src.js %>/**/*.js'
            ]
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
                    '<%= project.dist.js %>/head.js': '<%= project.src.js %>/head/**.js',
                    '<%= project.dist.js %>/bs3-widgets.js': [
                        '<%= project.src.jquery %>/*.js',
                        '<%= project.src.bootstrap %>/assets/javascripts/bootstrap.js',
                        '<%= project.src.js %>/include/**.js',
                        '<%= project.src.js %>/bs3/**.js',
                        '<%= project.src.js %>/vendor/**.js',
                        '<%= project.src.js %>/widgets/**.js'
                    ],
                    '<%= project.dist.js %>/bs2-widgets.js': [
                        '<%= project.src.js %>/include/**.js',
                        '<%= project.src.js %>/bs2/**.js',
                        '<%= project.src.js %>/vendor/**.js',
                        '<%= project.src.js %>/widgets/**.js'
                    ],
                    '<%= project.dev.js %>/head.js': '<%= project.src.js %>/head/**.js',
                    // The BS3 widgets file includes the BS3 JavaScript piece as well as jQuery
                    '<%= project.dev.js %>/bs3-widgets.js': [
                        '<%= project.src.jquery %>/*.js',
                        '<%= project.src.bootstrap %>/assets/javascripts/bootstrap.js',
                        '<%= project.src.js %>/include/**.js',
                        '<%= project.src.js %>/bs3/**.js',
                        '<%= project.src.js %>/vendor/**.js',
                        '<%= project.src.js %>/widgets/**.js'
                    ],
                    '<%= project.dev.js %>/bs2-widgets.js': [
                        '<%= project.src.js %>/include/**.js',
                        '<%= project.src.js %>/bs2/**.js',
                        '<%= project.src.js %>/vendor/**.js',
                        '<%= project.src.js %>/widgets/**.js'
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
                tasks: ['uglify'],
            },
            livereload: {
                options: {
                    livereload: true
                },
                files: [
                    '<%= project.basedir %>/**/*.html',
                    '<%= project.dev.css %>/**/*.css',
                    '<%= project.dev.js %>/**/*.js'
                    ]
            }
        },
        // HTTP server for testing
        connect: {
            server: {
                options: {
                    directory: '<%= project.basedir.test %>',
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
    grunt.loadNpmTasks('grunt-xsltproc');
    grunt.loadNpmTasks('grunt-shell');

 /**
 * Default task
 * Run `grunt` on the command line
 */
    grunt.registerTask('default', [
        'connect', 'watch'
    ]);
    grunt.registerTask('preflight', [ 'shell:xsltdoc', 'xsltproc', 'concat', 'uglify', 'sass', 'postcss' ]);
    grunt.registerTask('xsltdoc', ['shell:xsltdoc']);
}
