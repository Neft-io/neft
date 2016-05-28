> [Wiki](Home) ▸ [[API Reference|API-Reference]] ▸ [[Document|Document-API]] ▸ [[File|Document-File @class-API]]

id
<dl><dt>Syntax</dt><dd><code>id @xml</code></dd></dl>
[Tag][document/Tag] with the id attribute is saved in the local scope
(file, [neft:fragment][document/neft:fragment@xml], [neft:each][document/neft:each@xml] etc.)
and it's available in the string interpolation.

Id must be unique in the scope.

```xml
<h1 id="heading">Heading</h1>
<span>${heading.stringify()}</span>
```

> [`Source`](/Neft-io/neft/blob/feb74662c4f7ee7aedc58bcb4488ea1b56f65be9/src/document/file/parse/ids.litcoffee#id)
