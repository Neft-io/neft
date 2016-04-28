Pointer @extension
==================

```nml
`Rectangle {
`	width: 100
`	height: 100
`	color: 'green'
`
`	Class {
`		when: target.pointer.hover
`		changes: {
`			color: 'red'
`		}
`	}
`}
```

	'use strict'

	utils = require 'src/utils'
	signal = require 'src/signal'
	assert = require 'src/assert'

	NOP = ->

	module.exports = (Renderer, Impl, itemUtils, Item) -> (ctor) -> class Pointer extends itemUtils.DeepObject
		@__name__ = 'Pointer'

		itemUtils.defineProperty
			constructor: ctor
			name: 'pointer'
			valueConstructor: Pointer

*Pointer* Pointer()
-------------------

Enables mouse and touch handling.

		constructor: (ref) ->
			super ref
			@_enabled = true
			@_draggable = false
			@_dragActive = false
			@_pressed = false
			@_hover = false
			@_pressedInitialized = false
			@_hoverInitialized = false

			Object.preventExtensions @

*Boolean* Pointer::enabled = true
---------------------------------

## *Signal* Pointer::onEnabledChange(*Boolean* oldValue)

		itemUtils.defineProperty
			constructor: Pointer
			name: 'enabled'
			defaultValue: true
			namespace: 'pointer'
			parentConstructor: ctor
			implementation: Impl.setItemPointerEnabled
			developmentSetter: (val) ->
				assert.isBoolean val

Hidden *Boolean* Pointer::draggable = false
-------------------------------------------

## Hidden *Signal* Pointer::onDraggableChange(*Boolean* oldValue)

		itemUtils.defineProperty
			constructor: Pointer
			name: 'draggable'
			defaultValue: false
			namespace: 'pointer'
			parentConstructor: ctor
			implementation: Impl.setItemPointerDraggable
			developmentSetter: (val) ->
				assert.isBoolean val

Hidden *Boolean* Pointer::dragActive = false
--------------------------------------------

## Hidden *Signal* Pointer::onDragActiveChange(*Boolean* oldValue)

		itemUtils.defineProperty
			constructor: Pointer
			name: 'dragActive'
			defaultValue: false
			namespace: 'pointer'
			parentConstructor: ctor
			implementation: Impl.setItemPointerDragActive
			developmentSetter: (val) ->
				assert.isBoolean val

*Signal* Pointer::onClick(*PointerEvent* event)
-----------------------------------------------

*Signal* Pointer::onPress(*PointerEvent* event)
-----------------------------------------------

*Signal* Pointer::onRelease(*PointerEvent* event)
-------------------------------------------------

*Signal* Pointer::onEnter(*PointerEvent* event)
-----------------------------------------------

*Signal* Pointer::onExit(*PointerEvent* event)
----------------------------------------------

*Signal* Pointer::onWheel(*PointerEvent* event)
-----------------------------------------------

*Signal* Pointer::onMove(*PointerEvent* event)
----------------------------------------------

Hidden *Signal* Pointer::onDragStart()
--------------------------------------

Hidden *Signal* Pointer::onDragEnd()
------------------------------------

Hidden *Signal* Pointer::onDragEnter()
--------------------------------------

Hidden *Signal* Pointer::onDragExit()
-------------------------------------

Hidden *Signal* Pointer::onDrop()
---------------------------------

		onLazySignalInitialized = (pointer, name) ->
			Impl.attachItemSignal.call pointer, 'pointer', name # TODO: send here an item
			return

		@SIGNALS = ['onClick', 'onPress', 'onRelease',
		            'onEnter', 'onExit', 'onWheel', 'onMove',
		            'onDragStart', 'onDragEnd',
		            'onDragEnter', 'onDragExit', 'onDrop']

		for signalName in @SIGNALS
			signal.Emitter.createSignal @, signalName, onLazySignalInitialized

*Boolean* Pointer::pressed = false
----------------------------------

Whether the pointer is currently pressed.

## *Signal* Pointer::onPressedChange(*Boolean* oldValue)

		intitializePressed = do ->
			onPress = (event) ->
				event.stopPropagation = false
				@pressed = true
			onRelease = ->
				@pressed = false

			(pointer) ->
				unless pointer._pressedInitialized
					pointer._pressedInitialized = true
					pointer.onPress onPress
					pointer.onRelease onRelease
				return

		itemUtils.defineProperty
			constructor: Pointer
			name: 'pressed'
			defaultValue: false
			namespace: 'pointer'
			parentConstructor: ctor
			signalInitializer: intitializePressed
			getter: (_super) -> ->
				intitializePressed @
				_super.call @

*Boolean* Pointer::hover = false
--------------------------------

Whether the pointer is currently under the item.

## *Signal* Pointer::onHoverChange(*Boolean* oldValue)

		initializeHover = do ->
			onEnter = ->
				@hover = true
			onExit = ->
				@hover = false

			(pointer) ->
				unless pointer._hoverInitialized
					pointer._hoverInitialized = true
					pointer.onEnter onEnter
					pointer.onExit onExit
				return

		itemUtils.defineProperty
			constructor: Pointer
			name: 'hover'
			defaultValue: false
			namespace: 'pointer'
			parentConstructor: ctor
			signalInitializer: initializeHover
			getter: (_super) -> ->
				initializeHover @
				_super.call @

*PointerEvent* PointerEvent() : *DevicePointerEvent*
----------------------------------------------------

Events order:
 1. Press
 2. Enter
 3. Move
 4. Move (not captured ensured items)
 5. Exit
 6. Release
 7. Click
 8. Release (not captured ensured items)

Stopped 'Enter' event will emit 'Move' event on this item.

Stopped 'Exit' event will emit 'Release' event on this item.

		@PointerEvent = class PointerEvent
			constructor: ->
				@_stopPropagation = true
				@_checkSiblings = false
				@_ensureRelease = true
				@_ensureMove = true
				Object.preventExtensions @

			@:: = Object.create Renderer.Device.pointer
			@::constructor = PointerEvent

*Boolean* PointerEvent::stopPropagation = false
-----------------------------------------------

Enable this property to stop further event propagation.

			utils.defineProperty @::, 'stopPropagation', null, ->
				@_stopPropagation
			, (val) ->
				assert.isBoolean val
				@_stopPropagation = val

*Boolean* PointerEvent::checkSiblings = false
---------------------------------------------

By default first deepest captured item will propagate this event only by his parents.

Change this value to test previous siblings as well.

			utils.defineProperty @::, 'checkSiblings', null, ->
				@_checkSiblings
			, (val) ->
				assert.isBoolean val
				@_checkSiblings = val

*Boolean* PointerEvent::ensureRelease = true
--------------------------------------------

Define whether pressed item should get 'onRelease' signal even
if the pointer has been released outside of this item.

Can be changed only in the 'onPress' signal.

			utils.defineProperty @::, 'ensureRelease', null, ->
				@_ensureRelease
			, (val) ->
				assert.isBoolean val
				@_ensureRelease = val

*Boolean* PointerEvent::ensureMove = true
-----------------------------------------

Define whether the pressed item should get 'onMove' signals even
if the pointer is outside of this item.

Can be changed only in the 'onPress' signal.

			utils.defineProperty @::, 'ensureMove', null, ->
				@_ensureMove
			, (val) ->
				assert.isBoolean val
				@_ensureMove = val

*PointerEvent* Pointer.event
----------------------------

		@event = new PointerEvent