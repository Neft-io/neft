'use strict'

[utils, expect] = ['utils', 'expect'].map require
coffee = require 'coffee-script' if utils.isNode

module.exports = (File) -> class Input

	{Element} = File

	@__name__ = 'Input'
	@__path__ = 'File.Input'

	RE = @RE = new RegExp '([^#]*)#{([^}]*)}([^#]*)', 'gm'
	VAR_RE = @VAR_RE = ///(^|\s|\[|:)([a-z]\w*)+///gi

	@Text = require('./input/text.coffee') File, @
	@Attr = require('./input/attr.coffee') File, @

	constructor: (@node, text) ->

		expect(node).toBe.any File.Element
		expect(text).toBe.truthy().string()

		# build toString()
		func = ''
		RE.lastIndex = 0
		while (match = RE.exec text) isnt null

			# parse prop
			prop = match[2].replace VAR_RE, (_, prefix, elem) ->
				str = "get(storages, '#{escape(elem)}')"
				"#{prefix}#{str}"

			# add into func string
			if match[1] then func += "'#{utils.addSlashes match[1]}' + "
			func += "#{prop} + "
			if match[3] then func += "'#{utils.addSlashes match[3]}' + "

		func = 'return ' + func.slice 0, -3
		@_func = func = coffee.compile func, bare: true

	_func: ''
	node: null

	get: (storages, prop) ->

		for storage in storages when storage

			# from attr
			if storage instanceof Element
				r = storage.attrs.get prop
				return r if r?
			else

				# from object
				r = storage[prop]
				return r if r?

		null

	parse: ->
		throw "`parse()` method not implemented"

	###
	Override `toString()` method on first call by `@_func` generated in the ctor.
	`utils.simplify()` currently does not support `fromJSON()` and `toJSON()` methods
	on the constructors, so it's the only way to support such functionality.
	###
	toString: do (cache = {}) -> (storages) ->
		{get} = @

		func = cache[@_func] ?= new Function 'get', 'storages', @_func

		toString = @toString = (storages) -> try func get, storages
		toString storages

	clone: (original, self) ->

		clone = Object.create @

		clone.clone = undefined
		clone.node = original.node.getCopiedElement @node, self.node

		clone