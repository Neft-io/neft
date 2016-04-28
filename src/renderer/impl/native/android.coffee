'use strict'

assert = require 'src/assert'

nativeActions = require 'neft-native/actions'
nativeBridge = require 'neft-native/bridge'

module.exports = (impl) ->
	Types:
		Scrollable: require './level2/scrollable'

	bridge: do ->
		itemsById = new Array 20000 # 20k
		itemsById.push null

		lastId = 0

		vsync = ->
			requestAnimationFrame vsync
			nativeBridge.sendData()

		requestAnimationFrame vsync

		inActions: nativeActions.in
		outActions: nativeActions.out
		listen: nativeBridge.addActionListener
		getId: (item) ->
			assert.instanceOf item, impl.Renderer.Item
			itemsById[++lastId] = item
			lastId
		getItemFromReader: (reader) ->
			itemsById[reader.integers[reader.integersIndex++]]
		pushAction: nativeBridge.pushAction
		pushItem: (val) ->
			if val isnt null
				assert.instanceOf val, impl.Renderer.Item
			nativeBridge.pushInteger if val isnt null then val._impl.id else 0
			return
		pushBoolean: nativeBridge.pushBoolean
		pushInteger: nativeBridge.pushInteger
		pushFloat: nativeBridge.pushFloat
		pushString: nativeBridge.pushString