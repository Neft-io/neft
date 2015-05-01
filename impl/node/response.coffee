'use strict'

zlib = require 'zlib'
log = require 'log'
utils = require 'utils'
path = require 'path'
Document = require 'document'
expect = require 'expect'

log = log.scope 'Networking'

HEADERS =
	'Host': (obj) ->
		host = ///^(?:[a-z]+):\/\/(.+?)(?:\/)?$///.exec(obj.networking.url)
		if host then host[1] else obj.networking.url
	'Cache-Control': 'no-cache'
	'Content-Language': (obj) -> obj.networking.language
	'X-Frame-Options': 'deny'

METHOD_HEADERS =
	OPTIONS:
		'Access-Control-Allow-Origin': (obj) -> obj.networking.url
		'Allow': 'GET, POST, PUT, DELETE'

GZIP_ENCODING_HEADERS =
	'Content-Encoding': 'gzip'

###
Set headers in the server response
###
setHeaders = (obj, headers) ->
	{serverRes} = obj

	for name, value of headers
		unless serverRes.getHeader(name)?
			if typeof value is 'function'
				value = value obj
			serverRes.setHeader name, value

	return

###
Parse passed data into expected type
###
isObject = (data) -> true if data and typeof data is 'object'
isJSON = (data) -> 'application/json' if isObject data
isDocument = (data) -> 'text/html' if data instanceof Document

extensions =
	'.js': 'application/javascript'
	'.ico': 'image/x-icon'

parsers =
	'application/json': (data) ->
		try JSON.stringify data
	'text/html': (data) ->
		html = data.node.stringify()
		html

prepareData = (obj, data) ->
	# determine data type
	type = isDocument(data) or isJSON(data)
	type ?= extensions[path.extname obj.serverReq.url]
	type ?= 'text/plain'

	# parse data into type
	unless parsedData = parsers[type]?(data)
		parsedData = data + ''

	unless obj.serverRes.getHeader('Content-Type')?
		obj.serverRes.setHeader 'Content-Type', "#{type}; charset=utf-8"

	parsedData

###
Send data in server response
###
sendData = do ->
	send = (obj, data) ->
		if typeof data is 'string'
			len = Buffer.byteLength data
		else
			len = data and data.length

		obj.serverRes.setHeader 'Content-Length', len
		obj.serverRes.end data

	(obj, data, callback) ->
		acceptEncodingHeader = obj.serverReq.headers['Accept-Encoding']
		useGzip = acceptEncodingHeader and utils.has(acceptEncodingHeader, 'gzip')

		unless useGzip
			send obj, data
			return callback()

		setHeaders obj, GZIP_ENCODING_HEADERS

		zlib.gzip data, (_, data) ->
			send obj, data
			callback()

module.exports = (Networking, pending) ->
	exports =
	setHeader: (res, name, val) ->
		# get config obj
		obj = pending[res.request.uid]
		obj.serverRes.setHeader name, val

	send: (res, data, callback) ->
		# get config obj
		obj = pending[res.request.uid]
		return unless obj

		delete pending[res.request.uid]

		{serverRes} = obj

		# write headers
		setHeaders obj, HEADERS
		if headers = METHOD_HEADERS[obj.serverReq.method]
			setHeaders obj, headers

		# set status
		serverRes.statusCode = res.status

		# cookies
		if cookies = utils.tryFunction(JSON.stringify, null, [res.cookies], null)
			serverRes.setHeader 'X-Cookies', cookies

		# send data
		data = prepareData obj, data
		sendData obj, data, ->
			callback()

	redirect: (res, status, uri, callback) ->
		exports.send res, null, callback
