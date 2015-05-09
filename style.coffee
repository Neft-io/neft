'use strict'

assert = require 'assert'
utils = require 'utils'
signal = require 'signal'
log = require 'log'
Renderer = require 'renderer'

log = log.scope 'Styles'

module.exports = (File, data) -> class Style
	{windowStyle, styles} = data

	@__name__ = 'Style'
	@__path__ = 'File.Style'

	listenTextRec = (style, node=style.node) ->
		assert.instanceOf style, Style
		assert.instanceOf node, File.Element

		if 'onTextChanged' of node
			style.textWatchingNodes.push node
			node.onTextChanged textChangedListener, style

		if node.children
			for child in node.children
				listenTextRec style, child

		return

	visibilityChangedListener = ->
		if @file.isRendered
			@updateVisibility()

	textChangedListener = ->
		if @file.isRendered
			@updateText()

	attrsChangedListener = (e) ->
		if e.name is 'neft:style'
			@reloadItem()
			if @file.isRendered
				@render()
				@findItemParent()
		else if e.name is 'href' and @isLink()
			@item?.linkUri = @getLinkUri()

		if @file.isRendered
			return unless @attrs?.hasOwnProperty(e.name)
			value = @node.attrs.get e.name
			if @file.funcs?.hasOwnProperty value
				log.warn "Dynamic listening on Renderer events is not supported"
				return
			@setAttr e.name, value

	reloadItemsRecursively = (style) ->
		style.reloadItem()

		for child in style.children
			reloadItemsRecursively child

		return

	constructor: ->
		@file = null
		@node = null
		@attrs = null
		@parent = null
		@isScope = false
		@isAutoParent = false
		@item = null
		@scope = null
		@children = []
		@textWatchingNodes = []
		@visible = true
		@attrListeners = []
		@isTextSet = false
		@classes = null

		Object.preventExtensions @

	render: ->
		for child in @children
			child.render()

		unless @item
			return

		# save classes
		if classes = @item._classes
			unless utils.isEqual(classes.items(), @classes)
				@classes = utils.clone(classes.items())

		if 'text' of @item or (@item.$ isnt null and 'text' of @item.$) or @item.label?
			@updateText()

		@item.document.node = @node
		@updateVisibility()
		
		for name of @attrs
			val = @node.attrs.get name
			@setAttr name, val
		return

	revert: ->
		unless @item
			return

		if @isAutoParent
			if @isScope
				@item.document.hide()
			@item.parent = null
		@item.document.node = null

		for child in @children
			child.revert()

		for name, val of @attrs
			@setAttr name, val

		{attrListeners} = @
		while attrListeners.length
			func = attrListeners.pop()
			name = attrListeners.pop()
			obj = attrListeners.pop()
			obj[name].disconnect func

		# restore classes
		if (classes = @item._classes) or @classes
			classes.clear()
			if @classes
				for name in @classes
					classes.append name
		return

	updateText: ->
		if @item.$? and 'text' of @item.$
			obj = @item.$
		else if 'text' of @item
			obj = @item
		else if @item.label? and 'text' of @item.label
			obj = @item.label

		if obj
			text = @node.stringifyChildren()

			if text.length > 0 or @isTextSet
				@isTextSet = true
				obj.text = text
		return

	updateVisibility: ->
		unless @item
			return

		visible = true
		tmpNode = @node
		loop
			visible = tmpNode.visible
			tmpNode = tmpNode.parent
			if not visible or not tmpNode or tmpNode.attrs.has('neft:style')
				break

		if @visible isnt visible
			@visible = visible
			@item.visible = visible
		return

	ATTR_PRIMITIVE_VALUES =
		__proto__: null
		'null': null
		'undefined': undefined
		'false': false
		'true': true

	setAttr: (name, val) ->
		assert.instanceOf @, Style
		assert.ok @attrs.hasOwnProperty(name)

		{funcs} = @file
		if funcs?.hasOwnProperty val
			val = funcs[val]

		name = name.slice 'neft:style:'.length
		props = name.split ':'
		obj = @item
		for prop, i in props
			if i is props.length - 1
				if val of ATTR_PRIMITIVE_VALUES
					val = ATTR_PRIMITIVE_VALUES[val]

				if val?
					switch typeof obj[prop]
						when 'number'
							val = parseFloat val
						when 'boolean'
							val = !!val
						when 'string'
							val = val+''

				unless prop of obj
					log.error "Can't set the '#{prop}' property, because this property doesn't exist"
					continue

				if typeof obj[prop] is 'function'
					obj[prop] val
					@attrListeners.push obj, prop, val
				else
					obj[prop] = val
			obj = obj[prop]
		return

	isLink: ->
		@node.name is 'a' and not @attrs?.hasOwnProperty('neft:style:onPointerClicked') and @node.attrs.get('href')?[0] isnt '#'

	getLinkUri: ->
		uri = @node.attrs.get('href') + ''
		`//<development>`
		unless ///^([a-z]+:|\/|\$\{)///.test uri
			log.warn "Relative link found `#{uri}`"
		`//</development>`
		uri

	reloadItem: ->
		unless utils.isClient
			return

		if @item and @isAutoParent
			@item.parent = null

		if @item
			while elem = @textWatchingNodes.pop()
				elem.onTextChanged.disconnect textChangedListener, @

		wasAutoParent = @isAutoParent

		id = @node.attrs.get 'neft:style'
		assert.isString id

		@isScope = ///^(styles|renderer)\:///.test id
		@item = null
		@scope = null
		@isAutoParent = false

		if @isScope
			if ///^renderer\:///.test id
				id = id.slice 'renderer:'.length
				id = utils.capitalize id
				@scope =
					mainItem: new Renderer[id]
					ids: {}
			else
				match = /^styles:(.+?)(?:\:(.+?))?$/.exec id
				[_, id, subid] = match
				@scope = styles[id]?.withStructure(subid)
			@isAutoParent = true
			if @scope
				@item = @scope.mainItem
			else
				unless File.Input.test id
					log.warn "Style file `#{id}` can't be find"
				return
		else
			parent = @parent
			loop
				scope = parent?.scope or windowStyle
				@item = scope.ids[id] or scope.mainItem.$?[id]
				@item ?= scope.styles(id)
				if @item or ((not parent or not (parent = parent.parent)) and scope is windowStyle)
					break

			unless @item
				unless File.Input.test id
					log.warn "Can't find `#{id}` style item"
				return

			@isAutoParent = !@item.parent

		@node.attrs.set 'neft:styleItem', @item

		if @isLink()
			@item.linkUri = @getLinkUri()

		# text changes
		if 'text' of @item or (@item.$ isnt null and 'text' of @item.$)
			listenTextRec @

		return;

	findItemParent: ->
		if @isAutoParent and @item
			tmpNode = @node
			while tmpNode = tmpNode.parent
				if item = tmpNode.attrs.get 'neft:styleItem'
					oldParent = @item.parent
					@item.parent = item
					if @isScope and not oldParent
						@item.document.show()
					break

			unless item
				@item.parent = null

		for child in @children
			child.findItemParent()

		return

	clone: (originalFile, file) ->
		clone = new Style

		clone.file = file
		clone.node = originalFile.node.getCopiedElement @node, file.node
		clone.attrs = @attrs

		# clone children
		for child in @children
			child = child.clone originalFile, file
			child.parent = clone
			clone.children.push child

		# reload items
		unless @parent
			reloadItemsRecursively clone

		# break for the abstract
		unless utils.isClient
			return clone

		# attr changes
		clone.node.onAttrsChanged attrsChangedListener, clone

		# visibility changes
		tmpNode = clone.node
		loop
			if tmpNode.attrs.has 'neft:if'
				tmpNode.onVisibilityChanged visibilityChangedListener, clone

			tmpNode = tmpNode.parent
			if not tmpNode or tmpNode.attrs.has('neft:style')
				break

		clone
