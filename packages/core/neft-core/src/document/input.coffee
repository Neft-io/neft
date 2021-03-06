'use strict'

utils = require '../util'
assert = require '../assert'
log = require '../log'
{SignalsEmitter} = require '../signal'
eventLoop = require '../event-loop'
Binding = require '../binding'

assert = assert.scope 'View.Input'
log = log.scope 'View', 'Input'

class DocumentBinding extends Binding
    @New = (binding, input, target) ->
        target ?= new DocumentBinding binding, input
        Binding.New binding, input.target, target

    constructor: (binding, @input) ->
        super binding, @input.target

    getItemById: (item) ->
        if item is 'this'
            @ctx

    onError: (err) ->
        if process.env.NODE_ENV isnt 'production'
            log.error "Failed `#{@input.text}` binding in file `#{@input.document.path}`: `#{err}`"
        return

    update: ->
        # disable updates for reverted files
        if not @input.isRendered
            return
        eventLoop.lock()
        super()
        eventLoop.release()
        return

    getValue: ->
        @input.getValue()

    setValue: (val) ->
        @input.setValue val

module.exports = class Input extends SignalsEmitter
    initBindingConfig = (cfg) ->
        cfg.func ?= new Function 'self', cfg.body
        cfg.tree ?= [cfg.func, cfg.connections]
        return

    constructor: (@document, element, @interpolation, @text) ->
        super()

        @element = @document.element.getChildByAccessPath(element)
        @isRendered = false
        @target = null
        @binding = null

        initBindingConfig @interpolation

    render: ->
        assert.isNotDefined @binding
        @target = @document.exported
        @binding = DocumentBinding.New @interpolation.tree, @
        @isRendered = true
        @binding.update()
        return

    revert: ->
        @binding.destroy()
        @binding = null
        @isRendered = false
        return
