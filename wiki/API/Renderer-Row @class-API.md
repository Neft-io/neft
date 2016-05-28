> [Wiki](Home) ▸ [[API Reference|API-Reference]] ▸ [[Renderer|Renderer-API]]

Row
<dl><dt>Syntax</dt><dd><code>Row @class</code></dd></dl>
```nml
`Row {
`   spacing: 5
`
`   Rectangle { color: 'blue'; width: 50; height: 50; }
`   Rectangle { color: 'green'; width: 20; height: 50; }
`   Rectangle { color: 'red'; width: 50; height: 20; }
`}
```

> [`Source`](/Neft-io/neft/blob/feb74662c4f7ee7aedc58bcb4488ea1b56f65be9/src/renderer/types/layout/row.litcoffee#row)

New
<dl><dt>Syntax</dt><dd><code>&#x2A;Row&#x2A; Row.New([&#x2A;Component&#x2A; component, &#x2A;Object&#x2A; options])</code></dd><dt>Static method of</dt><dd><i>Row</i></dd><dt>Parameters</dt><dd><ul><li>component — <i>Component</i> — <i>optional</i></li><li>options — <a href="/Neft-io/neft/wiki/API/Utils-API#isobject">Object</a> — <i>optional</i></li></ul></dd><dt>Returns</dt><dd><i>Row</i></dd></dl>
> [`Source`](/Neft-io/neft/blob/feb74662c4f7ee7aedc58bcb4488ea1b56f65be9/src/renderer/types/layout/row.litcoffee#new)

Row
<dl><dt>Syntax</dt><dd><code>&#x2A;Row&#x2A; Row() : &#x2A;Renderer.Item&#x2A;</code></dd><dt>Extends</dt><dd><i>Renderer.Item</i></dd><dt>Returns</dt><dd><i>Row</i></dd></dl>
> [`Source`](/Neft-io/neft/blob/feb74662c4f7ee7aedc58bcb4488ea1b56f65be9/src/renderer/types/layout/row.litcoffee#row)

padding
<dl><dt>Syntax</dt><dd><code>&#x2A;Margin&#x2A; Row::padding</code></dd><dt>Prototype property of</dt><dd><i>Row</i></dd><dt>Type</dt><dd><i>Margin</i></dd></dl>
> [`Source`](/Neft-io/neft/blob/feb74662c4f7ee7aedc58bcb4488ea1b56f65be9/src/renderer/types/layout/row.litcoffee#padding)

spacing
<dl><dt>Syntax</dt><dd><code>&#x2A;Float&#x2A; Row::spacing = 0</code></dd><dt>Prototype property of</dt><dd><i>Row</i></dd><dt>Type</dt><dd><a href="/Neft-io/neft/wiki/API/Utils-API#isfloat">Float</a></dd><dt>Default</dt><dd><code>0</code></dd></dl>
> [`Source`](/Neft-io/neft/blob/feb74662c4f7ee7aedc58bcb4488ea1b56f65be9/src/renderer/types/layout/row.litcoffee#spacing)

alignment
<dl><dt>Syntax</dt><dd><code>&#x2A;Alignment&#x2A; Row::alignment</code></dd><dt>Prototype property of</dt><dd><i>Row</i></dd><dt>Type</dt><dd><i>Alignment</i></dd></dl>
> [`Source`](/Neft-io/neft/blob/feb74662c4f7ee7aedc58bcb4488ea1b56f65be9/src/renderer/types/layout/row.litcoffee#alignment)

includeBorderMargins
<dl><dt>Syntax</dt><dd><code>&#x2A;Boolean&#x2A; Row::includeBorderMargins = false</code></dd><dt>Prototype property of</dt><dd><i>Row</i></dd><dt>Type</dt><dd><i>Boolean</i></dd><dt>Default</dt><dd><code>false</code></dd></dl>
> [`Source`](/Neft-io/neft/blob/feb74662c4f7ee7aedc58bcb4488ea1b56f65be9/src/renderer/types/layout/row.litcoffee#includebordermargins)
