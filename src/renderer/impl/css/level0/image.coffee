'use strict'

signal = require 'src/signal'

module.exports = (impl) ->
	{Item} = impl.Types
	{round} = Math

	cache = Object.create null

	createImage = (src) ->
		img = document.createElement 'img'
		img.src = src

		img.addEventListener 'error', ->
			obj.status = 'error'
			obj.onLoaded.emit()

		img.addEventListener 'load', ->
			obj.status = 'ready'
			obj.width = @naturalWidth or @width
			obj.height = @naturalHeight or @height

			if obj.width is 0 and obj.height is 0 and ///\.svg$///.test(obj.source)
				xhr = new XMLHttpRequest
				xhr.overrideMimeType 'text/xml'
				xhr.open 'get', obj.source, true
				xhr.onload = ->
					{responseXML} = xhr
					svg = responseXML.querySelector 'svg'

					viewBox = svg.getAttribute 'viewBox'
					if viewBox
						viewBox = viewBox.split ' '
					else
						viewBox = [0, 0, 0, 0]

					obj.width = parseFloat(svg.getAttribute('width')) or parseFloat(viewBox[2])
					obj.height = parseFloat(svg.getAttribute('height')) or parseFloat(viewBox[3])

					obj.onLoaded.emit()
				xhr.onerror = ->
					obj.status = 'error'
					obj.onLoaded.emit()
				xhr.send()
			else
				obj.onLoaded.emit()

		obj =
			source: src
			status: 'loading'
			width: 0
			height: 0
			elem: img
		signal.create obj, 'onLoaded'
		obj

	getImage = (src) ->
		if r = cache[src]
			return r
		r = createImage src
		unless /^data:/.test(src)
			cache[src] = r
		r

	onImageLoaded = ->
		data = @_impl
		img = data.image

		if img.source is data.source
			callCallback.call @
		return

	callCallback = ->
		data = @_impl
		img = data.image
		{callback} = data

		unless data.useCssBackground
			data.innerElem?.style.display = if img.status is 'ready' then 'block' else 'none'

		if img.status is 'ready'
			callback?.call @, null, img
		else if img.status is 'error'
			callback?.call @, true
		else
			img.onLoaded onImageLoaded, @
		return

	useCssBackground = (item) ->
		data = item._impl
		data.useCssBackground = true
		data.elemStyle.backgroundImage = "url('#{data.source}')"
		data.elemStyle.backgroundPosition = '50% 50%'
		data.innerElem.style.display = 'none'
		return

	setBackgroundSize = (item, width, height) ->
		data = item._impl

		unless data.useCssBackground
			useCssBackground item

		data.elemStyle.backgroundSize = "#{width}px #{height}px"

		return

	DATA =
		innerElem: null
		callback: null
		source: ''
		image: null
		useCssBackground: false
		offsetX: 0
		offsetY: 0

	DATA: DATA

	createData: impl.utils.createDataCloner 'Item', DATA

	_getImage: getImage
	_callCallback: callCallback

	create: (data) ->
		self = @
		Item.create.call @, data

		innerElem = data.innerElem = document.createElement 'img'
		innerElem.style.display = 'none'
		data.elem.appendChild innerElem
		return

	setStaticImagePixelRatio: (val) ->

	setImageSource: (val, callback) ->
		val = impl.utils.encodeImageSrc val

		data = @_impl
		data.innerElem.src = val
		data.source = val
		data.callback = callback
		data.image = getImage val

		if data.useCssBackground
			data.elemStyle.backgroundImage = "url('#{val}')"

		callCallback.call @
		return

	setImageSourceWidth: (val) ->
		data = @_impl

		if data.image and val > 0 and val isnt data.image.width
			setBackgroundSize @, val, @_sourceHeight
		return

	setImageSourceHeight: (val) ->
		data = @_impl

		if data.image and val > 0 and val isnt data.image.height
			setBackgroundSize @, @_sourceWidth, val
		return

	setImageFillMode: (val) ->
		data = @_impl

		if val is 'Stretch'
			data.useCssBackground = false
			data.elemStyle.backgroundImage = ''
			data.innerElem.style.display = 'block'
		else
			useCssBackground @

			switch val
				when 'PreserveAspectFit'
					data.elemStyle.backgroundRepeat = 'no-repeat'
				when 'Tile'
					data.elemStyle.backgroundRepeat = 'repeat'

		return

	setImageOffsetX: (val) ->
		data = @_impl
		unless data.useCssBackground
			useCssBackground @
		data.offsetX = val
		data.elemStyle.backgroundPosition = "#{val}px #{data.offsetY}px"
		return

	setImageOffsetY: (val) ->
		data = @_impl
		unless data.useCssBackground
			useCssBackground @
		data.offsetY = val
		data.elemStyle.backgroundPosition = "#{data.offsetY}px #{val}px"
		return