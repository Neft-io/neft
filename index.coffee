'use strict'

exports = module.exports = require 'src/app'
exports['neft-app'] = exports
exports.utils = exports['neft-utils'] = require 'src/utils'
exports.signal = exports['neft-signal'] = require 'src/signal'
exports.Dict = exports['neft-dict'] = require 'src/dict'
exports.List = exports['neft-list'] = require 'src/list'
exports.log = exports['neft-log'] = require 'src/log'
exports.Resources = exports['neft-resources'] = require 'src/resources'
exports.native = exports['neft-native'] = require 'src/native'
exports.Renderer = exports['neft-renderer'] = require 'src/renderer'
exports.Networking = exports['neft-networking'] = require 'src/networking'
exports.Schema = exports['neft-schema'] = require 'src/schema'
exports.Document = exports['neft-document'] = require 'src/document'
exports.styles = exports['neft-styles'] = require 'src/styles'
exports.assert = exports['neft-assert'] = require 'src/assert'
exports.db = exports['neft-db'] = require 'src/db'
exports.Binding = exports['neft-binding'] = require 'src/binding'

if exports.utils.isNode
    exports.nmlParser = require 'src/nml-parser'
