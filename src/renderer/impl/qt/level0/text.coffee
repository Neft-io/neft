'use strict'

FONT_WEIGHT = [
    'Light',
    'Normal',
    'DemiBold',
    'Bold',
    'Black'
]

FONT_WEIGHT_LAST_INDEX = FONT_WEIGHT.length - 1

module.exports = (impl) ->
    {Item, Image} = impl.Types

    updatePending = false

    updateSize = ->
        data = @_impl
        {elem} = data

        updatePending = true

        if data.autoWidth
            @width = elem.contentWidth

        if data.autoHeight
            @height = elem.contentHeight

        updatePending = false

    onWidthChange = ->
        if not updatePending
            auto = @_impl.autoWidth = @width is 0
            @_impl.elem.wrapMode = if auto then Text.NoWrap else Text.Wrap
        if @_impl.autoWidth or @_impl.autoHeight
            updateSize.call @

    onHeightChange = ->
        if not updatePending
            @_impl.autoHeight = @height is 0
        if @_impl.autoWidth or @_impl.autoHeight
            updateSize.call @

    onLickActivated = (link) ->
        __location.append link

    onFontLoaded = (name) ->
        fontFamily = @_impl.fontFamily
        if name is fontFamily
            @_impl.elem.font.family = impl.fonts[fontFamily]
            impl.onFontLoaded.disconnect onFontLoaded, @
            @_impl.listensOnFontLoaded = false
        return

    QML_OBJECT_DEF = 'Text {' +
            'font.pixelSize: 14;' +
            'textFormat: Text.StyledText;' +
        '}'

    DATA =
        autoWidth: true
        autoHeight: true
        fontFamily: 'sans-serif'
        listensOnFontLoaded: false

    exports =
    DATA: DATA

    createData: impl.utils.createDataCloner 'Item', DATA

    create: (data) ->
        elem = data.elem ?= impl.utils.createQmlObject QML_OBJECT_DEF

        Item.create.call @, data

        exports.setTextFontFamily.call @, data.fontFamily
        
        # update size
        elem.fontChanged.connect @, updateSize

        # links
        elem.linkActivated.connect onLickActivated

        # update autoWidth/autoHeight
        @onWidthChange onWidthChange
        @onHeightChange onHeightChange

    setText: (val) ->
        {SUPPORTED_HTML_TAGS} = impl.Renderer.Text

        # remove unsupported HTML tags
        val = val.replace ///<\/?([a-zA-Z0-9]+).*?>///g, (str, tag) ->
            if SUPPORTED_HTML_TAGS[tag]
                str
            else
                ''
        val = val.replace ///(\ ){2,}///g, (str) ->
            str.replace ///\ ///g, '&nbsp; '

        @_impl.elem.text = val
        updateSize.call @

    setTextWrap: (val) ->

    updateTextContentSize: ->

    setTextColor: (val) ->
        @_impl.elem.color = impl.utils.toQtColor val

    setTextLinkColor: (val) ->
        @_impl.elem.linkColor = impl.utils.toQtColor val

    setTextLineHeight: (val) ->
        @_impl.elem.lineHeight = val

    setTextFontFamily: (val) ->
        @_impl.fontFamily = val
        if impl.fonts[val]
            @_impl.elem.font.family = impl.fonts[val]
        else
            unless @_impl.listensOnFontLoaded
                impl.onFontLoaded onFontLoaded, @
                @_impl.listensOnFontLoaded = true
        return

    setTextFontPixelSize: (val) ->
        @_impl.elem.font.pixelSize = val

    setTextFontWordSpacing: (val) ->
        @_impl.elem.font.wordSpacing = val

    setTextFontLetterSpacing: (val) ->
        @_impl.elem.font.letterSpacing = val

    setTextAlignmentHorizontal: (val) ->
        switch val
            when 'left'
                @_impl.elem.horizontalAlignment = Text.AlignLeft
            when 'center'
                @_impl.elem.horizontalAlignment = Text.AlignHCenter
            when 'right'
                @_impl.elem.horizontalAlignment = Text.AlignRight
            when 'justify'
                @_impl.elem.horizontalAlignment = Text.AlignJustify
        return

    setTextAlignmentVertical: (val) ->
        switch val
            when 'top'
                @_impl.elem.verticalAlignment = Text.AlignTop
            when 'center'
                @_impl.elem.verticalAlignment = Text.AlignVCenter
            when 'bottom'
                @_impl.elem.verticalAlignment = Text.AlignBottom
        return
