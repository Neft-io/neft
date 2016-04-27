'use strict'

View = Neft?.Document or require '../index.coffee.md'
{describe, it} = require 'neft-unit'
assert = require 'neft-assert'
{createView, renderParse, uid} = require './utils'

describe 'neft:require', ->
	describe 'shares fragments', ->
		it 'without namespace', ->
			first = 'namespace'+uid()
			view1 = createView '<neft:fragment neft:name="a"></neft:fragment>', first
			view2 = createView '<neft:require href="'+first+'" />'

			assert.is Object.keys(view2.fragments).length, 1
			assert.is Object.keys(view2.fragments)[0], 'a'

		it 'with namespace', ->
			first = uid()
			view1 = createView '<neft:fragment neft:name="a"></neft:fragment>', first
			view2 = createView '<neft:require href="'+first+'" as="ns">'

			assert.is Object.keys(view2.fragments).length, 1
			assert.is Object.keys(view2.fragments)[0], 'ns:a'
