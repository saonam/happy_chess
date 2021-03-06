module.exports = function(grunt) {

    // Project configuration.
    grunt.initConfig({
        pkg: grunt.file.readJSON('package.json'),

        concat: {
            options: {
                separator: "\n\n#### Another file ####\n\n"
            },
            dist: {
                src: ['src/game.js.coffee', 'src/piece.js.coffee', 'src/point.js.coffee', 'src/player.js.coffee', 'src/chess.js.coffee', 'src/happy_chess.js.coffee'],
                dest: 'build/concat.<%= pkg.name %>.js.coffee'
            },
            server_dist: {
                src: ['src/server/00_require.js.coffee','src/server/room.js.coffee', 'src/server/player.js.coffee', 'src/server/room_manager.js.coffee', 'src/server/app.js.coffee'],
                dest: 'build/concat.app.js.coffee'
            }
        },
        coffee: {
            compile: {
                files: {
                    'build/<%= pkg.name %>.js':  '<%= concat.dist.dest %>',
                    'public/assets/javascripts/<%= pkg.name %>.js':  '<%= concat.dist.dest %>',
                    'index.js': '<%= concat.server_dist.dest %>'
                }
            }
        },
        uglify: {
            options: {
                banner: '/*! <%= pkg.name %> <%= grunt.template.today("yyyy-mm-dd") %> */\n'
            },
            build: {
                src: 'build/<%= pkg.name %>.js',
                dest: 'public/assets/javascripts/<%= pkg.name %>.min.js'
            }
        },
        watch: {
            files: ['<%= concat.dist.src %>', '<%= concat.server_dist.src %>'],
            tasks: ['concat', 'coffee']
        }

    });

    // Load the plugin that provides the "uglify" task.
    grunt.loadNpmTasks('grunt-contrib-uglify');
    grunt.loadNpmTasks('grunt-contrib-coffee');
    grunt.loadNpmTasks('grunt-contrib-concat');
    grunt.loadNpmTasks('grunt-contrib-watch');

    // Default task(s).
    grunt.registerTask('default', ['concat', 'coffee', 'uglify']);

};