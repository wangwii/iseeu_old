module.exports = (grunt) ->
  
  grunt.initConfig
    coffeelint:
      app: ['*.coffee']
    clean:
      build: ['_build']
    copy:
      html:
        files: [
          {expand: true, flatten: true, src: ['src/**/*.html'], dest: '_build/', filter: 'isFile'}
        ]
      image:
        files: [
          {expand: true, flatten: true, src: ['src/images/*'], dest: '_build/images', filter: 'isFile'}
        ]  
    coffee:
      glob_to_multiple:
        expand: true
        flatten: true
        cwd: 'src/'
        src: ['**/*.coffee']
        dest: '_build/'
        ext: '.js'
    watch:
      coffee_files:
        files: ['src/**/*.coffee']
        tasks: ['coffee']
      html_files:
        files: ['src/**/*.html']
        tasks: ['copy']

  grunt.loadNpmTasks 'grunt-contrib-copy'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-coffeelint'

  grunt.registerTask 'default', ['copy', 'watch']
