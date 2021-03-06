# Native

    'use strict'

    util = require '../../../util'
    log = require '../../../log'
    assert = require '../../../assert'
    colorUtils = require '../../utils/color'
    Resources = require '../../../resources'

    IS_NATIVE = process.env.NEFT_NATIVE
    if process.env.NEFT_NATIVE
        {callNativeFunction, onNativeEvent} = require '../../../native/handler'

    module.exports = (Renderer, Impl, itemUtils) ->

        class Native extends Renderer.Item
            @__name__ = 'Native'

## *Native* Native.New([*Object* options])

            @New = (opts) ->
                item = new @
                itemUtils.Object.initialize item, opts
                @Initialize? item
                item

## Native.defineProperty(*Object* config)

Defines new property with the given name.

For each property, signal `onXYZChange` is created,
where `XYZ` is the given name.

`config` parameter must be an object with specified keys:
- `enabled` - whether it's supported on current platform,
- `name` - name of the property,
- `type` - type of predefined condifuration described below,
- `defaultValue`,
- `setter`,
- `getter`,
- `developmentSetter`
- `implementationValue` - function returning value passed to the implementation.

### Predefined types

            PROPERTY_TYPES = Object.create null

#### text

            PROPERTY_TYPES.text = ->
                defaultValue: ''
                implementationValue: (val) -> String(val)

#### number

            PROPERTY_TYPES.number = ->
                defaultValue: 0
                implementationValue: (val) -> parseFloat(val) || 0

#### boolean

            PROPERTY_TYPES.boolean = ->
                defaultValue: false
                implementationValue: (val) -> Boolean(val)

#### resource

            PROPERTY_TYPES.resource = (config) ->
                defaultValue: ''
                implementationValue: do ->
                    RESOURCE_REQUEST =
                        resolution: 1
                    requestAnimationFrame? ->
                        RESOURCE_REQUEST.resolution = Renderer.device.pixelRatio
                    getResourceResolutionByPath = (rsc, path) ->
                        for format in rsc.formats
                            paths = rsc.paths[format]
                            if not paths
                                continue
                            for resolution of paths
                                if paths[resolution] is path
                                    return parseFloat(resolution)
                        return 1
                    (val) ->
                        val = String(val)
                        unless Resources.testUri(val)
                            return val
                        resource = Impl.resources?.getResource(val)
                        if resource
                            path = resource.resolve RESOURCE_REQUEST
                            config.onResolutionChange?.call @, getResourceResolutionByPath(resource, path)
                            return path
                        else
                            log.warn("Unknown resource given `#{val}`")
                            return ''

#### color

            PROPERTY_TYPES.color = (config) ->
                defaultValue: ''
                implementationValue: do ->
                    RESOURCE_REQUEST =
                        property: 'color'
                    (val) ->
                        val = String(val)
                        val = Impl.resources?.resolve(val, RESOURCE_REQUEST) or val
                        if IS_NATIVE
                            if val?
                                colorUtils.toRGBAHex val, config.defaultValue
                            else
                                null
                        else
                            val

#### item

            PROPERTY_TYPES.item = (config) ->
                defaultValue: null
                implementationValue: (val) ->
                    if not (val instanceof Renderer.Item)
                        return null
                    if IS_NATIVE
                        if val?
                            val._impl.id
                        else
                            null
                    else
                        val

            @defineProperty = (config) ->
                itemName = @__name__
                properties = @_properties ?= []
                config = util.clone config

                assert.isObject config, '''
                    NativeItem.defineProperty config parameter must be an object
                '''
                assert.isString config.name, '''
                    NativeItem property name must be a string
                '''
                assert.isNotDefined properties[config.name], """
                    Property #{config.name} is already defined
                """
                assert.isDefined PROPERTY_TYPES[config.type], """
                    Unknown property type #{config.type}
                """ if config.type

                # type
                if typeConfigFunc = PROPERTY_TYPES[config.type]
                    typeConfig = typeConfigFunc(config)
                    for key, val of typeConfig
                        if key not of config
                            config[key] = val

                # constructor
                config.constructor = @

                # internalName
                config.internalName = itemUtils.getPropInternalName config.name

                # implementation
                config.implementation = do ->
                    if config.enabled is false
                        return util.NOP

                    ctorName = util.capitalize itemName
                    name = util.capitalize config.name
                    if IS_NATIVE
                        funcName = "rendererSet#{ctorName}#{name}"
                        (val) ->
                            callNativeFunction funcName, [@_impl.id, val]
                    else
                        funcName = "set#{ctorName}#{name}"
                        (val) ->
                            Impl[funcName]?.call @, val

                # save
                properties.push config

                # create
                itemUtils.defineProperty config

            @setPropertyValue = itemUtils.setPropertyValue

