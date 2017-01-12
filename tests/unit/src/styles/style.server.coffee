'use strict'

{utils, Document, Renderer, styles} = Neft
{createView} = require '../document/utils.server'

{Element} = Document

testViews = []

render = (opts) ->
    doc = createView opts.html
    {path} = doc

    Style = styles
        styles: opts.styles or {}
        queries: opts.queries or {}
        windowStyle: opts.windowStyle or {objects: {}}

    for key, subfile of Document._files
        if key.indexOf(path) is 0
            testViews.push subfile
            Style.extendDocumentByStyles subfile

    clone = doc.render()
    clone.destroy()

    doc.render()

describe 'styles', ->
    describe 'n-style', ->
        it 'can be a Renderer.Item instance', ->
            # item = Renderer.Rectangle.New()
            # node = new Element.Tag
            # node.props['n-style'] = item
            # doc = render
            #   node: node

            # assert.is doc.styles.length, 1
            # assert.isDefined style = doc.styles[0]
            # assert.is style.item, item

        it "accepts 'renderer:' prefix", ->
            doc = render
                html: '<b n-style="renderer:Rectangle" />'

            assert.is doc.styles.length, 1
            assert.instanceOf (style = doc.styles[0]).item, Renderer.Rectangle

        it "accepts 'styles:file' syntax", ->
            doc = render
                html: '<b n-style="styles:file" />'
                styles:
                    file:
                        _main:
                            getComponent: ->
                                item: Renderer.Rectangle.New()

            assert.is doc.styles.length, 1
            assert.instanceOf (item = doc.styles[0].item), Renderer.Rectangle

        it "accepts 'styles:file:style' syntax", ->
            doc = render
                html: '<b n-style="styles:file:style" />'
                styles:
                    file:
                        style:
                            getComponent: ->
                                item: Renderer.Rectangle.New()

            assert.is doc.styles.length, 1
            assert.instanceOf (item = doc.styles[0].item), Renderer.Rectangle

        it "accepts 'styles:file:style:subid' syntax", ->
            doc = render
                html: '''<b n-style="styles:file:style">
                    <div n-style="renderer:Item">
                        <i n-style="styles:file:style:subid" />
                    </div>
                </b>'''
                styles:
                    file:
                        style:
                            getComponent: ->
                                item: Renderer.Rectangle.New()
                                objects:
                                    subid: Renderer.Text.New()

            bNode = doc.node.query 'b'
            iNode = doc.node.query 'i'

            assert.is doc.styles.length, 1
            assert.instanceOf bNode.style, Renderer.Rectangle
            assert.instanceOf iNode.style, Renderer.Text

        it "accepts 'styles:view:style:subid' syntax", ->
            doc = render
                html: '<b n-style="styles:view:style:subid" />'
                windowStyle:
                    objects:
                        subid: Renderer.Text.New()

            assert.is doc.styles.length, 1
            assert.instanceOf doc.styles[0].item, Renderer.Text

        it 'created style is accessible in node', ->
            doc = render
                html: '<b n-style="renderer:Item" />'

            assert.is (node = doc.styles[0].node).name, 'b'
            assert.instanceOf node.style, Renderer.Item

        it 'node is accessible in created style document', ->
            doc = render
                html: '<b n-style="renderer:Item" />'

            bNode = doc.node.query 'b'
            assert.is bNode.style.document.node, bNode

        it 'must be specify to create a style', ->
            doc = render
                html: '<b />'

            node = doc.node.query 'b'

            assert.is doc.styles.length, 0
            assert.isNotDefined node.style

    describe 'Renderer.Text::text', ->
        it 'is always equal of stringified node children', ->
            doc = render
                html: '<b n-style="renderer:Text">ab<i>c</i></b>'

            node = doc.node.query 'b'
            item = doc.styles[0].item

            assert.is item.text, node.stringifyChildren()

            node.children[0].text = '123'
            assert.is item.text, node.stringifyChildren()

        it 'is always equal of stringified visible node children', ->
            doc = render
                html: '''
                    <b n-style="renderer:Text">ab<i visible="false">c</i></b>
                '''

            bNode = doc.node.query 'b'
            iNode = doc.node.query 'i'
            item = doc.styles[0].item

            assert.is item.text, bNode.stringifyChildren()

            iNode.props.set 'visible', true
            assert.is item.text, bNode.stringifyChildren()

    describe 'Renderer.Item::$.text', ->
        it 'is always equal stringified node children', ->
            doc = render
                html: '<b n-style="styles:file">ab<i>c</i></b>'
                styles:
                    file:
                        _main:
                            getComponent: ->
                                item = Renderer.Item.New()
                                item.$.text = 'debug'
                                item: item

            node = doc.node.query 'b'
            item = doc.styles[0].item

            assert.is item.$.text, node.stringifyChildren()

            node.children[0].text = '123'
            assert.is item.$.text, node.stringifyChildren()

        it 'is more important than ::text property', ->
            doc = render
                html: '<b n-style="styles:file">ab<i>c</i></b>'
                styles:
                    file:
                        _main:
                            getComponent: ->
                                item = Renderer.Text.New()
                                item.$.text = 'debug'
                                item: item

            node = doc.node.query 'b'
            item = doc.styles[0].item

            assert.is item.text, ''
            assert.is item.$.text, node.stringifyChildren()

            node.children[0].text = '123'

            assert.is item.text, ''
            assert.is item.$.text, node.stringifyChildren()

    describe 'Element.Text', ->
        it 'is rendered as Renderer.Text', ->
            doc = render
                html: '<b>abc</b>'

            assert.is doc.styles.length, 1
            assert.instanceOf node = (style = doc.styles[0]).node, Element.Text
            assert.is node.text, 'abc'
            assert.instanceOf item = style.item, Renderer.Text

        it 'text is properly synchronized', ->
            doc = render
                html: '<b>abc</b>'

            node = doc.node.query '#text'
            item = doc.styles[0].item

            assert.is item.text, node.text

            node.text = '123'

            assert.is item.text, node.text

        it 'is not created if has a text parent', ->
            doc = render
                html: '<b n-style="styles:file">ab</b>'
                styles:
                    file:
                        _main:
                            getComponent: ->
                                item = Renderer.Text.New()
                                item: item

            node = doc.node.query 'b'
            textNode = node.query '#text'
            item = doc.styles[0].item

            assert.instanceOf item, Renderer.Text
            assert.isNotDefined textNode.style

    describe 'a[href]', ->
        it 'sets style linkUri', ->
            doc = render
                html: '<a href="/abc" n-style="renderer:Item"></a>'

            node = doc.node.query 'a'

            assert.is doc.styles.length, 1
            assert.instanceOf style = node.style, Renderer.Item
            assert.is style.linkUri, node.props.href

        it 'sets child node style linkUri', ->
            doc = render
                html: '<a href="/abc"><b n-style="renderer:Item" /></a>'

            aNode = doc.node.query 'a'
            bNode = doc.node.query 'b'

            assert.is doc.styles.length, 1
            assert.instanceOf style = bNode.style, Renderer.Item
            assert.is style.linkUri, aNode.props.href

        it "doesn't set child node style linkUri if the parent node is styled", ->
            doc = render
                html: '''<a href="/abc" n-style="renderer:Item">
                    <b n-style="renderer:Item" />
                </a>'''

            aNode = doc.node.query 'a'
            bNode = doc.node.query 'b'

            assert.is bNode.style.linkUri, ''

        it 'updates style linkUri on attr change', ->
            doc = render
                html: '<a href="/abc" n-style="renderer:Item"></a>'

            node = doc.node.query 'a'
            node.props.set 'href', '/123'

            assert.is node.style.linkUri, node.props.href

        it 'updates style linkUri on parent change', ->
            doc = render
                html: '<a href="/abc"><div /></a><b n-style="renderer:Item" />'

            aNode = doc.node.query 'a'
            divNode = doc.node.query 'div'
            bNode = doc.node.query 'b'

            assert.is bNode.style.linkUri, ''

            bNode.parent = divNode
            assert.is bNode.style.linkUri, aNode.props.href

            bNode.parent = null
            assert.is bNode.style.linkUri, ''

        it 'updates child style linkUri on attr change', ->
            doc = render
                html: '''
                    <a href="/abc"><div><b n-style="renderer:Item" /></div></a>
                '''

            aNode = doc.node.query 'a'
            bNode = doc.node.query 'b'

            aNode.props.set 'href', '/123'
            assert.is bNode.style.linkUri, aNode.props.href

        it 'updates n-each styles', ->
            test = ->
                for child in ulNode.children
                    assert.is child.query('#text').style?.linkUri, child.query('a').props.href
                return

            doc = render
                html: '''<ul n-each="[1,2]">
                    <a href="/${props.item}">${props.item}</a>
                </ul>'''

            ulNode = doc.node.query 'ul'

            test()

            ulNode.props.set 'n-each', [5, 6, 7]
            test()

    describe "'n-style:' attributes", ->
        it 'are set on a style item', ->
            doc = render
                html: '<b n-style="renderer:Item" n-style:x="50" />'

            {node, item} = doc.styles[0]

            assert.instanceOf item, Renderer.Item
            assert.is item.x, node.props['n-style:x']

        it 'on change are set on a style item', ->
            doc = render
                html: '<b n-style="renderer:Item" n-style:x="50" />'

            {node, item} = doc.styles[0]

            node.props.set 'style:x', 70
            assert.is item.x, node.props['n-style:x']

        it "'null' value is not set for non-object properties", ->
            doc = render
                html: '<b n-style="renderer:Item" n-style:x="null" />'

            {node, item} = doc.styles[0]

            assert.is item.x, 0

            node.props.set 'n-style:x', 4
            node.props.set 'n-style:x', null
            assert.is item.x, 4

    describe "'class' attribute", ->
        it 'sets item classes', ->
            doc = render
                html: '<b n-style="renderer:Item" class="a b c" />'

            {node, item} = doc.styles[0]

            assert.isEqual item.classes.toArray(), node.props.class.split(' ')

        it 'synchronizes item classes on add and remove', ->
            doc = render
                html: '<b n-style="renderer:Item" class="a b c" />'

            {node, item} = doc.styles[0]

            node.props.set 'class', 'g a c'
            assert.isEqual item.classes.toArray(), node.props.class.split(' ')

    describe 'Style item visible', ->
        it "is 'true' by default", ->
            doc = render
                html: '<b n-style="renderer:Item" />'

            assert.is doc.styles[0].item.visible, true

        it "is 'false' if the style node is invisible", ->
            doc = render
                html: '<b n-style="renderer:Item" visible="false" />'

            assert.is doc.styles[0].item.visible, false

        it "is 'false' if the style node comes invisible", ->
            doc = render
                html: '<b n-style="renderer:Item" />'

            node = doc.node.query 'b'

            node.visible = false
            assert.is doc.styles[0].item.visible, false

        it "is 'true' if the style node comes visible", ->
            doc = render
                html: '<b n-style="renderer:Item" visible="false" />'

            node = doc.node.query 'b'

            node.visible = true
            assert.is doc.styles[0].item.visible, true

        it "is 'false' if the not-styled node parent is invisible", ->
            doc = render
                html: '''<div visible="false">
                    <div><b n-style="renderer:Item" /></div>
                </div>'''

            assert.is doc.styles[0].item.visible, false

        it "is 'false' if the not-styled node parent comes invisible", ->
            doc = render
                html: """<div>
                    <div><b n-style="renderer:Item" /></div>
                </div>"""

            node = doc.node.query 'div'

            node.visible = false
            assert.is doc.styles[0].item.visible, false

        it "is 'true' if the styled node parent is invisible", ->
            doc = render
                html: """<div n-style="renderer:Rectangle" visible="false">
                    <div><b n-style="renderer:Item" /></div>
                </div>"""

            bNode = doc.node.query 'b'

            assert.is bNode.style.visible, true

        it "is 'true' if the styled node parent comes invisible", ->
            doc = render
                html: """<div n-style="renderer:Rectangle">
                    <div><b n-style="renderer:Item" /></div>
                </div>"""

            divNode = doc.node.query 'div'
            bNode = doc.node.query 'b'

            divNode.visible = false
            assert.is bNode.style.visible, true

    describe "Style item parent", ->
        it "refers to the first styled parent style", ->
            doc = render
                html: """<div n-style="renderer:Item">
                    <b n-style="renderer:Item" />
                </div>"""

            divNode = doc.node.query 'div'
            bNode = doc.node.query 'b'

            assert.is bNode.style.parent, divNode.style

        it "refers to the first styled parent style after the parent change", ->
            doc = render
                html: """<div n-style="renderer:Item">
                    <i />
                </div>
                <b n-style="renderer:Item" />"""

            divNode = doc.node.query 'div'
            iNode = doc.node.query 'i'
            bNode = doc.node.query 'b'

            bNode.parent = iNode
            assert.is bNode.style.parent, divNode.style

        it "is properly synchronized on 'use'", ->
            doc = render
                html: '''<component name="a">
                    <b n-style="renderer:Item" />
                    <i n-style="renderer:Item" />
                </component>
                <div n-style="renderer:Item">
                    <use component="a" />
                </div>'''

            divNode = doc.node.query 'div'
            bNode = doc.node.query 'b'
            iNode = doc.node.query 'i'

            assert.is bNode.style.parent, divNode.style
            assert.is iNode.style.parent, divNode.style

        it "doesn't change if the item has a parent", ->
            doc = render
                html: """<div n-style="renderer:Item"></div>
                <b n-style="styles:file:style" />"""
                styles:
                    file:
                        style:
                            getComponent: ->
                                parent = Renderer.Item.New()
                                item = Renderer.Item.New()
                                item.parent = parent

                                item: item

            divNode = doc.node.query 'div'
            bNode = doc.node.query 'b'

            bNode.parent = divNode
            assert.isDefined bNode.style.parent
            assert.isNot bNode.style.parent, divNode.style

    describe "Style item index", ->
        describe "is valid on", ->
            it "index change", ->
                doc = render
                    html: """<div n-style="renderer:Item">
                        <em n-style="renderer:Item" />
                        <b n-style="renderer:Item" />
                        <i n-style="renderer:Item" />
                    </div>"""

                divNode = doc.node.query 'div'
                emNode = doc.node.query 'em'
                bNode = doc.node.query 'b'
                iNode = doc.node.query 'i'

                iNode.index = 1
                assert.is iNode.style.previousSibling, emNode.style
                assert.is iNode.style.nextSibling, bNode.style

            it "parent change", ->
                doc = render
                    html: """<div n-style="renderer:Item">
                        <em />
                        <b n-style="renderer:Item" />
                    </div>
                    <i n-style="renderer:Item" />"""

                divNode = doc.node.query 'div'
                emNode = doc.node.query 'em'
                bNode = doc.node.query 'b'
                iNode = doc.node.query 'i'

                iNode.parent = emNode
                assert.is iNode.style.nextSibling, bNode.style

        it "is valid in n-each", ->
            test = ->
                childItem = divNode.style.children.firstChild
                for item in divNode.props['n-each']
                    assert.is childItem.text, item+''
                    childItem = childItem.nextSibling
                return

            doc = render
                html: """<div n-style="renderer:Item" n-each="[1,2,3]">
                    <b>${props.item}</b>
                </div>"""

            divNode = doc.node.query 'div'

            test()

            divNode.props.set 'n-each', [5,6,7,8]
            test()
            return

        it "is valid for fixed item parent", ->
            doc = render
                html: """<b n-style="styles:file:style">
                    <em n-style="renderer:Item" />
                    <i n-style="styles:file:style:subid" />
                </b>"""
                styles:
                    file:
                        style:
                            getComponent: ->
                                item = Renderer.Rectangle.New()
                                subid = Renderer.Text.New()
                                subid.parent = item

                                item: item
                                objects:
                                    subid: subid

            bNode = doc.node.query 'b'
            emNode = doc.node.query 'em'
            iNode = doc.node.query 'i'

            assert.is emNode.style.nextSibling, iNode.style

    it '', ->
        for view in testViews
            utils.clear view.styles
        return