const { Renderer, assert, utils } = Neft;
const { setPropertyValue } = Renderer.itemUtils;

class Switch extends Renderer.Native {
    setSelectedAnimated(val) {
        assert.isBoolean(val);
        setPropertyValue(this, 'selected', val);
        this.call('setSelectedAnimated', val);
    }
}

Switch.__name__ = 'Switch';

Switch.Initialize = (item) => {
    item.on('selectedChange', function (val) {
        setPropertyValue(this, 'selected', val);
    });
};

Switch.defineProperty({
    type: 'boolean',
    name: 'selected',
});

Switch.defineProperty({
    type: 'color',
    name: 'borderColor',
});

Switch.defineProperty({
    type: 'color',
    name: 'selectedColor',
});

Switch.defineProperty({
    type: 'color',
    name: 'thumbColor',
});

module.exports = Switch;