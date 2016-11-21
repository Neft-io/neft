> [Wiki](Home) ▸ [[API Reference|API-Reference]] ▸ **App**

# App

> [`Source`](/Neft-io/neft/blob/98dfb6cbdd49bbd6d5539c696a87aed827588cec/src/app/index.litcoffee)

## Nested APIs

* [[Route|App-App.Route-API]]
* [[Standard routes|App-Standard routes-API]]

## Table of contents
* [App](#app)
* [app](#app)
  * [config](#config)
    * [type](#type)
  * [networking](#networking)
  * [models](#models)
  * [routes](#routes)
  * [styles](#styles)
  * [views](#views)
  * [resources](#resources)
  * [onReady](#onready)
  * [cookies](#cookies)

#app
<dl><dt>Syntax</dt><dd><code>&#x2A;Dict&#x2A; app</code></dd><dt>Type</dt><dd><a href="/Neft-io/neft/wiki/Dict-API#class-dict">Dict</a></dd></dl>
> [`Source`](/Neft-io/neft/blob/98dfb6cbdd49bbd6d5539c696a87aed827588cec/src/app/index.litcoffee#dict-app)

##config
<dl><dt>Syntax</dt><dd><code>&#x2A;Object&#x2A; app.config = `{}`</code></dd><dt>Static property of</dt><dd><i>app</i></dd><dt>Type</dt><dd><a href="/Neft-io/neft/wiki/Utils-API#isobject">Object</a></dd><dt>Default</dt><dd><code>{}</code></dd></dl>
Config object from the *package.json* file.

Can be overriden in the *init.js* file.

### type

The `app` type (the default one) uses renderer on the client side.

The `game` type uses special renderer (if exists) focused on more performance goals.

The `text` type always return HTML document with no renderer on the client side.
It's used for the crawlers (e.g. GoogleBot) or browsers with no javascript support.

```javascript
// package.json
{
    "name": "neft.io app",
    "version": "0.1.0",
    "config": {
        "title": "My first application!",
        "protocol": "http",
        "port": 3000,
        "host": "localhost",
        "language": "en",
        "type": "app"
    }
}
// init.js
module.exports = function(NeftApp) {
    var app = NeftApp({ title: "Overridden title" });
    console.log(app.config);
    // {title: "My first application!", protocol: "http", port: ....}
};
```

> [`Source`](/Neft-io/neft/blob/98dfb6cbdd49bbd6d5539c696a87aed827588cec/src/app/index.litcoffee)

##networking
<dl><dt>Syntax</dt><dd><code>&#x2A;Networking&#x2A; app.networking</code></dd><dt>Static property of</dt><dd><i>app</i></dd><dt>Type</dt><dd><a href="/Neft-io/neft/wiki/Networking-API#class-networking">Networking</a></dd></dl>
Standard Networking instance used to communicate
with the server and to create local requests.

All routes created by the *App.Route* uses this networking.

HTTP protocol is used by default with the data specified in the *package.json*.

> [`Source`](/Neft-io/neft/blob/98dfb6cbdd49bbd6d5539c696a87aed827588cec/src/app/index.litcoffee#networking-appnetworking)

##models
<dl><dt>Syntax</dt><dd><code>&#x2A;Object&#x2A; app.models = `{}`</code></dd><dt>Static property of</dt><dd><i>app</i></dd><dt>Type</dt><dd><a href="/Neft-io/neft/wiki/Utils-API#isobject">Object</a></dd><dt>Default</dt><dd><code>{}</code></dd></dl>
Files from the *models* folder with objects returned by their exported functions.

```javascript
// models/user/permission.js
module.exports = function(app) {
    return {
        getPermission: function(id){}
    };
};
// controllers/user.js
module.exports = function(app) {
    return {
        get: function(req, res, callback) {
            var data = app.models['user/permission'].getPermission(req.params.userId);
            callback(null, data);
        }
    }
};
```

> [`Source`](/Neft-io/neft/blob/98dfb6cbdd49bbd6d5539c696a87aed827588cec/src/app/index.litcoffee#object-appmodels--)

##routes
<dl><dt>Syntax</dt><dd><code>&#x2A;Object&#x2A; app.routes = `{}`</code></dd><dt>Static property of</dt><dd><i>app</i></dd><dt>Type</dt><dd><a href="/Neft-io/neft/wiki/Utils-API#isobject">Object</a></dd><dt>Default</dt><dd><code>{}</code></dd></dl>
Files from the *routes* folder with objects returned by their exported functions.

> [`Source`](/Neft-io/neft/blob/98dfb6cbdd49bbd6d5539c696a87aed827588cec/src/app/index.litcoffee#object-approutes--)

##styles
<dl><dt>Syntax</dt><dd><code>&#x2A;Object&#x2A; app.styles = `{}`</code></dd><dt>Static property of</dt><dd><i>app</i></dd><dt>Type</dt><dd><a href="/Neft-io/neft/wiki/Utils-API#isobject">Object</a></dd><dt>Default</dt><dd><code>{}</code></dd></dl>
Files from the *styles* folder as *Function*s
ready to create new [Item](/Neft-io/neft/wiki/Renderer-Item-API#class-item)s.

> [`Source`](/Neft-io/neft/blob/98dfb6cbdd49bbd6d5539c696a87aed827588cec/src/app/index.litcoffee#object-appstyles--)

##views
<dl><dt>Syntax</dt><dd><code>&#x2A;Object&#x2A; app.views = `{}`</code></dd><dt>Static property of</dt><dd><i>app</i></dd><dt>Type</dt><dd><a href="/Neft-io/neft/wiki/Utils-API#isobject">Object</a></dd><dt>Default</dt><dd><code>{}</code></dd></dl>
Files from the *views* folder as the [Document](/Neft-io/neft/wiki/Document-API#class-document) instances.

> [`Source`](/Neft-io/neft/blob/98dfb6cbdd49bbd6d5539c696a87aed827588cec/src/app/index.litcoffee#object-appviews--)

##resources
<dl><dt>Syntax</dt><dd><code>&#x2A;Resources&#x2A; app.resources</code></dd><dt>Static property of</dt><dd><i>app</i></dd><dt>Type</dt><dd><a href="/Neft-io/neft/wiki/Resources-API#class-resources">Resources</a></dd></dl>
> [`Source`](/Neft-io/neft/blob/98dfb6cbdd49bbd6d5539c696a87aed827588cec/src/app/index.litcoffee#resources-appresources)

##onReady
<dl><dt>Syntax</dt><dd><code>&#x2A;Signal&#x2A; app.onReady()</code></dd><dt>Static property of</dt><dd><i>app</i></dd><dt>Type</dt><dd><a href="/Neft-io/neft/wiki/Signal-API#class-signal">Signal</a></dd></dl>
Called when all modules, views, styled etc. have been loaded.

> [`Source`](/Neft-io/neft/blob/98dfb6cbdd49bbd6d5539c696a87aed827588cec/src/app/index.litcoffee#signal-apponready)

##cookies
<dl><dt>Syntax</dt><dd><code>&#x2A;Dict&#x2A; app.cookies</code></dd><dt>Static property of</dt><dd><i>app</i></dd><dt>Type</dt><dd><a href="/Neft-io/neft/wiki/Dict-API#class-dict">Dict</a></dd></dl>
On the client side, this object refers to the last received cookies
from the networking request.

On the server side, this cookies object are added into the each networking response.

By default, client has *clientId* and *sessionId* hashes.

```javascript
app.cookies.onChange(function(key){
    console.log('cookie changed', key, this[key]);
});
```

```xml
<h1>Your clientId</h1>
<em>${context.app.cookies.clientId}</em>
```

> [`Source`](/Neft-io/neft/blob/98dfb6cbdd49bbd6d5539c696a87aed827588cec/src/app/index.litcoffee#dict-appcookies)
