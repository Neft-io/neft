const Renderer = require('../renderer')
const Document = require('../document')
const Element = require('../document/element')
const eventLoop = require('../event-loop')

const windowElement = new Element.Tag()
windowElement.props.set('n-style', ['__default__', 'item'])

const windowDocument = new Document('__window__', {
  style: {
    __default__: {
      item: () => {
        const item = Renderer.Item.New({ layout: 'flow' })
        return { objects: { item }, item }
      },
    },
  },
  styleItems: [{ element: [], children: [] }],
  element: windowElement,
})

windowDocument.render()
Renderer.setWindowItem(windowElement.style)

let renderer = null
module.exports = (DocumentFile, options) => {
  eventLoop.setImmediate(() => {
    if (renderer) {
      renderer.element.parent = null
      renderer.revert()
    }
    renderer = DocumentFile()
    renderer.render(options)
    renderer.element.parent = windowElement
  })
}