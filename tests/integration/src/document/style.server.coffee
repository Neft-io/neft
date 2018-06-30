'use strict'

fs = require 'fs'
os = require 'os'
{utils, Document, styles} = Neft
{createView, renderParse, uid} = require './utils.server'

styles {queries: []}

describe 'Document style', ->
    it 'is not rendered', ->
        view = createView '''
            <style></style>
        '''
        view = view.clone()

        renderParse view
        assert.is view.node.stringify(), ''

    it 'extends nodes by style items', ->
        view = createView '''
            <style>
                Item {
                    id: firstItem
                    query: 'test'
                }
            </style>
            <test />
        '''
        view = view.clone()

        renderParse view
        testNode = view.node.query 'test'
        assert.isNot testNode.props['n-style'].indexOf('firstItem'), -1

    it 'extends file node by main item if needed', ->
        view = createView '''
            <style>
                Item {
                    id: firstItem
                }
                Item {
                    query: 'abc'
                }
            </style>
        '''
        view = view.clone()

        renderParse view
        assert.ok view.node.props['n-style']

    it 'further declarations are merged', ->
        view = createView '''
            <style>
                Item {
                    id: firstItem
                    query: 'test'
                }
            </style>
            <style>
                Item {
                    id: mainItem
                }
            </style>
            <test />
        '''
        view = view.clone()

        renderParse view
        testNode = view.node.query 'test'
        assert.isNot testNode.props['n-style'].indexOf('firstItem'), -1
        assert.ok view.node.props['n-style']

    it 'can be placed in <n-component />', ->
        view = createView '''
            <n-component n-name="TestComp">
                <style>
                    Item {
                        id: firstItem
                        query: 'test'
                    }
                </style>
                <test />
            </n-component>
            <TestComp />
        '''
        view = view.clone()

        renderParse view
        testNode = view.node.query 'test'
        assert.isNot testNode.props['n-style'].indexOf('firstItem'), -1