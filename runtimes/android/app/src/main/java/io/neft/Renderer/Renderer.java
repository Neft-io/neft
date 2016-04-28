package io.neft.Renderer;

import android.graphics.Matrix;
import android.graphics.Rect;
import android.graphics.RectF;

import java.util.ArrayList;

import io.neft.Client.Reader;
import io.neft.MainActivity;
import io.neft.Native;

public class Renderer {
    private static final long MIN_FRAME_DELAY = 16;

    public MainActivity app;
    final public ArrayList<Item> items;
    final private Runnable runnable;

    final public Device device = new Device();
    final public Screen screen = new Screen();
    final public Navigator navigator = new Navigator();

    public ArrayList<RectF> dirtyRects = new ArrayList<>();
    private Matrix measureMatrix = new Matrix();
    private Rect dirtyRect = new Rect();

    public Renderer() {
        this.items = new ArrayList<>();
        this.runnable = new Runnable() {
            public void run() {
                onAnimationFrame();
            }
        };

        items.add(null);
    }

    public float pxToDp(float px) {
        return px / device.pixelRatio;
    }

    public float dpToPx(float dp) {
        return dp * device.pixelRatio;
    }

    public void pushItem(Item val) {
        app.client.pushInteger(val.id);
    }

    public void onAnimationFrame() {
        app.view.postDelayed(runnable, MIN_FRAME_DELAY);
        app.client.sendData();
        Native.renderer_callAnimationFrame();
        this.draw();
    }

    public Item getItemFromReader(Reader reader) {
        return items.get(reader.getInteger());
    }

    public void init(MainActivity app) {
        Device.init(device, app);
        Screen.init(screen, app);
        Navigator.init(navigator, app);

        WindowView.register(app);
        Navigator.register(app);
        Device.register(app);
        Screen.register(app);
        Item.register(app);
        Image.register(app);
        Text.register(app);
        TextInput.register(app);
        NativeItem.register(app);
        Rectangle.register(app);
        Scrollable.register(app);
    }

    private void draw() {
        // measure window item
        dirtyRects.clear();
        if (app.view.windowItem != null) {
            app.view.windowItem.measure(measureMatrix, screen.rect, dirtyRects);
        }

        for (final RectF rect : dirtyRects) {
            rect.roundOut(dirtyRect);
            app.view.invalidate(dirtyRect);
        }
    }
}