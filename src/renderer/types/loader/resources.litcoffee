# ResourcesLoader

Access it with:
```javascript
ResourcesLoader {}
```

Example:

```javascript
Item {
    ResourcesLoader {
        id: loader
        resources: app.resources
    }
    Text {
        text: 'Progress: ' + loader.progress * 100 + '%'
    }
}
```

    'use strict'

    assert = require 'src/assert'
    utils = require 'src/utils'
    log = require 'src/log'
    signal = require 'src/signal'
    Resources = require 'src/resources'

    log = log.scope 'Renderer', 'ResourcesLoader'

    module.exports = (Renderer, Impl, itemUtils) -> class ResourcesLoader extends itemUtils.FixedObject
        @__name__ = 'ResourcesLoader'
        @__path__ = 'Renderer.ResourcesLoader'

        getResources = (resources, target=[]) ->
            for key, val of resources when resources.hasOwnProperty(key)
                if val instanceof Resources.Resource
                    target.push val
                else
                    getResources val, target
            target

## *ResourcesLoader* ResourcesLoader.New([*Object* options])

        @New = (opts) ->
            item = new ResourcesLoader
            itemUtils.Object.initialize item, opts
            item

        constructor: ->
            super()
            @_resources = Renderer.resources
            @_progress = 0
            setImmediate =>
                if @_resources
                    @progress = 0
                    Impl.loadResources.call @, getResources(@_resources)

## *Resources* ResourcesLoader::resources

        utils.defineProperty @::, 'resources', null, ->
            @_resources
        , (val) ->
            if typeof val is 'string'
                val = Renderer.resources.getResource val
            assert.instanceOf val, Resources
            @_resources = val

## *Float* ResourcesLoader::progress = `0`

## *Signal* ResourcesLoaded::onProgressChange(*Float* oldValue)

        itemUtils.defineProperty
            constructor: @
            name: 'progress'
            developmentSetter: (val) ->
                assert.isFloat val
