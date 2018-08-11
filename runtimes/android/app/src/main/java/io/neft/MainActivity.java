package io.neft;

import android.app.Activity;
import android.os.Bundle;
import android.view.KeyEvent;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import io.neft.utils.Signal;

public class MainActivity extends Activity {
    private static final App APP = App.getInstance();
    protected WindowView view;
    public Signal onBackPress = new Signal();

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        APP.attach(this);

        view = APP.getWindowView();

        if (view.getParent() != null) {
            ViewGroup parent = (ViewGroup) this.view.getParent();
            parent.removeView(view);
        }

        setContentView(view);

        // transparent status bar
        getWindow().getDecorView().setSystemUiVisibility(
                View.SYSTEM_UI_FLAG_LAYOUT_STABLE | View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
        );
    }

    @Override
    public void onBackPressed() {
        onBackPress.emit();
    }

    @Override
    public boolean dispatchTouchEvent(MotionEvent event) {
        App.getInstance().processTouchEvent(event);
        return super.dispatchTouchEvent(event);
    }

    private void onKeyEvent(int keyCode, KeyEvent event) {
        APP.processKeyEvent(keyCode, event);
    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event){
        onKeyEvent(keyCode, event);
        return super.onKeyDown(keyCode, event);
    }

    @Override
    public boolean onKeyUp(int keyCode, KeyEvent event){
        onKeyEvent(keyCode, event);
        return super.onKeyUp(keyCode, event);
    }

    @Override
    public boolean onKeyMultiple(int keyCode, int repeatCount, KeyEvent event){
        onKeyEvent(keyCode, event);
        return super.onKeyMultiple(keyCode, repeatCount, event);
    }
}
