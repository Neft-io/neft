'use strict'

fs = require 'fs-extra'
pathUtils = require 'path'
childProcess = require 'child_process'
config = require './config'

{utils, log} = Neft

NEFT_BIN_PATH = pathUtils.join __dirname, '../../../bin/neft.js'

BUILD_ARGS = [
    'build',
    '',
    "--init-file=#{config.getInitFilePath()}",
    '--out=',
    '--config='
]

BUILD_OPTIONS =
    silent: true
    env:
        RUN_TESTS: false

BUILD_LOG_PREFIX = '[BUILD] '

###
Builds Neft app for the given target.
See `neft help` for available targets.
Callback function is called when build is ready.
###
exports.buildProject = (target, env, callback) ->
    log.info "#{target} project building"
    fs.removeSync './build/browser'
    args = utils.clone BUILD_ARGS
    args[1] = target # target
    args[3] += config.getPlatformOutFolder(target) # out
    args[4] += JSON.stringify # config
        testingServerUrl: config.getServerUrl()
        environment: env
    error = null
    buildProcess = childProcess.fork NEFT_BIN_PATH, args, BUILD_OPTIONS
    buildProcess.stdout.on 'data', (data) ->
        log BUILD_LOG_PREFIX + String(data).trim()
    buildProcess.stderr.on 'data', (data) ->
        error = String(data).trim()
        log.error BUILD_LOG_PREFIX + error
        buildProcess.kill()
    buildProcess.on 'exit', ->
        log.info "#{target} project built"
        callback error