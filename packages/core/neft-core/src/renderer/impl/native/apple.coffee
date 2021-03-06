utils = require '../../../util'
assert = require '../../../assert'

nativeActions = require '../../../native/actions'
nativeBridge = require '../../../native/bridge'

module.exports = (impl) ->
    Types: {}
    bridge: do ->
        itemsById = new Array 20000 # 20k

        lastId = 0

        inActions: nativeActions.in
        outActions: nativeActions.out
        listen: nativeBridge.addActionListener
        getId: (item) ->
            assert.instanceOf item, impl.Renderer.Item
            itemsById[lastId] = item
            lastId++
        getItemFromReader: (reader) ->
            itemsById[reader.integers[reader.integersIndex++]]
        pushAction: nativeBridge.pushAction
        pushItem: (val) ->
            if val isnt null
                assert.instanceOf val, impl.Renderer.Item
            nativeBridge.pushInteger if val isnt null then val._impl.id else -1
            return
        pushBoolean: nativeBridge.pushBoolean
        pushInteger: nativeBridge.pushInteger
        pushFloat: nativeBridge.pushFloat
        pushString: nativeBridge.pushString
