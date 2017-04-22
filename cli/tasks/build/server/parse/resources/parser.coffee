'use strict'

fs = require 'fs'
pathUtils = require 'path'
yaml = require 'js-yaml'
mkdirp = require 'mkdirp'
Jimp = require 'jimp'

utils = require 'src/utils'
log = require 'src/log'
assert = require 'src/assert'
Resources = require 'src/resources'

log = log.scope 'Resources', 'Parser'

IMAGE_FORMATS =
    __proto__: null
    png: true
    jpg: true
    jpeg: true
    gif: true

DEFAULT_CONFIG =
    resolutions: [1]

stack = null
resizeStack = null

isResourcesPath = (path) ->
    /\/resources\.(?:json|yaml)$/.test path

toCamelCase = (str) ->
    words = str.split ' '
    r = words[0]
    for i in [1...words.length] by 1
        r += utils.capitalize words[i]
    r

resolutionToString = (resolution) ->
    if resolution is 1
        ''
    else
        '@' + (resolution + '').replace('.', 'p') + 'x'

getImageSize = do ->
    cache = Object.create null
    (path, mtime, callback) ->
        if cache[path] and mtime < Date.now() - 1000
            callback null, cache[path]
            return
        Jimp.read path, (err, image) ->
            if err
                return callback err
            cache[path] =
                width: image.bitmap.width
                height: image.bitmap.height
            callback null, cache[path]
            return
        return

supportImageResource = (path, rsc) ->
    # get size
    stats = fs.statSync path
    mtime = new Date stats.mtime

    resizeImage = (path, width, height, output, callback) ->
        Jimp.read path, (err, image) ->
            if err
                return callback err
            image.resize(width, height).write output, callback

    stack.add (callback) ->
        getImageSize path, mtime.valueOf(), (err, meta) ->
            if err
                return callback err

            name = pathUtils.basename path
            name = Resources.Resource.parseFileName name
            nameResolution = name.resolution ? 1

            width = Math.round meta.width / nameResolution
            height = Math.round meta.height / nameResolution

            rsc.width = width
            rsc.height = height

            for format in rsc.formats
                for resolution in rsc.resolutions
                    resPath = rsc.paths[format][resolution].slice(1)
                    if nameResolution isnt resolution
                        resPath = "build/#{resPath}"
                    shouldResize = not (exists = fs.existsSync(resPath))
                    shouldResize ||= new Date(fs.statSync(resPath).mtime) < mtime
                    if shouldResize
                        unless exists
                            mkdirp.sync pathUtils.dirname(resPath)
                        resizeStack.add resizeImage, null, [
                            path, width * resolution, height * resolution, resPath
                        ]
            callback()
            return

parseResourcesFolder = (path) ->
    throw new Error "Resources folder not implemented"

parseResourcesFile = (path, config) ->
    assert.isString path

    try
        file = require path
    catch err
        log.error "Error in file '#{path}'"
        throw err

    getValue file, path, config

parseResourcesObject = (obj, dirPath, config) ->
    assert.isPlainObject obj

    if obj.resources?
        config = utils.clone config
        utils.merge config, obj
        delete config.resources
    else
        obj = resources: obj

    if dirPath.indexOf('.') isnt -1
        dirPath = pathUtils.dirname dirPath

    if Array.isArray(obj.resources)
        parseResourcesArray obj.resources, dirPath, config
    else
        rscs = new Resources
        for prop, val of obj.resources
            rscs[prop] = getValue val, dirPath, config
        rscs

parseResourcesArray = (arr, dirPath, config) ->
    obj = utils.arrayToObject arr, (_, val) ->
        name = val.file or val
        if isResourcesPath(name)
            pathUtils.dirname(name)
        else
            Resources.Resource.parseFileName(name).file
    parseResourcesObject obj, dirPath, config

parseResourceFile = (path, config) ->
    dirPath = pathUtils.dirname path
    name = pathUtils.basename path
    name = Resources.Resource.parseFileName(name)
    name.resolution ?= 1

    unless fs.existsSync(path)
        msg = "File '#{path}' doesn't exist"
        unless name.format
            msg += "; format is missed"
        log.error msg
        return

    rsc = new Resources.Resource

    newConfig = {}
    for key, val of config
        newConfig[toCamelCase(key)] = utils.cloneDeep val

    utils.merge rsc, newConfig

    if newConfig.file
        rsc.file = name.file

    if rsc.resolutions
        unless utils.has(rsc.resolutions, name.resolution)
            rsc.resolutions.push name.resolution
    else
        rsc.resolutions = [name.resolution]

    # remove greater resolutions
    rsc.resolutions = rsc.resolutions.filter (elem) ->
        elem <= name.resolution

    if name.format
        if rsc.formats
            # log.warn "Multiple formats are not currently supported; '#{rsc.formats}' got"
            unless utils.has(rsc.formats, name.format)
                rsc.formats.push name.format
        else
            rsc.formats = [name.format]
    rsc.formats ?= []

    paths = rsc.paths = {}
    for format in rsc.formats
        formatPaths = paths[format] = {}
        for resolution in rsc.resolutions
            resPath = "/#{dirPath}/#{name.file}#{resolutionToString(resolution)}.#{format}"
            formatPaths[resolution] = resPath

    if IMAGE_FORMATS[name.format]
        supportImageResource path, rsc

    rsc

getValue = (val, dirPath, config) ->
    if utils.isObject(val)
        config = utils.clone config
        utils.merge config, val
        delete config.file
        delete config.resources

    if typeof val is 'string'
        path = pathUtils.join dirPath, val
        getFile path, config
    else if val?.file
        path = pathUtils.join dirPath, val.file
        getFile path, config
    else if Array.isArray(val)
        parseResourcesArray val, dirPath, config
    else if utils.isObject(val)
        if val.resources?
            if Array.isArray(val.resources)
                parseResourcesArray val.resources, dirPath, config
            else
                parseResourcesObject val.resources, dirPath, config
        else
            config = utils.clone config
            utils.merge config, val
            parseResourceFile dirPath, config

getFile = (path, config) ->
    try
        stat = fs.statSync path
    catch
        log.error "File '#{path}' doesn't exist"
        return
    possiblePaths = [
        pathUtils.join(path, './resources.json'),
        pathUtils.join(path, './resources.yaml'),
        pathUtils.join(path, './resources.yml'),
    ]

    if isResourcesPath(path)
        return parseResourcesFile path, config
    if stat.isDirectory()
        for possiblePath in possiblePaths
            if fs.existsSync(possiblePath)
                return parseResourcesFile possiblePath, config
        return parseResourcesFolder path, config
    return parseResourceFile path, config

exports.parse = (path, callback) ->
    stack = new utils.async.Stack
    resizeStack = new utils.async.Stack
    rscs = getFile path, DEFAULT_CONFIG
    stack.runAllSimultaneously (err) ->
        unless rscs instanceof Resources
            rscs = {}

        if not err and resizeStack.length
            resizeStack.runAllSimultaneously ->
                callback err, rscs
        else
            callback err, rscs
