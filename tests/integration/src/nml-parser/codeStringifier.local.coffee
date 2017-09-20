'use strict'

nmlParser = require 'src/nml-parser'

getObjectCode = (nml, path) ->
    ast = nmlParser.getAST nml
    nmlParser.getObjectCode ast: ast.objects[0], path: path

describe 'nml-parser', ->
    it 'parses Item', ->
        code = '''
            Item {}
        '''
        expected = '''
            _i0 = Item.New()
            _i0.onReady.emit()
            objects: {"_i0": _i0}
            item: _i0
        '''
        assert.is getObjectCode(code), expected

    it 'adds given file path', ->
        code = '''
            Item {}
        '''
        expected = '''
            _i0 = Item.New()
            _i0._path = "abc123"
            _i0.onReady.emit()
            objects: {"_i0": _i0}
            item: _i0
        '''
        assert.is getObjectCode(code, 'abc123'), expected

    it 'sets item id', ->
        code = '''
            Item {
                id: abc123
            }
        '''
        expected = '''
            abc123 = Item.New()
            _RendererObject.setOpts(abc123, {"id": "abc123"})
            abc123.onReady.emit()
            objects: {"abc123": abc123}
            item: abc123
        '''
        assert.is getObjectCode(code), expected

    it 'sets item properties', ->
        code = '''
            Item {
                property prop1
                property customProp
            }
        '''
        expected = '''
            _i0 = Item.New()
            _RendererObject.createProperty(_i0, "prop1")
            _RendererObject.createProperty(_i0, "customProp")
            _i0.onReady.emit()
            objects: {"_i0": _i0}
            item: _i0
        '''
        assert.is getObjectCode(code), expected

    it 'sets item signals', ->
        code = '''
            Item {
                signal signal1
                signal customSignal
            }
        '''
        expected = '''
            _i0 = Item.New()
            _RendererObject.createSignal(_i0, "signal1")
            _RendererObject.createSignal(_i0, "customSignal")
            _i0.onReady.emit()
            objects: {"_i0": _i0}
            item: _i0
        '''
        assert.is getObjectCode(code), expected

    it 'sets item attributes', ->
        code = '''
            Item {
                prop1: 123
            }
        '''
        expected = '''
            _i0 = Item.New()
            _RendererObject.setOpts(_i0, {"prop1": 123})
            _i0.onReady.emit()
            objects: {"_i0": _i0}
            item: _i0
        '''
        assert.is getObjectCode(code), expected

    it 'sets item object attributes', ->
        code = '''
            Item {
                prop1: Rectangle {
                    color: 'red'
                }
            }
        '''
        expected = '''
            _i1 = Item.New()
            _i0 = Rectangle.New()
            _RendererObject.setOpts(_i1, {"prop1": _RendererObject.setOpts(_i0, {"color": 'red'})})
            _i1.onReady.emit()
            _i0.onReady.emit()
            objects: {"_i1": _i1, "_i0": _i0}
            item: _i1
        '''
        assert.is getObjectCode(code), expected

    it 'parses Item with children', ->
        code = '''
            Item {
                Rectangle {
                    color: 'red'
                }
            }
        '''
        expected = '''
            _i1 = Item.New()
            _i0 = Rectangle.New()
            _RendererObject.setOpts(_i1, {"children": [_RendererObject.setOpts(_i0, {"color": 'red'})]})
            _i1.onReady.emit()
            _i0.onReady.emit()
            objects: {"_i1": _i1, "_i0": _i0}
            item: _i1
        '''
        assert.is getObjectCode(code), expected

    it 'sets item functions', ->
        code = '''
            Item {
                onEvent(param1, param2) {
                    return param1 + param2;
                }
            }
        '''
        expected = '''
            _i0 = Item.New()
            _RendererObject.setOpts(_i0, {"onEvent": `function(param1,param2){
                    return param1 + param2;
            }`})
            _i0.onReady.emit()
            objects: {"_i0": _i0}
            item: _i0
        '''
        assert.is getObjectCode(code), expected

    it 'compiles ES6 functions', ->
        code = '''
            Item {
                onEvent() {
                    const ab = 2;
                    return {ab};
                }
            }
        '''
        expected = '''
            _i0 = Item.New()
            _RendererObject.setOpts(_i0, {"onEvent": `function(){
                    var ab = 2;
                    return { ab: ab };
            }`})
            _i0.onReady.emit()
            objects: {"_i0": _i0}
            item: _i0
        '''
        assert.is getObjectCode(code), expected

    it 'sets item bindings', ->
        code = '''
            Item {
                width: child.width

                Rectangle {
                    id: child
                }
            }
        '''
        expected = '''
            _i0 = Item.New()
            child = Rectangle.New()
            _RendererObject.setOpts(_i0, {"width": [`function(){return child.width}`, [[child, 'width']]], \
            "children": [_RendererObject.setOpts(child, {"id": "child"})]})
            _i0.onReady.emit()
            child.onReady.emit()
            objects: {"_i0": _i0, "child": child}
            item: _i0
        '''
        assert.is getObjectCode(code), expected

    it 'sets item deep bindings', ->
        code = '''
            Class {
                changes: {
                    width: document.width
                }
            }
        '''
        expected = '''
            _i0 = Class.New()
            _RendererObject.setOpts(_i0, {"changes": {"width": [\
            `function(){return document.width}`, [[document, 'width']]]}})
            objects: {"_i0": _i0}
            item: _i0
        '''
        assert.is getObjectCode(code), expected

    it 'prefixes Renderer types in bindings', ->
        code = '''
            NumberAnimation {
                updateProperty: PropertyAnimation.ALWAYS
            }
        '''
        expected = '''
            _i0 = NumberAnimation.New()
            _RendererObject.setOpts(_i0, {"updateProperty": [`function(){\
            return Neft.Renderer.PropertyAnimation.ALWAYS}`, []]})
            objects: {"_i0": _i0}
            item: _i0
        '''
        assert.is getObjectCode(code), expected

    it 'sets item anchors', ->
        code = '''
            Item {
                anchors.left: previousSibling.horizontalCenter
            }
        '''
        expected = '''
            _i0 = Item.New()
            _RendererObject.setOpts(_i0, {"anchors.left": ["previousSibling","horizontalCenter"]})
            _i0.onReady.emit()
            objects: {"_i0": _i0}
            item: _i0
        '''
        assert.is getObjectCode(code), expected

    it 'parses conditions', ->
        code = '''
            Item {
                if (this.width > 50) {
                    height: document.width
                }
            }
        '''
        expected = '''
            _i0 = Item.New()
            _r0 = Class.New()
            _RendererObject.setOpts(_i0, {"children": [\
            _RendererObject.setOpts(_r0, {\
            "when": [`function(){return this.target.width > 50}`, \
            [[['this', 'target'], 'width']]], \
            "changes": {"height": [`function(){return document.width}`, [[document, 'width']]]}\
            })\
            ]})
            _i0.onReady.emit()
            objects: {"_i0": _i0, "_r0": _r0}
            item: _i0
        '''
        assert.is getObjectCode(code), expected

    it 'parses conditions returning value', ->
        code = '''
            Item {
                if (document.props.hover) {
                    height: 100
                }
            }
        '''
        expected = '''
            _i0 = Item.New()
            _r0 = Class.New()
            _RendererObject.setOpts(_i0, {"children": [\
            _RendererObject.setOpts(_r0, {\
            "when": [`function(){return document.props.hover}`, \
            [[[document, 'props'], 'hover']]], \
            "changes": {"height": 100}\
            })\
            ]})
            _i0.onReady.emit()
            objects: {"_i0": _i0, "_r0": _r0}
            item: _i0
        '''
        assert.is getObjectCode(code), expected

    it 'parses selects', ->
        code = '''
            Item {
                select ('a > b') {
                    color: 'red'
                }
            }
        '''
        expected = '''
            _i0 = Item.New()
            _r0 = Class.New()
            _RendererObject.setOpts(_i0, {"children": [\
            _RendererObject.setOpts(_r0, {\
            "document.query": 'a > b', \
            "changes": {"color": 'red'}\
            })\
            ]})
            _i0.onReady.emit()
            objects: {"_i0": _i0, "_r0": _r0}
            item: _i0
        '''
        assert.is getObjectCode(code), expected