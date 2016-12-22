'use strict'

{Networking, utils} = Neft
{Impl} = Networking

Networking.Impl =
    init: ->

describe 'Networking', ->
    beforeEach ->
        @config =
            type: Networking.HTTP
            protocol: 'http'
            port: 3000
            host: 'localhost'
            language: 'en'

    describe 'option.allowAllOrigins', ->
        it 'is false by default', ->
            assert.is new Networking(@config).allowAllOrigins, false

            utils.merge @config, {allowAllOrigins: null}
            assert.is new Networking(@config).allowAllOrigins, false

        it 'can be set to true', ->
            utils.merge @config, {allowAllOrigins: true}
            assert.is new Networking(@config).allowAllOrigins, true