## *Native* Native::constructor() : *Item*

            constructor: ->
                super()

                @_autoWidth = true
                @_autoHeight = true
                @_width = -1
                @_height = -1

                # save properties with default values
                if properties = @constructor._properties
                    for property in properties
                        @[property.internalName] = property.defaultValue

                return

            _width: -1
            getter = util.lookupGetter @::, 'width'
            itemWidthSetter = util.lookupSetter @::, 'width'
            util.defineProperty @::, 'width', null, getter,
                do (_super = itemWidthSetter) -> (val) ->
                    if @_autoWidth = val is -1
                        Impl.updateNativeSize.call @
                    else
                        _super.call @, val
                    return

            _height: -1
            getter = util.lookupGetter @::, 'height'
            itemHeightSetter = util.lookupSetter @::, 'height'
            util.defineProperty @::, 'height', null, getter,
                do (_super = itemHeightSetter) -> (val) ->
                    if @_autoHeight = val is -1
                        Impl.updateNativeSize.call @
                    else
                        _super.call @, val
                    return

## Native::set(*String* propName, *Any* val)

            set: (name, val) ->
                assert.isString name, "NativeItem.set name must be a string, but #{name} given"

                ctorName = util.capitalize @constructor.__name__
                id = @_impl.id
                name = util.capitalize name

                if IS_NATIVE
                    funcName = "rendererSet#{ctorName}#{name}"
                    callNativeFunction funcName, [id, val]
                else
                    funcName = "set#{ctorName}#{name}"
                    Impl[funcName]?.call @, val
                return

## Native::call(*String* funcName, *Any* args...)

            call: (name, args...) ->
                assert.isString name, "NativeItem.call name must be a string, but #{name} given"

                ctorName = util.capitalize @constructor.__name__
                id = @_impl.id
                name = util.capitalize name

                if IS_NATIVE
                    funcName = "rendererCall#{ctorName}#{name}"
                    callArgs = [funcName, [id, args...]]
                    callNativeFunction callArgs...
                else
                    funcName = "call#{ctorName}#{name}"
                    Impl[funcName]?.apply @, args
                return

## Native::on(*String* eventName, *Function* listener)

            # nativeEventName -> item id -> [item, listeners...]
            eventListeners = Object.create null

            createNativeEventListener = (listeners, eventName) -> (id) ->
                unless itemListeners = listeners[id]
                    log.warn "Got a native event '#{eventName}' for an item which " +
                        "didn't register a listener on this event; check if you " +
                        "properly call 'on()' method with a signal listener"
                    return

                length = arguments.length
                args = new Array length - 1
                for i in [0...length - 1] by 1
                    args[i] = arguments[i + 1]

                item = itemListeners[0]
                for i in [1...itemListeners.length] by 1
                    itemListeners[i].apply item, args

                return

            on: (name, func) ->
                assert.isString name, "NativeItem.on name must be a string, but #{name} given"
                assert.isFunction func, """
                    NativeItem.on listener must be a function, but #{func} given
                """

                name = util.capitalize name

                if IS_NATIVE
                    ctorName = util.capitalize @constructor.__name__
                    eventName = "rendererOn#{ctorName}#{name}"

                    unless listeners = eventListeners[eventName]
                        listeners = eventListeners[eventName] = Object.create(null)
                        onNativeEvent eventName, createNativeEventListener(listeners, eventName)

                    itemListeners = listeners[@_impl.id] ?= [@]
                    itemListeners.push func
                else
                    eventName = "on#{name}"
                    @_impl[eventName]?.connect func, @
                return

        Native
