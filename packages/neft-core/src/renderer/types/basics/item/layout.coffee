'use strict'

utils = require '../../../../util'
signal = require '../../../../signal'
assert = require '../../../../assert'

module.exports = (Renderer, Impl, itemUtils, Item) -> (ctor, opts) -> class Layout extends itemUtils.DeepObject
    @__name__ = 'Layout'

    propertyName = opts?.propertyName or 'layout'

    itemUtils.defineProperty
        constructor: ctor
        name: propertyName
        valueConstructor: Layout

    constructor: (ref) ->
        super ref
        @_enabled = true
        @_fillWidth = false
        @_fillHeight = false

        Object.preventExtensions @

    itemUtils.defineProperty
        constructor: Layout
        name: 'enabled'
        defaultValue: true
        developmentSetter: (val) ->
            assert.isBoolean val
        namespace: propertyName
        parentConstructor: ctor

    itemUtils.defineProperty
        constructor: Layout
        name: 'fillWidth'
        defaultValue: false
        developmentSetter: (val) ->
            assert.isBoolean val
        namespace: propertyName
        parentConstructor: ctor

    itemUtils.defineProperty
        constructor: Layout
        name: 'fillHeight'
        defaultValue: false
        developmentSetter: (val) ->
            assert.isBoolean val
        namespace: propertyName
        parentConstructor: ctor