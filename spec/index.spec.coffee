'use strict'

View = require('../index.coffee.md')

uid = do (i = 0) -> -> "index_#{i++}.html"

renderParse = (view, opts) ->

	view.render opts
	view.revert()
	view.render opts

describe 'View', ->

	it 'can be created using HTML', ->

		view = View.fromHTML uid(), '<b></b>'
		expect(view).toEqual jasmine.any View

	it 'clears got HTML', ->

		view = View.fromHTML uid(), '<!--comment--><div>   </div>'
		expect(view.node.stringify()).toBe '<div></div>'

	it 'finds units', ->

		view = View.fromHTML uid(), '<unit name="a"></unit>'
		expect(view.units).not.toEqual {}

	it 'finds elems', ->

		view = View.fromHTML uid(), '<unit name="a"><b></b></unit><a></a>'
		expect(view.elems).not.toEqual {}

	describe 'links', ->

		it 'finds properly', ->

			first = uid()
			View.fromHTML first, '<b></b>'
			view = View.fromHTML uid(), '<link rel="require" href="'+first+'">'
			expect(view.links.length).toBe 1

		describe 'shares units', ->

			it 'without namespace', ->

				first = 'namespace/'+uid()
				View.fromHTML first, '<unit name="a"></unit>'
				view = View.fromHTML uid(), '<link rel="require" href="'+first+'">'
				expect(Object.keys(view.units).length).toBe 1
				expect(Object.keys(view.units)[0]).toBe 'a'

			it 'with namespace', ->

				first = uid()
				View.fromHTML first, '<unit name="a"></unit>'
				view = View.fromHTML uid(), '<link rel="require" href="'+first+'" as="ns">'
				expect(Object.keys(view.units).length).toBe 1
				expect(Object.keys(view.units)[0]).toBe 'ns-a'

	it 'can be cloned and destroyed', ->

		view = View.fromHTML uid(), '<b></b>'
		clone = view.clone()

		expect(view).not.toBe clone
		expect(view.node).not.toBe clone.node
		expect(view.node.stringify()).toBe clone.node.stringify()

	it 'is pooled on factory', ->

		path = uid()
		view_start = View.fromHTML path, '<b></b>'
		view_factored = View.factory path
		view_factored.destroy()
		view_refactored = View.factory path

		expect(view_factored).not.toBe view_start
		expect(view_factored).toBe view_refactored

	it 'can replace elems by units', ->

		view = View.fromHTML uid(), '<unit name="a"><b></b></unit><a></a>'
		view = view.clone()

		renderParse view
		expect(view.node.stringify()).toBe '<unit><b></b></unit>'
		view.revert()
		expect(view.node.stringify()).toBe '<a></a>'

	it 'can replace elems by units in units', ->

		source = View.fromHTML uid(), '<unit name="b">1</unit><unit name="a"><b></b></unit><a></a>'
		view = source.clone();

		renderParse view
		expect(source.node.stringify()).toBe '<a></a>'
		expect(view.node.stringify()).toBe '<unit><unit>1</unit></unit>'

	it 'can render clone separately', ->

		source = View.fromHTML uid(), '<unit name="a"><b></b></unit><a></a>'
		view = source.clone()

		renderParse view
		expect(view.node.stringify()).toBe '<unit><b></b></unit>'
		expect(source.node.stringify()).toBe '<a></a>'

	it 'can put elem body in unit', ->

		source = View.fromHTML uid(), '
			<unit name="a"><source></source></unit>
			<a><b></b></a>'
		view = source.clone()

		renderParse view
		expect(source.node.stringify()).toBe '<a><b></b></a>'
		expect(view.node.stringify()).toBe '<unit><b></b></unit>'

describe 'View Storage', ->

	describe 'inputs are replaced', ->

		it 'by elem attrs', ->

			source = View.fromHTML uid(), '<unit name="a">#{x}</unit><a x="2"></a>'
			view = source.clone()

			renderParse view
			expect(source.node.stringify()).toBe '<a x="2"></a>'
			expect(view.node.stringify()).toBe '<unit>2</unit>'

		it 'by passed storage', ->

			source = View.fromHTML uid(), '<unit name="a">#{x}, #{b.a}</unit><a></a>'
			view = source.clone()

			renderParse view,
				storage: x: 2, b: {a: 1}
			expect(source.node.stringify()).toBe '<a></a>'
			expect(view.node.stringify()).toBe '<unit>2, 1</unit>'