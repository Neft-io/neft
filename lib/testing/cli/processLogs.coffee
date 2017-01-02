'use strict'

logger = require '../logger'

{log} = Neft

PROCESS_LOG_PREFIX = '[PROCESS] '
SCREENSHOT_TEST_PREFIX = '[SCREENSHOT TEST] '

getLoggerLog = (log) ->
    if log.indexOf(logger.TEST_PREFIX) is 0
        log.slice logger.TEST_PREFIX.length

exports.LogsReader = class LogsReader
    constructor: ->
        @error = null
        @terminated = false
    log: (data) ->
        msg = String(data).trim()
        unless msg
            return
        if msg.indexOf('\n') >= 0
            return msg.split('\n').forEach @log, @
        unless content = getLoggerLog(msg)
            log PROCESS_LOG_PREFIX + msg
        else if content.indexOf(logger.ERROR) is 0
            errMsg = content.slice logger.ERROR.length
            errMsg = decodeURIComponent errMsg
            @error = new Error errMsg
            log.error logger.TEST_PREFIX + errMsg
        else if content is logger.SUCCESS
            log.ok content
            @terminated = true
        else if content is logger.FAILURE
            log.error content
            @terminated = true
            @error = new Error logger.FAILURE
        else
            log msg
