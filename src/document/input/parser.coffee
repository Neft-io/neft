'use strict'

log = require 'src/log'
bindingParser = require 'src/binding/parser'

{BINDING_THIS_TO_TARGET_OPTS} = bindingParser

PARSER_OPTS =
    globalIdToThis:
        scope: true
    modifyBindingPart: (elem) ->
        # File context doesn't have signal on 'scope' change, so
        # we need to use short '${scope}' syntax which uses Input::scope.
        if elem[0] is 'this' and elem[1] is 'scope'
            elem.shift()
        return

isPublicId = (id) ->
    id in ['this', 'ids', 'attrs', 'scope']

shouldBeUpdatedOnCreate = (connection) ->
    [key] = connection
    if Array.isArray(key)
        shouldBeUpdatedOnCreate key
    else
        not (key in ['this', 'scope'])

exports.parse = (text) ->
    text = text.replace(/[\t\n]/gm, '')
    func = ""

    str = ''
    func = ''
    isString = isBlock = false
    blocks = 0
    innerBlocks = 0
    i = 0
    n = text.length
    while i < n
        charStr = text[i]
        if charStr is '$' and text[i+1] is '{'
            isBlock = true
            blocks += 1
            if str isnt '' or blocks > 1
                func += '"'+str+'" + '
            str = ''
            i++
        else if charStr is '{'
            innerBlocks += 1
            str += charStr
        else if charStr is '}'
            if innerBlocks > 0
                innerBlocks -= 1
                str += charStr
            else if isBlock
                func += "(#{str}) + "
                str = ''
            else
                log.error "Interpolated string parse error: '#{text}'"
                return
        else
            str += charStr
        i++

    if str is ''
        func = func.slice 0, -3
    else
        func += '"'+str+'"'

    parsed = bindingParser.parse func, isPublicId, BINDING_THIS_TO_TARGET_OPTS, PARSER_OPTS

    funcBody = "return #{parsed.hash}"

    try
        new Function funcBody
    catch err
        log.error "Can't parse string literal:\n#{text}\n#{err.message}"

    connections = eval "[#{parsed.connections}]"

    updateOnCreate = true
    for connection in connections
        unless updateOnCreate = shouldBeUpdatedOnCreate(connection)
            break

    func: null
    body: funcBody
    connections: connections
    updateOnCreate: updateOnCreate
