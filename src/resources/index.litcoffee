# Resources

    'use strict'

    utils = require 'src/utils'
    log = require 'src/log'
    assert = require 'src/assert'

    log = log.scope 'Resources'

# **Class** Resources

    module.exports = class Resources
        @__name__ = 'Resources'

        @Resources = @
        @Resource = require('./resource') @

        @URI = ///^(?:rsc|resource|resources)?:\/?\/?(.*?)(?:@([0-9p]+)x)?(?:\.[a-zA-Z]+)?(?:\#[a-zA-Z0-9]+)?$///

## *Resources* Resources.fromJSON(*String*|*Object* json)

        @fromJSON = (json) ->
            if typeof json is 'string'
                json = JSON.parse json
            assert.isObject json

            resources = new Resources
            for prop, val of json
                if prop is '__name__'
                    continue
                val = Resources[val.__name__].fromJSON val
                assert.notOk prop of resources, "Can't set '#{prop}' property in this resources object, because it's already defined"
                resources[prop] = val

            resources

## *Boolean* Resources.testUri(*String* uri)

        @testUri = (uri) ->
            assert.isString uri
            Resources.URI.test uri

        constructor: ->

## *Resource* Resources::getResource(*String* uri)

        getResource: (uri) ->
            if typeof uri is 'string'
                if match = Resources.URI.exec(uri)
                    uri = match[1]

            chunk = uri
            while chunk
                if r = @[chunk]
                    rest = uri.slice chunk.length + 1
                    if rest isnt '' and r instanceof Resources
                        r = r.getResource rest
                    return r
                chunk = chunk.slice 0, chunk.lastIndexOf('/')
            return

## *String* Resources::resolve(*String* uri, [*Object* request])

        resolve: (uri, req) ->
            rsc = @getResource uri
            if rsc instanceof Resources.Resource
                name = Resources.Resource.parseFileName uri
                name.file = ''
                if req?
                    for key, val of req
                        unless name[key]
                            name[key] = val
                path = rsc.resolve '', name
            path and @resolve(path) or path

## *Object* Resources::toJSON()

        toJSON: ->
            utils.merge
                __name__: @constructor.__name__
            , @

# Glossary

- [Resources](#class-resources)
