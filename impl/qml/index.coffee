'use strict'

utils = require 'utils'

module.exports = (Networking) ->
	Request: require('./request.coffee') Networking
	Response: require('./response.coffee') Networking

	init: (networking) ->
		__location.change.connect (uri) ->
			# send internal request
			networking.createRequest
				method: Networking.Request.GET
				type: Networking.Request.HTML_TYPE
				uri: uri

		setImmediate ->
			__location.append '/'

	sendRequest: (req, callback) ->
		{Request} = Networking

		xhr = new XMLHttpRequest

		xhr.open req.method, req.uri, true
		xhr.setRequestHeader 'X-Expected-Type', req.type

		xhr.onreadystatechange = ->
			return if xhr.readyState isnt 4

			response = xhr.responseText

			if req.type is Request.JSON_TYPE
				response = utils.tryFunction JSON.parse, null, [response], response

			callback
				status: xhr.status
				data: response

		xhr.send()