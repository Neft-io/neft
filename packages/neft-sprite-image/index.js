const { Renderer, utils, assert } = Neft
const { Impl, NumberAnimation, itemUtils } = Renderer

class SpriteImage extends Renderer.Item {
  constructor() {
    super()
    this._source = ''
    this._frameCount = 1
    this._animation = NumberAnimation.New()
  }
}

Impl.addTypeImplementation('SpriteImage', require('./impl/base/spriteImage'))

SpriteImage.New = (opts) => {
  const item = new SpriteImage()
  itemUtils.Object.initialize(item, opts)
  return item
}

itemUtils.defineProperty({
  constructor: SpriteImage,
  name: 'source',
  implementation: Impl.Types.SpriteImage.setSpriteImageSource,
  developmentSetter(val) {
    assert.isString(val)
  },
})

itemUtils.defineProperty({
  constructor: SpriteImage,
  name: 'frameCount',
  implementation: Impl.Types.SpriteImage.setSpriteImageFrameCount,
  developmentSetter(val) {
    assert.isInteger(val)
    assert.operator(val, '>', 0)
  },
})

utils.defineProperty(SpriteImage.prototype, 'animation', 0, function () {
  return this._animation
}, null)

module.exports = SpriteImage