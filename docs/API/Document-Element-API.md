> [Wiki](Home) ▸ [[API Reference|API-Reference]] ▸ [[Document|Document-API]] ▸ **Element**

# Element

> [`Source`](/Neft-io/neft/blob/b07f8471f0eea285e6ecaed7d5dc667674e2a4ae/src/document/element/element.litcoffee)

## Nested APIs

* [[Tag|Document-Element.Tag-API]]
* [[Text|Document-Element.Text-API]]

## Table of contents
* [Element](#element)
* [**Class** Element](#class-element)
  * [fromHTML](#fromhtml)
  * [fromJSON](#fromjson)
  * [index](#index)
  * [nextSibling](#nextsibling)
  * [previousSibling](#previoussibling)
  * [parent](#parent)
  * [onParentChange](#onparentchange)
  * [style](#style)
  * [onStyleChange](#onstylechange)
  * [visible](#visible)
  * [onVisibleChange](#onvisiblechange)
  * [queryAllParents](#queryallparents)
  * [queryParents](#queryparents)
  * [getAccessPath](#getaccesspath)
  * [clone](#clone)
  * [toJSON](#tojson)
* [Glossary](#glossary)

# **Class** Element

> [`Source`](/Neft-io/neft/blob/b07f8471f0eea285e6ecaed7d5dc667674e2a4ae/src/document/element/element.litcoffee)

##fromHTML
<dl><dt>Syntax</dt><dd><code>&#x2A;Element&#x2A; Element.fromHTML(&#x2A;String&#x2A; html)</code></dd><dt>Static method of</dt><dd><a href="/Neft-io/neft/wiki/Document-Element-API#class-element">Element</a></dd><dt>Parameters</dt><dd><ul><li>html — <i>String</i></li></ul></dd><dt>Returns</dt><dd><a href="/Neft-io/neft/wiki/Document-Element-API#class-element">Element</a></dd></dl>
> [`Source`](/Neft-io/neft/blob/b07f8471f0eea285e6ecaed7d5dc667674e2a4ae/src/document/element/element.litcoffee#element-elementfromhtmlstring-html)

##fromJSON
<dl><dt>Syntax</dt><dd><code>&#x2A;Element&#x2A; Element.fromJSON(&#x2A;Array&#x2A;|&#x2A;String&#x2A; json)</code></dd><dt>Static method of</dt><dd><a href="/Neft-io/neft/wiki/Document-Element-API#class-element">Element</a></dd><dt>Parameters</dt><dd><ul><li>json — <i>String</i> or <i>Array</i></li></ul></dd><dt>Returns</dt><dd><a href="/Neft-io/neft/wiki/Document-Element-API#class-element">Element</a></dd></dl>
> [`Source`](/Neft-io/neft/blob/b07f8471f0eea285e6ecaed7d5dc667674e2a4ae/src/document/element/element.litcoffee#element-elementfromjsonarraystring-json)

##index
<dl><dt>Syntax</dt><dd><code>&#x2A;Integer&#x2A; Element::index</code></dd><dt>Prototype property of</dt><dd><a href="/Neft-io/neft/wiki/Document-Element-API#class-element">Element</a></dd><dt>Type</dt><dd><a href="/Neft-io/neft/wiki/Utils-API#isinteger">Integer</a></dd></dl>
> [`Source`](/Neft-io/neft/blob/b07f8471f0eea285e6ecaed7d5dc667674e2a4ae/src/document/element/element.litcoffee#integer-elementindex)

##nextSibling
<dl><dt>Syntax</dt><dd><code>&#x2A;Element&#x2A; Element::nextSibling</code></dd><dt>Prototype property of</dt><dd><a href="/Neft-io/neft/wiki/Document-Element-API#class-element">Element</a></dd><dt>Type</dt><dd><a href="/Neft-io/neft/wiki/Document-Element-API#class-element">Element</a></dd></dl>
> [`Source`](/Neft-io/neft/blob/b07f8471f0eea285e6ecaed7d5dc667674e2a4ae/src/document/element/element.litcoffee#element-elementnextsibling)

##previousSibling
<dl><dt>Syntax</dt><dd><code>&#x2A;Element&#x2A; Element::previousSibling</code></dd><dt>Prototype property of</dt><dd><a href="/Neft-io/neft/wiki/Document-Element-API#class-element">Element</a></dd><dt>Type</dt><dd><a href="/Neft-io/neft/wiki/Document-Element-API#class-element">Element</a></dd></dl>
> [`Source`](/Neft-io/neft/blob/b07f8471f0eea285e6ecaed7d5dc667674e2a4ae/src/document/element/element.litcoffee#element-elementprevioussibling)

##parent
<dl><dt>Syntax</dt><dd><code>&#x2A;Element&#x2A; Element::parent</code></dd><dt>Prototype property of</dt><dd><a href="/Neft-io/neft/wiki/Document-Element-API#class-element">Element</a></dd><dt>Type</dt><dd><a href="/Neft-io/neft/wiki/Document-Element-API#class-element">Element</a></dd></dl>
> [`Source`](/Neft-io/neft/blob/b07f8471f0eea285e6ecaed7d5dc667674e2a4ae/src/document/element/element.litcoffee#element-elementparent)

##onParentChange
<dl><dt>Syntax</dt><dd><code>&#x2A;Signal&#x2A; Element::onParentChange(&#x2A;Element&#x2A; oldValue)</code></dd><dt>Prototype method of</dt><dd><a href="/Neft-io/neft/wiki/Document-Element-API#class-element">Element</a></dd><dt>Parameters</dt><dd><ul><li>oldValue — <a href="/Neft-io/neft/wiki/Document-Element-API#class-element">Element</a></li></ul></dd><dt>Type</dt><dd><a href="/Neft-io/neft/wiki/Signal-API#class-signal">Signal</a></dd></dl>
> [`Source`](/Neft-io/neft/blob/b07f8471f0eea285e6ecaed7d5dc667674e2a4ae/src/document/element/element.litcoffee#signal-elementonparentchangeelement-oldvalue)

##style
<dl><dt>Syntax</dt><dd><code>&#x2A;Renderer.Item&#x2A; Element::style</code></dd><dt>Prototype property of</dt><dd><a href="/Neft-io/neft/wiki/Document-Element-API#class-element">Element</a></dd><dt>Type</dt><dd><i>Renderer.Item</i></dd></dl>
> [`Source`](/Neft-io/neft/blob/b07f8471f0eea285e6ecaed7d5dc667674e2a4ae/src/document/element/element.litcoffee#rendereritem-elementstyle)

##onStyleChange
<dl><dt>Syntax</dt><dd><code>&#x2A;Signal&#x2A; Element::onStyleChange(&#x2A;Renderer.Item&#x2A; oldValue)</code></dd><dt>Prototype method of</dt><dd><a href="/Neft-io/neft/wiki/Document-Element-API#class-element">Element</a></dd><dt>Parameters</dt><dd><ul><li>oldValue — <i>Renderer.Item</i></li></ul></dd><dt>Type</dt><dd><a href="/Neft-io/neft/wiki/Signal-API#class-signal">Signal</a></dd></dl>
> [`Source`](/Neft-io/neft/blob/b07f8471f0eea285e6ecaed7d5dc667674e2a4ae/src/document/element/element.litcoffee#signal-elementonstylechangerendereritem-oldvalue)

##visible
<dl><dt>Syntax</dt><dd><code>&#x2A;Boolean&#x2A; Element::visible</code></dd><dt>Prototype property of</dt><dd><a href="/Neft-io/neft/wiki/Document-Element-API#class-element">Element</a></dd><dt>Type</dt><dd><i>Boolean</i></dd></dl>
> [`Source`](/Neft-io/neft/blob/b07f8471f0eea285e6ecaed7d5dc667674e2a4ae/src/document/element/element.litcoffee#boolean-elementvisible)

##onVisibleChange
<dl><dt>Syntax</dt><dd><code>&#x2A;Signal&#x2A; Element::onVisibleChange(&#x2A;Boolean&#x2A; oldValue)</code></dd><dt>Prototype method of</dt><dd><a href="/Neft-io/neft/wiki/Document-Element-API#class-element">Element</a></dd><dt>Parameters</dt><dd><ul><li>oldValue — <i>Boolean</i></li></ul></dd><dt>Type</dt><dd><a href="/Neft-io/neft/wiki/Signal-API#class-signal">Signal</a></dd></dl>
> [`Source`](/Neft-io/neft/blob/b07f8471f0eea285e6ecaed7d5dc667674e2a4ae/src/document/element/element.litcoffee#signal-elementonvisiblechangeboolean-oldvalue)

##queryAllParents
<dl><dt>Syntax</dt><dd><code>&#x2A;Array&#x2A; Element::queryAllParents(&#x2A;String&#x2A; query)</code></dd><dt>Prototype method of</dt><dd><a href="/Neft-io/neft/wiki/Document-Element-API#class-element">Element</a></dd><dt>Parameters</dt><dd><ul><li>query — <i>String</i></li></ul></dd><dt>Returns</dt><dd><i>Array</i></dd></dl>
> [`Source`](/Neft-io/neft/blob/b07f8471f0eea285e6ecaed7d5dc667674e2a4ae/src/document/element/element.litcoffee#array-elementqueryallparentsstring-query)

##queryParents
<dl><dt>Syntax</dt><dd><code>&#x2A;Element&#x2A; Element::queryParents(&#x2A;String&#x2A; query)</code></dd><dt>Prototype method of</dt><dd><a href="/Neft-io/neft/wiki/Document-Element-API#class-element">Element</a></dd><dt>Parameters</dt><dd><ul><li>query — <i>String</i></li></ul></dd><dt>Returns</dt><dd><a href="/Neft-io/neft/wiki/Document-Element-API#class-element">Element</a></dd></dl>
> [`Source`](/Neft-io/neft/blob/b07f8471f0eea285e6ecaed7d5dc667674e2a4ae/src/document/element/element.litcoffee#element-elementqueryparentsstring-query)

##getAccessPath
<dl><dt>Syntax</dt><dd><code>&#x2A;Array&#x2A; Element::getAccessPath([&#x2A;Tag&#x2A; toParent])</code></dd><dt>Prototype method of</dt><dd><a href="/Neft-io/neft/wiki/Document-Element-API#class-element">Element</a></dd><dt>Parameters</dt><dd><ul><li>toParent — <i>Tag</i> — <i>optional</i></li></ul></dd><dt>Returns</dt><dd><i>Array</i></dd></dl>
> [`Source`](/Neft-io/neft/blob/b07f8471f0eea285e6ecaed7d5dc667674e2a4ae/src/document/element/element.litcoffee#array-elementgetaccesspathtag-toparent)

##clone
<dl><dt>Syntax</dt><dd><code>&#x2A;Element&#x2A; Element::clone()</code></dd><dt>Prototype method of</dt><dd><a href="/Neft-io/neft/wiki/Document-Element-API#class-element">Element</a></dd><dt>Returns</dt><dd><a href="/Neft-io/neft/wiki/Document-Element-API#class-element">Element</a></dd></dl>
> [`Source`](/Neft-io/neft/blob/b07f8471f0eea285e6ecaed7d5dc667674e2a4ae/src/document/element/element.litcoffee#element-elementclone)

##toJSON
<dl><dt>Syntax</dt><dd><code>&#x2A;Array&#x2A; Element::toJSON()</code></dd><dt>Prototype method of</dt><dd><a href="/Neft-io/neft/wiki/Document-Element-API#class-element">Element</a></dd><dt>Returns</dt><dd><i>Array</i></dd></dl>
> [`Source`](/Neft-io/neft/blob/b07f8471f0eea285e6ecaed7d5dc667674e2a4ae/src/document/element/element.litcoffee#array-elementtojson)

# Glossary

- [Element](#class-element)
