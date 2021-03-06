'use strict'

assert = require '../../assert'

###
Parse 3-digit hex, 6-digit hex, rgb, rgba, hsl, hsla, or named color into RGBA hex.
###
exports.toRGBAHex = do ->
    NAMED_COLORS =
        '': 0x00000000
        transparent: 0x00000000
        black: 0x000000ff
        silver: 0xc0c0c0ff
        gray: 0x808080ff
        white: 0xffffffff
        maroon: 0x800000ff
        red: 0xff0000ff
        purple: 0x800080ff
        fuchsia: 0xff00ffff
        green: 0x008000ff
        lime: 0x00ff00ff
        olive: 0x808000ff
        yellow: 0xffff00ff
        navy: 0x000080ff
        blue: 0x0000ffff
        teal: 0x008080ff
        aqua: 0x00ffffff
        orange: 0xffa500ff
        aliceblue: 0xf0f8ffff
        antiquewhite: 0xfaebd7ff
        aquamarine: 0x7fffd4ff
        azure: 0xf0ffffff
        beige: 0xf5f5dcff
        bisque: 0xffe4c4ff
        blanchedalmond: 0xffe4c4ff
        blueviolet: 0x8a2be2ff
        brown: 0xa52a2aff
        burlywood: 0xdeb887ff
        cadetblue: 0x5f9ea0ff
        chartreuse: 0x7fff00ff
        chocolate: 0xd2691eff
        coral: 0xff7f50ff
        cornflowerblue: 0x6495edff
        cornsilk: 0xfff8dcff
        crimson: 0xdc143cff
        darkblue: 0x00008bff
        darkcyan: 0x008b8bff
        darkgoldenrod: 0xb8860bff
        darkgray: 0xa9a9a9ff
        darkgreen: 0x006400ff
        darkgrey: 0xa9a9a9ff
        darkkhaki: 0xbdb76bff
        darkmagenta: 0x8b008bff
        darkolivegreen: 0x556b2fff
        darkorange: 0xff8c00ff
        darkorchid: 0x9932ccff
        darkred: 0x8b0000ff
        darksalmon: 0xe9967aff
        darkseagreen: 0x8fbc8fff
        darkslateblue: 0x483d8bff
        darkslategray: 0x2f4f4fff
        darkslategrey: 0x2f4f4fff
        darkturquoise: 0x00ced1ff
        darkviolet: 0x9400d3ff
        deeppink: 0xff1493ff
        deepskyblue: 0x00bfffff
        dimgray: 0x696969ff
        dimgrey: 0x696969ff
        dodgerblue: 0x1e90ffff
        firebrick: 0xb22222ff
        floralwhite: 0xfffaf0ff
        forestgreen: 0x228b22ff
        gainsboro: 0xdcdcdcff
        ghostwhite: 0xf8f8ffff
        gold: 0xffd700ff
        goldenrod: 0xdaa520ff
        greenyellow: 0xadff2fff
        grey: 0x808080ff
        honeydew: 0xf0fff0ff
        hotpink: 0xff69b4ff
        indianred: 0xcd5c5cff
        indigo: 0x4b0082ff
        ivory: 0xfffff0ff
        khaki: 0xf0e68cff
        lavender: 0xe6e6faff
        lavenderblush: 0xfff0f5ff
        lawngreen: 0x7cfc00ff
        lemonchiffon: 0xfffacdff
        lightblue: 0xadd8e6ff
        lightcoral: 0xf08080ff
        lightcyan: 0xe0ffffff
        lightgoldenrodyellow: 0xfafad2ff
        lightgray: 0xd3d3d3ff
        lightgreen: 0x90ee90ff
        lightgrey: 0xd3d3d3ff
        lightpink: 0xffb6c1ff
        lightsalmon: 0xffa07aff
        lightseagreen: 0x20b2aaff
        lightskyblue: 0x87cefaff
        lightslategray: 0x778899ff
        lightslategrey: 0x778899ff
        lightsteelblue: 0xb0c4deff
        lightyellow: 0xffffe0ff
        limegreen: 0x32cd32ff
        linen: 0xfaf0e6ff
        mediumaquamarine: 0x66cdaaff
        mediumblue: 0x0000cdff
        mediumorchid: 0xba55d3ff
        mediumpurple: 0x9370dbff
        mediumseagreen: 0x3cb371ff
        mediumslateblue: 0x7b68eeff
        mediumspringgreen: 0x00fa9aff
        mediumturquoise: 0x48d1ccff
        mediumvioletred: 0xc71585ff
        midnightblue: 0x191970ff
        mintcream: 0xf5fffaff
        mistyrose: 0xffe4e1ff
        moccasin: 0xffe4b5ff
        navajowhite: 0xffdeadff
        oldlace: 0xfdf5e6ff
        olivedrab: 0x6b8e23ff
        orangered: 0xff4500ff
        orchid: 0xda70d6ff
        palegoldenrod: 0xeee8aaff
        palegreen: 0x98fb98ff
        paleturquoise: 0xafeeeeff
        palevioletred: 0xdb7093ff
        papayawhip: 0xffefd5ff
        peachpuff: 0xffdab9ff
        peru: 0xcd853fff
        pink: 0xffc0cbff
        plum: 0xdda0ddff
        powderblue: 0xb0e0e6ff
        rosybrown: 0xbc8f8fff
        royalblue: 0x4169e1ff
        saddlebrown: 0x8b4513ff
        salmon: 0xfa8072ff
        sandybrown: 0xf4a460ff
        seagreen: 0x2e8b57ff
        seashell: 0xfff5eeff
        sienna: 0xa0522dff
        skyblue: 0x87ceebff
        slateblue: 0x6a5acdff
        slategray: 0x708090ff
        slategrey: 0x708090ff
        snow: 0xfffafaff
        springgreen: 0x00ff7fff
        steelblue: 0x4682b4ff
        tan: 0xd2b48cff
        thistle: 0xd8bfd8ff
        tomato: 0xff6347ff
        turquoise: 0x40e0d0ff
        violet: 0xee82eeff
        wheat: 0xf5deb3ff
        whitesmoke: 0xf5f5f5ff
        yellowgreen: 0x9acd32ff
        rebeccapurple: 0x663399ff

    DIGIT_3_RE = /^#[0-9a-fA-F]{3}$/
    DIGIT_6_RE = /^#[0-9a-fA-F]{6}$/
    RGB_RE = /^rgb\s*\(\s*([0-9.]+)\s*,\s*([0-9.]+)\s*,\s*([0-9.]+)\s*\)$/
    RGBA_RE = /^rgba\s*\(\s*([0-9.]+)\s*,\s*([0-9.]+)\s*,\s*([0-9.]+)\s*,\s*([0-9.]+)\s*\)$/
    HSL_RE = /^hsl\s*\(\s*([0-9.]+)\s*,\s*([0-9.]+)\s*%\s*,\s*([0-9.]+)\s*%\s*\)$/
    HSLA_RE = /^hsla\s*\(\s*([0-9.]+)\s*,\s*([0-9.]+)\s*%\s*,\s*([0-9.]+)\s*%\s*,\s*([0-9.]+)\s*\)$/

    numberToHex = (val) ->
        val = parseFloat val
        if val < 0
            val = 0
        else if val > 255
            val = 255
        hex = Math.round val
        hex

    alphaToHex = (val) ->
        numberToHex Math.round(parseFloat(val) * 255)

    # http://www.w3.org/TR/2011/REC-css3-color-20110607/#hsl-color
    hslToRgb = do ->
        hueToRgb = (p, q, t) ->
            if t < 0
                t += 1
            if t > 1
                t -= 1
            if t * 6 < 1
                return p + (q - p) * t * 6
            if t * 2 < 1
                return q
            if t * 3 < 2
                return p + (q - p) * (2 / 3 - t) * 6
            return p

        (hStr, sStr, lStr) ->
            p = q = h = s = l = 0.0

            h = (parseFloat(hStr) % 360) / 360
            s = parseFloat(sStr) / 100
            l = parseFloat(lStr) / 100

            if s is 0
                red = green = blue = l
            else
                if l <= 0.5
                    q = l * (s + 1)
                else
                    q = l + s - l * s
                p = l * 2 - q

                red = hueToRgb p, q, h + 1 / 3
                green = hueToRgb p, q, h
                blue = hueToRgb p, q, h - 1 / 3

            return Math.round(red * 255) << 16 |
                Math.round(green * 255) << 8 |
                Math.round(blue * 255)

    (color, defaultColor = 'transparent') ->
        assert.isString color
        r = g = b = a = 0

        if (result = NAMED_COLORS[color]) isnt undefined
            return result

        # 3-digit hexadecimal
        if DIGIT_3_RE.test(color)
            r = parseInt color[1], 16
            g = parseInt color[2], 16
            b = parseInt color[3], 16
            r = r<<4 | r
            g = g<<4 | g
            b = b<<4 | b
            a = 0xFF

        # 6-digit hexadecimal
        else if DIGIT_6_RE.test(color)
            r = parseInt color.substr(1, 2), 16
            g = parseInt color.substr(3, 2), 16
            b = parseInt color.substr(5, 2), 16
            a = 0xFF

        # rgb
        else if match = RGB_RE.exec(color)
            r = numberToHex match[1]
            g = numberToHex match[2]
            b = numberToHex match[3]
            a = 0xFF

        # rgba
        else if match = RGBA_RE.exec(color)
            r = numberToHex match[1]
            g = numberToHex match[2]
            b = numberToHex match[3]
            a = alphaToHex match[4]

        # hsl
        else if match = HSL_RE.exec(color)
            b = hslToRgb match[1], match[2], match[3]
            a = 0xFF

        # hsla
        else if match = HSLA_RE.exec(color)
            b = hslToRgb match[1], match[2], match[3]
            a = alphaToHex match[4]

        else
            return exports.toRGBAHex(defaultColor)

        return (r << 24 |
            g << 16 |
            b << 8 |
            a) >>> 0
