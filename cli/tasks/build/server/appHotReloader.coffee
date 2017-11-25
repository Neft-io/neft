'use strict'

# ! IMPORTANT !
# DO NOT INCLUDE THIS FILE INTO PRODUCTION BUILDS

{log, utils, Document} = Neft
try {onNativeEvent} = Neft.native

log = log.scope 'HotReloader'

NATIVE_EVENT = '__neftHotReload'

reloadDocumentDeeply = (doc, reloadCompPath) ->
    # uses
    for use in doc.uses
        unless use.isRendered
            continue
        if doc.components[use.name] is reloadCompPath
            use.revert()
            delete Document._pool[reloadCompPath]
            use.render()
        else if use.usedComponent
            reloadDocumentDeeply use.usedComponent, reloadCompPath

    # iterators
    for iterator in doc.iterators
        unless iterator.isRendered
            continue
        if iterator.name is reloadCompPath
            iterator.revert()
            delete Document._pool[reloadCompPath]
            iterator.render()
        else
            for child in iterator.usedComponents
                reloadDocumentDeeply child, reloadCompPath
    return

reloadRouteDocument = (app, route, reloadCompPath) ->
    onLoadEnd = ->
        app.Route.onLastClientRouteChange.disconnect onLoadEnd
        delete Document._pool[reloadCompPath]

    app.Route.onLastClientRouteChange.connect onLoadEnd
    app.networking.createLocalRequest route.request.toJSON()

    return

module.exports = (app) ->

    reloadVisibleComponent = (name) ->
        delete Document._pool[name]
        lastRespData = app.Route.lastClientRoute?.response.data
        if lastRespData instanceof Document
            if lastRespData.path is name
                reloadRouteDocument app, app.Route.lastClientRoute, name
            else
                reloadDocumentDeeply lastRespData, name
        return

    reloadComponent = (name, fileStr) ->
        log.debug "Reload component #{name}"
        func = new Function 'module', fileStr
        funcModules = exports: {}
        name = "components/#{name}"
        delete Document._files[name]
        func funcModules
        app.components[name] = Document.fromJSON funcModules.exports
        reloadVisibleComponent name

    reloadStyle = (name, fileStr) ->
        log.debug "Reload style #{name}"

        styleModule = do (module, exports = {}) ->
            module = exports: exports
            eval fileStr
            module

        styleModule.exports._init windowItem: app.windowItem
        app.styles[name] = styleModule.exports

        for path, file of Document._files
            for style in file.styles
                if style.node instanceof Document.Element.Tag
                    styleId = style.node.props[Document.Style.STYLE_ID_PROP]
                    styleIdParts = styleId.split ':'
                    if styleIdParts[0] is 'styles' and styleIdParts[1] is name
                        reloadVisibleComponent path
                        break

        return

    reloadScript = (name, fileStr) ->
        log.debug "Reload script #{name}"
        scriptModule = do (module, exports = {}) ->
            module = exports: exports
            eval fileStr
            module
        app.documentScripts[name] = scriptModule.exports

        for path, file of Document._files
            if utils.has(file.scripts.names, name)
                reloadVisibleComponent path

        return

    app?.reload = reload = (hotReloads) ->
        for hotReload in hotReloads
            switch hotReload.destination
                when 'components'
                    reloadComponent(hotReload.name, hotReload.file)
                when 'styles'
                    reloadStyle(hotReload.name, hotReload.file)
                when 'scripts'
                    reloadScript(hotReload.name, hotReload.file)
                else
                    throw new Error "Unsupported hot reload destination #{hotReload.destination}"

    if process.env.NEFT_NATIVE
        onNativeEvent NATIVE_EVENT, (data) ->
            reload JSON.parse(data).hotReloads