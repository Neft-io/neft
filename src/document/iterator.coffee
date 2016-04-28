'use strict'

utils = require 'src/utils'
assert = require 'src/assert'
List = require 'src/list'
log = require 'src/log'

{isArray} = Array

assert = assert.scope 'View.Iterator'
log = log.scope 'View', 'Iterator'

module.exports = (File) -> class Iterator
	@__name__ = 'Iterator'
	@__path__ = 'File.Iterator'

	@HTML_ATTR = "#{File.HTML_NS}:each"

	JSON_CTOR_ID = @JSON_CTOR_ID = File.JSON_CTORS.push(Iterator) - 1

	i = 1
	JSON_NAME = i++
	JSON_NODE = i++
	JSON_TEXT = i++
	JSON_ARGS_LENGTH = @JSON_ARGS_LENGTH = i

	@_fromJSON = (file, arr, obj) ->
		unless obj
			node = file.node.getChildByAccessPath arr[JSON_NODE]
			obj = new Iterator file, node, arr[JSON_NAME]
		obj.text = arr[JSON_TEXT]
		obj

	attrsChangeListener = (name) ->
		if @file.isRendered and name is 'neft:each'
			@update()

	visibilityChangeListener = (oldVal) ->
		if @file.isRendered and oldVal is false and not @node.data
			@update()

	constructor: (@file, @node, @name) ->
		assert.instanceOf @file, File
		assert.instanceOf @node, File.Element
		assert.isString @name
		assert.notLengthOf @name, 0

		@usedFragments = []
		@text = ''
		@data = null
		@isRendered = false

		@node.onAttrsChange attrsChangeListener, @
		@node.onVisibleChange visibilityChangeListener, @

		`//<development>`
		if @constructor is Iterator
			Object.preventExtensions @
		`//</development>`

	render: ->
		unless @node.visible
			return

		each = @node.attrs[Iterator.HTML_ATTR]

		# stop if nothing changed
		if each is @data
			return

		# stop if no data found
		if not isArray(each) and not (each instanceof List)
			# log.warn "Data is not an array nor List in '#{@text}':\n#{each}"
			return

		# set as data
		@data = array = each

		# listen on changes
		if each instanceof List
			each.onChange @updateItem, @
			each.onInsert @insertItem, @
			each.onPop @popItem, @

		# add items
		for _, i in array
			@insertItem i

		@isRendered = true

		null

	revert: ->
		{data} = @

		if data
			@clearData()

			if data instanceof List
				data.onChange.disconnect @updateItem, @
				data.onInsert.disconnect @insertItem, @
				data.onPop.disconnect @popItem, @

		@data = null
		@isRendered = false

	update: ->
		@revert()
		@render()

	clearData: ->
		assert.isObject @data

		while length = @usedFragments.length
			@popItem length - 1

		@

	updateItem: (elem, i) ->
		unless i?
			i = elem

		assert.isObject @data
		assert.isInteger i

		@popItem i
		@insertItem i

		@

	insertItem: (elem, i) ->
		unless i?
			i = elem

		assert.isObject @data
		assert.isInteger i

		{data} = @

		usedFragment = File.factory @name
		@usedFragments.splice i, 0, usedFragment

		each = data
		item = data[i]

		# replace
		newChild = usedFragment.node
		newChild.parent = @node
		newChild.index = i

		# render fragment
		newChild.attrs.set 'each', each
		newChild.attrs.set 'index', i
		newChild.attrs.set 'item', item
		usedFragment.storage ?= @file.storage
		usedFragment.render @file.inputAttrs, @file.scope, @

		# signal
		usedFragment.onReplaceByUse.emit @
		File.emitNodeSignal usedFragment, 'neft:onReplaceByUse', @

		@

	popItem: (elem, i) ->
		unless i?
			i = elem

		assert.isObject @data
		assert.isInteger i

		@node.children[i].parent = undefined

		usedFragment = @usedFragments[i]
		if usedFragment.storage is @file.storage
			usedFragment.storage = null
		usedFragment.revert().destroy()
		@usedFragments.splice i, 1

		@

	clone: (original, file) ->
		node = original.node.getCopiedElement @node, file.node

		new Iterator file, node, @name

	toJSON: (key, arr) ->
		unless arr
			arr = new Array JSON_ARGS_LENGTH
			arr[0] = JSON_CTOR_ID
		arr[JSON_NAME] = @name
		arr[JSON_NODE] = @node.getAccessPath @file.node
		arr[JSON_TEXT] = @text
		arr