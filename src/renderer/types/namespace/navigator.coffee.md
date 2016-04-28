Navigator @namespace
====================

	'use strict'

	utils = require 'src/utils'
	signal = require 'src/signal'
	assert = require 'src/assert'

	module.exports = (Renderer, Impl, itemUtils) ->
		class Navigator extends signal.Emitter

*Object* Navigator
------------------

			constructor: ->
				super()
				@_impl = bindings: null
				@_language = 'en'
				@_browser = true
				@_online = true

				Object.preventExtensions @

*Boolean* Navigator.language = 'en'
-----------------------------------

```nml
`Text {
`	text: "Your language: " + Navigator.language
`	font.pixelSize: 30
`}
```

			utils.defineProperty @::, 'language', null, ->
				@_language
			, null

*Boolean* Navigator.browser = true
----------------------------------

			utils.defineProperty @::, 'browser', null, ->
				@_browser
			, null

*Boolean* Navigator.native = false
----------------------------------

```style
`Text {
`	text: Navigator.native ? "Native" : "Browser"
`	font.pixelSize: 30
`}
```

			utils.defineProperty @::, 'native', null, ->
				not @_browser
			, null

*Boolean* Navigator.online = true
---------------------------------

## *Signal* Navigator.onOnlineChange(*Boolean* oldValue)

			itemUtils.defineProperty
				constructor: @
				name: 'online'
				developmentSetter: (val) ->
					assert.isBoolean val

		navigator = new Navigator
		Impl.initNavigatorNamespace?.call navigator
		navigator