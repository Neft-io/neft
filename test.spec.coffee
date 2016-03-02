'use strict'

Dict = require './index'

describe 'ctor', ->
	it 'creates new dict', ->
		dict = Dict a: 1
		expect(dict).toEqual jasmine.any Dict

describe 'values can be accessed by keys', ->
	dict = Dict a: 1
	expect(dict.a).toBe 1
	expect(dict.abc).toBe undefined

describe 'set()', ->
	it 'set key value', ->
		dict = Dict()
		dict.set 'a', 1
		expect(dict.a).toBe 1

	it 'overrides keys', ->
		dict = Dict a: 1
		dict.set 'a', 2
		expect(dict.a).toBe 2

describe 'length', ->
	it 'returns amount of keys', ->
		dict = Dict a: 1, b: 2
		expect(dict.length).toBe 2

describe 'pop()', ->
	it 'removes key', ->
		dict = Dict a: 1
		dict.pop 'a'
		expect(dict.a).toBe undefined

describe 'keys()', ->
	it 'returns keys as an array', ->
		dict = Dict a: 1, b: 2
		expect(dict.keys()).toEqual ['a', 'b']

	it 'length is const', ->
		dict = Dict a: 1
		keys = dict.keys()
		dict.set 'b', 1
		expect(keys).toEqual ['a']
		expect(dict.keys()).toEqual ['a', 'b']

describe 'values()', ->
	it 'returns key values as an array', ->
		dict = Dict a: 1, b: 2
		expect(dict.values()).toEqual [1, 2]

	it 'length is const', ->
		dict = Dict a: 1
		values = dict.values()
		dict.set 'b', 2
		expect(values).toEqual [1]
		expect(dict.values()).toEqual [1, 2]

describe 'items()', ->
	it 'returns an array of key - value pairs', ->
		dict = Dict a: 1, b: 2
		expect(dict.items()).toEqual [['a', 1], ['b', 2]]

	it 'length is const', ->
		dict = Dict a: 1
		items = dict.items()
		dict.set 'b', 2
		expect(items).toEqual [['a', 1]]
		expect(dict.items()).toEqual [['a', 1], ['b', 2]]

describe 'json stringified', ->
	it 'is a reversed operation', ->
		dict = Dict a: 1, b: 2
		json = JSON.stringify dict
		dict2 = Dict.fromJSON json

		expect(dict2.items()).toEqual dict.items()
		expect(dict2).toEqual jasmine.any Dict

describe 'onChange signal', ->
	dict = listener = null
	ok = false
	args = items = null

	beforeEach ->
		ok = false
		args = []

		listener = (_args...) ->
			ok = true
			args.push _args
			items = dict.items()

	afterEach ->
		expect(ok).toBeTruthy()
		dict.onChange.disconnect listener

	it 'works with set() on new item', ->
		dict = Dict()
		dict.onChange listener
		dict.set 'a', 1
		expect(args).toEqual [['a', undefined]]
		expect(items).toEqual [['a', 1]]

	it 'works with set() on item change', ->
		dict = Dict a: 1
		dict.onChange listener
		dict.set 'a', 2
		expect(args).toEqual [['a', 1]]
		expect(items).toEqual [['a', 2]]

	it 'works with pop()', ->
		dict = Dict a: 1
		dict.onChange listener
		dict.pop 'a'
		expect(args).toEqual [['a', 1]]
		expect(items).toEqual []
