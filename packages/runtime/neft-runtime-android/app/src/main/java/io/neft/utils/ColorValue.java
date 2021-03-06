package io.neft.utils;

import android.graphics.Color;

public class ColorValue {
    public static final ColorValue TRANSPARENT = new ColorValue(Color.TRANSPARENT);
    private final int color;

    public static int RGBAtoARGB(int val) {
        return (val >>> 8) |  // __RRGGBB
                ((val & 0x000000FF) << 24); // AA______
    }

    public static int setAlpha(int argb, int alpha) {
        return ((argb & 0x00FFFFFF) |  // __RRGGBB
                (alpha & 0xFF) << 24); // AA______
    }

    public static int byAlpha(int argb, int alpha) {
        float left = (argb >> 24 & 0xFF) / 255f;
        float right = (alpha & 0xFF) / 255f;
        return setAlpha(argb, (int) (left * right * 255f));
    }

    public ColorValue(int argb) {
        this.color = argb;
    }

    public int getColor() {
        return color;
    }
}
