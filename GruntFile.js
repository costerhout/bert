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
                cmspath: '/_assets/stylesheets/xsltlib',
                stylesheet: '<%= project.basedir %>/build/cms-preflight.xslt',
                strip: 'src/xslt'
            },
            src: {
                xslt: '<%= project.basedir %>/src/xslt',
                js: '<%= project.basedir %>/src/js',
                scss: '<%= project.basedir %>/src/scss'
            },
            dist: {
                xslt: '<%= project.basedir %>/dist/xslt',
                js: '<%= project.basedir %>/dist/js',
                css: '<%= project.basedir %>/dist/css'
            },
            test: 'test'
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
                        '<%= project.src.js %>/include/**.js',
                        '<%= project.src.js %>/bs3/**.js',
                        '<%= project.src.js %>/widgets/**.js'
                    ],
                    '<%= project.dist.js %>/bs2-widgets.js': [
                        '<%= project.src.js %>/include/**.js',
                        '<%= project.src.js %>/bs2/**.js',
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
                banner: '/* Copyright 2016 University of Alaska Southeast (http://uas.alaska.edu) */'
            },
            dynamic_mappings: {
                files: [
                    {
                        src: '*.js',
                        dest: '<%= project.dist.js %>/bundle',
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
                tasks: ['preflight'],
            },
            js: {
                files: [ '<%= project.src.js %>/**/*.js' ],
                tasks: ['uglify'],
            },
            livereload: {
                options: {
                    livereload: true
                },
                files: [ '<%= project.test %>/**/*.html' ]
            }
        },
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
        }
    });

    grunt.loadNpmTasks('grunt-contrib-watch');
    grunt.loadNpmTasks('grunt-contrib-connect');
    grunt.loadNpmTasks('grunt-contrib-uglify');
    grunt.loadNpmTasks('grunt-contrib-concat');
    grunt.loadNpmTasks('grunt-xsltproc');

 /**
 * Default task
 * Run `grunt` on the command line
 */
    grunt.registerTask('default', [
        'connect', 'watch'
    ]);
    grunt.registerTask('preflight', [ 'xsltproc', 'concat', 'uglify' ]);
}
