'use strict'

# get transform CSS property name
transformProp = do ->
	prefix = do ->
		tmp = document.createElement 'div'
		return 't' if tmp.style.transform?
		return 'webkitT' if tmp.style.webkitTransform?
		return 'mozT' if tmp.style.mozTransform?
		return 'msT' if tmp.style.msTransform?

	"#{prefix}ransform"

isFirefox = navigator.userAgent.indexOf('Firefox') isnt -1

rad2deg = (rad) ->
	rad * 180/Math.PI

module.exports = (impl) ->
	{items} = impl

	updateTransforms = (id) ->
		item = items[id]

		transform = "rotate(#{rad2deg(item.rotation)}deg) scale(#{item.scale})"
		item.elem.style[transformProp] = transform

	create: (id, target) ->
		target.elem ?= document.createElement 'div'
		target.elem.id = id

		target.rotation = 0
		target.scale = 1

	getItemParent: (id) ->
		items[id].elem.parentElement?.id

	setItemParent: (id, val) ->
		items[val].elem.appendChild items[id].elem

	getItemVisible: (id) ->
		items[id].elem.style.display isnt 'none'

	setItemVisible: (id, val) ->
		items[id].elem.style.display = if val then 'inherit' else 'none'

	getItemClip: (id) ->
		items[id].elem.style.overflow is 'hidden'

	setItemClip: (id, val) ->
		items[id].elem.style.overflow = if val then 'hidden' else 'visible'

	getItemWidth: (id) ->
		parseFloat items[id].elem.style.width

	setItemWidth: (id, val) ->
		items[id].elem.style.width = "#{val}px"

	getItemHeight: (id) ->
		parseFloat items[id].elem.style.height

	setItemHeight: (id, val) ->
		items[id].elem.style.height = "#{val}px"

	getItemX: (id) ->
		parseFloat items[id].elem.style.left

	setItemX: (id, val) ->
		items[id].elem.style.left = val

	getItemY: (id) ->
		parseFloat items[id].elem.style.top

	setItemY: (id, val) ->
		items[id].elem.style.top = val

	getItemZ: (id) ->
		val = items[id].elem.style.zIndex

		if val is 'inherit'
			0
		else
			parseFloat val

	setItemZ: (id, val) ->
		items[id].elem.style.zIndex = if val is 0 then 'inherit' else val

	getItemScale: (id) ->
		items[id].scale

	setItemScale: (id, val) ->
		items[id].scale = val
		updateTransforms id

	getItemRotation: (id) ->
		items[id].rotation

	setItemRotation: (id, val) ->
		items[id].rotation = val
		updateTransforms id

	getItemOpacity: (id) ->
		parseFloat items[id].elem.style.opacity

	setItemOpacity: (id, val) ->
		items[id].elem.style.opacity = val

