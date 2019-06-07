const { assert, NativeStyleItem } = require('@neftio/core')

const { setPropertyValue } = NativeStyleItem

class Switch extends NativeStyleItem {
  setSelectedAnimated(val) {
    assert.isBoolean(val)
    setPropertyValue(this, 'selected', val)
    this.call('setSelectedAnimated', val)
  }
}

Switch.Initialize = (item) => {
  item.on('selectedChange', function (val) {
    setPropertyValue(this, 'selected', val)
  })
}

Switch.defineProperty({
  type: 'boolean',
  name: 'selected',
})

Switch.defineProperty({
  type: 'color',
  name: 'borderColor',
})

Switch.defineProperty({
  type: 'color',
  name: 'selectedColor',
})

Switch.defineProperty({
  type: 'color',
  name: 'thumbColor',
})

module.exports = Switch