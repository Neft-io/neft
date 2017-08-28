'use strict'

childProcess = require 'child_process'
fs = require 'fs'
pathUtils = require 'path'

{log} = Neft

PACKAGE_NAME = 'io.neft.tests'
PROJECT_CWD = './build/macos'
LOG_RE = /^.*io\.neft\.mac\[[0-9:]+\]\s\[([A-Z]+)\]\s(.+)$/gm
REALPATH = fs.realpathSync '.'

buildProject = (env) ->
    childProcess.execSync "xcodebuild", cwd: PROJECT_CWD

launchProject = (env, logsReader, callback) ->
    mainErr = null
    cmd = """
        build/Release/io.neft.mac.app/Contents/MacOS/io.neft.mac
    """
    appProcess = childProcess.exec cmd, cwd: PROJECT_CWD
    appProcess.stderr.on 'data', (data) ->
        LOG_RE.lastIndex = 0
        dataStr = String data
        while match = LOG_RE.exec(dataStr)
            [_, level, msg] = match
            logsReader.log msg
        if logsReader.terminated
            appProcess.kill()
    appProcess.on 'exit', ->
        unless logsReader.terminated
            mainErr ?= "MacOS tests terminated before all tests ended"
        callback mainErr or logsReader.error

exports.getName = (env) ->
    "MacOS tests"

exports.run = (env, logsReader, callback) ->
    logsReader.log "Building project"
    try
        buildProject env
    catch err
        log.debug String err.stdout
        return callback new Error "Cannot build MacOS project"

    logsReader.log "Running tests"
    launchProject env, logsReader, callback
    return
