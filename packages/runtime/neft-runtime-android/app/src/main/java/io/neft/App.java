package io.neft;

import android.util.Log;
import android.view.Choreographer;
import android.view.KeyEvent;
import android.view.MotionEvent;
import android.view.ViewTreeObserver;
import io.neft.client.Client;
import io.neft.customapp.CustomApp;
import io.neft.renderer.*;
import io.neft.utils.Signal;
import io.neft.utils.StringUtils;
import lombok.Getter;
import lombok.NonNull;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

public class App {
    private class FullKeyEvent {
        final int keyCode;
        final KeyEvent keyEvent;

        FullKeyEvent(int keyCode, KeyEvent keyEvent) {
            this.keyCode = keyCode;
            this.keyEvent = keyEvent;
        }
    }

    public static final String TAG = "Neft";
    private static final String ASSET_FILE_PATH = "javascript/neft.js";
    private static final App INSTANCE = new App();
    private static final Choreographer CHOREOGRAPHER = Choreographer.getInstance();
    private MainActivity activity;
    private boolean running = false;
    @Getter private WindowView windowView;
    private CustomApp customApp;
    @Getter private Client client;
    @Getter private Renderer renderer;
    @Getter private AppPermissions permissions = new AppPermissions(this);
    private final UiThreadFrame uiThreadFrame;
    private final FrameCallback frameCallback;
    private final List<MotionEvent> touchEvents = new ArrayList<>();
    private final List<FullKeyEvent> keyEvents = new ArrayList<>();
    public Signal onBackPress = new Signal();

    String intentData = null;
    public Signal onIntentDataChange = new Signal();

    public static App getInstance() {
        return INSTANCE;
    }

    private class UiThreadFrame implements Runnable {
        @Override
        public void run() {
            CHOREOGRAPHER.postFrameCallback(frameCallback);
            onAnimationFrame();
        }
    }

    private class FrameCallback implements Choreographer.FrameCallback {
        @Override
        public void doFrame(long frameTimeNanos) {
            uiThreadFrame.run();
        }
    }

    private App() {
        uiThreadFrame = new UiThreadFrame();
        frameCallback = new FrameCallback();
    }

    public MainActivity getActivity() {
        return activity;
    }

    public String getIntentData() {
        return intentData;
    }

    private void onAnimationFrame() {
        synchronized (touchEvents) {
            while (!touchEvents.isEmpty()) {
                MotionEvent event = touchEvents.remove(0);
                renderer.getDevice().onTouchEvent(event);
                event.recycle();
            }
        }
        synchronized (keyEvents) {
            while (!keyEvents.isEmpty()) {
                FullKeyEvent fullKeyEvent = keyEvents.remove(0);
                renderer.getDevice().onKeyEvent(fullKeyEvent.keyCode, fullKeyEvent.keyEvent);
            }
        }
        Native.Bridge.callRendererAnimationFrame();
        client.sendData();
        if (windowView.windowItem != null) {
            windowView.windowItem.measure();
        }
        Item.onAnimationFrame();
    }

    public void run() {
        running = true;

        System.loadLibrary("neft");

        new Timers();
        client = new Client();
        renderer = new Renderer();
        Db.register();

        Device.register();
        Screen.register();
        WindowView.register();
        Item.register();
        Rectangle.register();
        Image.register();
        Text.register();
        NativeItem.register();

        renderer.init();
        AppConfig.initExtensions();

        customApp = new CustomApp();
        loadCode();

        activity.runOnUiThread(uiThreadFrame);
    }

    public void attach(@NonNull MainActivity activity) {
        this.activity = activity;
    }

    public void load() {
        if (running) {
            renderer.restore();
        } else {
            windowView = new WindowView(activity.getApplicationContext());
            run();
        }
    }

    public void processTouchEvent(@NonNull MotionEvent event) {
        // call press events synchronously to know which native items should handle further events
        if (event.getAction() == MotionEvent.ACTION_DOWN) {
            renderer.getDevice().onTouchEvent(event);
            client.sendData();
            return;
        }

        MotionEvent eventToProcess = MotionEvent.obtain(event);
        synchronized (touchEvents) {
            int lastIndex = touchEvents.size() - 1;
            MotionEvent lastEvent = lastIndex >= 0 ? touchEvents.get(lastIndex) : null;
            if (lastEvent != null && lastEvent.getAction() == eventToProcess.getAction()) {
                lastEvent.recycle();
                touchEvents.set(lastIndex, eventToProcess);
            } else {
                touchEvents.add(eventToProcess);
            }
        }
    }

    public void processKeyEvent(int keyCode, @NonNull KeyEvent event) {
        synchronized (keyEvents) {
            keyEvents.add(new FullKeyEvent(keyCode, event));
        }
    }

    private void loadCode() {
        String code = getAssetFile(ASSET_FILE_PATH);
        Native.Bridge.init(code);
    }

    private String getAssetFile(String path) {
        try {
            return StringUtils.getStringFromInputStream(activity.getAssets().open(path));
        } catch (IOException error) {
            Log.d(TAG, "IO ERROR!");
            Log.d(TAG, error.toString());
        }
        return "";
    }
}
