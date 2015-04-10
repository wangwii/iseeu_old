module.exports = (grunt) ->
  
  grunt.initConfig
    coffeelint:
      app: ['*.coffee']
    clean:
      build: ['_build']
    copy:
      html:
        files: [
          {expand: true, cwd: 'src/', src: ['**/*.html'],   dest: '_build/', filter: 'isFile'}
          {expand: true, cwd: 'src/', src: ['css/*.css'],   dest: '_build/', filter: 'isFile'}
          {expand: true, cwd: 'src/', src: ['images/*'],    dest: '_build/', filter: 'isFile'}
          {expand: true, cwd: 'src/', src: ['fonts/*'],    dest: '_build/', filter: 'isFile'}
          {expand: true, cwd: 'src/', src: ['favicon.ico'], dest: '_build/', filter: 'isFile'}
          {expand: true, src: ['vendor/**/*'], dest: '_build/'}
        ]
    coffee:
      glob_to_multiple:
        expand: true
        cwd: 'src/'
        src: ['**/*.coffee']
        dest: '_build/'
        ext: '.js'
    cjsx:
      compile:
        files:
          '_build/scripts/ui.js': ['src/**/*.cjsx']
    watch:
      coffee_files:
        files: ['src/**/*.coffee']
        tasks: ['coffee']
      html_files:
        files: ['src/**/*.html', 'src/**/*.css',]
        tasks: ['copy']
      cjsx_files:
        files: ['src/**/*.cjsx']
        tasks: ['cjsx']
      vendor_files:
        files: ['vendor/**/*']
        tasks: ['copy']

  grunt.loadNpmTasks 'grunt-contrib-copy'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-coffeelint'
  grunt.loadNpmTasks 'grunt-coffee-react'

  grunt.registerTask 'default', ['copy', 'coffee', 'cjsx', 'watch']
