'use strict'

[utils, expect, Dict] = ['utils', 'expect', 'dict'].map require
log = require 'log'
coffee = require 'coffee-script' if utils.isNode

log = log.scope 'View', 'Input'

module.exports = (File) -> class Input

	{Element} = File

	@__name__ = 'Input'
	@__path__ = 'File.Input'

	RE = @RE = new RegExp '([^#]*)#{([^}]*)}([^#]*)', 'gm'
	VAR_RE = @VAR_RE = ///(^|\s|\[|:|\()([a-z_][\w:_]*)+(?!:)///gi
	CONSTANT_VARS = @CONSTANT_VARS = ['undefined', 'false', 'true', 'null']

	cache = {}

	@getVal = do ->

		getFromElement = (elem, prop) ->
			if elem instanceof Element
				elem.attrs.get prop

		getFromObject = (obj, prop) ->
			if obj instanceof Dict
				obj.get prop
			else if obj
				obj[prop]

		(file, prop) ->
			if file.source
				v = getFromElement file.source.node, prop
				v ?= getFromObject file.source.storage, prop
			v ?= getFromObject file.storage, prop

			v

	@get = (input, prop) ->
		v = Input.getVal input.self, prop

		# realtime traces
		if v instanceof Dict and not input.traces[v.__hash__]
			input.trace v

		v

	@getStoragesArray = do (arr = []) -> (file) ->
		expect(file).toBe.any File

		arr[0] = file.source?.node
		arr[1] = file.source?.storage
		arr[2] = file.storage

		arr

	@fromAssembled = (input) ->
		input._func = cache[input.func] ?= new Function 'file', 'get', input.func

	constructor: (@node, @text) ->
		expect(node).toBe.any File.Element
		expect(text).toBe.truthy().string()

		# build toString()
		func = ''
		RE.lastIndex = 0
		while (match = RE.exec text) isnt null

			# parse prop
			prop = match[2].replace VAR_RE, (_, prefix, elem) ->
				if prefix.trim() or not utils.has CONSTANT_VARS, elem
					str = "get(file, '#{utils.addSlashes elem}')"
				"#{prefix}#{str}"

			# add into func string
			if match[1] then func += "'#{utils.addSlashes match[1]}' + "
			func += "#{prop} + "
			if match[3] then func += "'#{utils.addSlashes match[3]}' + "

		func = 'return ' + func.slice 0, -3
		@func = utils.tryFunction coffee.compile, coffee, [func, bare: true], func

		Input.fromAssembled @

	_func: null

	self: null
	node: null
	text: ''
	func: ''
	traces: null
	updatePending: false

	_onChanged: (prop) ->
		return if @updatePending

		setImmediate @update
		@updatePending = false

	_onAttrChanged: (e) ->
		@_onChanged e.name

	trace: (dict) ->
		expect(dict).toBe.any Dict
		expect().some().keys(@traces).not().toBe dict.__hash__

		dict.onChanged @_onChanged
		@traces[dict.__hash__] = dict

	render: ->
		for storage in Input.getStoragesArray @self
			if storage instanceof Element
				storage.on 'attrChanged', @_onAttrChanged
			else if storage instanceof Dict
				@trace storage
		
		@update()

	revert: ->
		for storage in Input.getStoragesArray @self
			if storage instanceof Element
				storage.off 'attrChanged', @_onAttrChanged

		for hash, dict of @traces
			dict.onChanged.disconnect @_onChanged
			delete @traces[hash]

		null

	update: ->
		@updatePending = false

	toString: do ->

		callFunc = ->
			@_func @, Input.get

		->
			try
				callFunc.call @
			catch err
				log.warn "`#{@text}` variable is skipped due to an error;\n#{err}"

	clone: (original, self) ->

		clone = Object.create @

		clone.clone = undefined
		clone.self = self
		clone.node = original.node.getCopiedElement @node, self.node
		clone.traces = {}
		clone.update = => @update.call clone
		clone._onAttrChanged = (arg1) => @_onAttrChanged.call clone, arg1
		clone._onChanged = (arg1) => @_onChanged.call clone, arg1

		clone

	@Text = require('./input/text.coffee') File, @
	@Attr = require('./input/attr.coffee') File, @
