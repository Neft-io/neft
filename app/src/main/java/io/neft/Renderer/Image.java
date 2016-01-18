package io.neft.Renderer;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.Rect;
import android.graphics.drawable.Drawable;
import android.graphics.drawable.PictureDrawable;
import android.util.Log;

import com.caverock.androidsvg.SVG;
import com.caverock.androidsvg.SVGParseException;

import java.io.IOException;
import java.io.InputStream;
import java.net.URL;
import java.util.ArrayList;
import java.util.HashMap;

import io.neft.Client.Action;
import io.neft.Client.InAction;
import io.neft.Client.OutAction;
import io.neft.Client.Reader;
import io.neft.MainActivity;

public class Image extends Item {
    static void register(final MainActivity app){
        app.client.actions.put(InAction.CREATE_IMAGE, new Action() {
            @Override
            public void work(Reader reader) {
                new Image(app);
            }
        });

        app.client.actions.put(InAction.SET_IMAGE_SOURCE, new Action() {
            @Override
            public void work(Reader reader) {
                ((Image) app.renderer.getItemFromReader(reader)).setSource(reader.getString());
            }
        });

        app.client.actions.put(InAction.SET_IMAGE_SOURCE_WIDTH, new Action() {
            @Override
            public void work(Reader reader) {
                ((Image) app.renderer.getItemFromReader(reader)).setSourceWidth(reader.getFloat());
            }
        });

        app.client.actions.put(InAction.SET_IMAGE_SOURCE_HEIGHT, new Action() {
            @Override
            public void work(Reader reader) {
                ((Image) app.renderer.getItemFromReader(reader)).setSourceHeight(reader.getFloat());
            }
        });

        app.client.actions.put(InAction.SET_IMAGE_FILL_MODE, new Action() {
            @Override
            public void work(Reader reader) {
                ((Image) app.renderer.getItemFromReader(reader)).setFillMode(reader.getString());
            }
        });

        app.client.actions.put(InAction.SET_IMAGE_OFFSET_X, new Action() {
            @Override
            public void work(Reader reader) {
                ((Image) app.renderer.getItemFromReader(reader)).setOffsetX(reader.getFloat());
            }
        });

        app.client.actions.put(InAction.SET_IMAGE_OFFSET_Y, new Action() {
            @Override
            public void work(Reader reader) {
                ((Image) app.renderer.getItemFromReader(reader)).setOffsetY(reader.getFloat());
            }
        });
    }

    abstract class LoadHandler {
        void work(String source, Bitmap bitmap){ throw new UnsupportedOperationException(); }
    }

    static int MAX_WIDTH = 1280;
    static int MAX_HEIGHT = 960;
    static final Paint paint = new Paint(Paint.ANTI_ALIAS_FLAG | Paint.FILTER_BITMAP_FLAG);

    static final HashMap<String, Bitmap> cache = new HashMap<>();
    static final HashMap<String, ArrayList<LoadHandler>> loading = new HashMap<>();

    protected Bitmap bitmap;
    protected final Rect srcRect = new Rect();
    protected final Rect dstRect = new Rect();

    public String source;

    public Image(MainActivity app){
        super(app);
    }

    @Override
    public void setWidth(float val){
        super.setWidth(val);
        dstRect.right = (int) Math.ceil(width);
    }

    @Override
    public void setHeight(float val){
        super.setHeight(val);
        dstRect.bottom = (int) Math.ceil(height);
    }

    private void onLoad(){
        srcRect.right = bitmap.getWidth();
        srcRect.bottom = bitmap.getHeight();

        app.client.pushAction(OutAction.IMAGE_SIZE);
        app.renderer.pushItem(this);
        app.client.pushString(source);
        app.client.pushBoolean(true);
        app.client.pushFloat(app.renderer.pxToDp(bitmap.getWidth()));
        app.client.pushFloat(app.renderer.pxToDp(bitmap.getHeight()));
    }

    private void onError(){
        app.client.pushAction(OutAction.IMAGE_SIZE);
        app.renderer.pushItem(this);
        app.client.pushString(source);
        app.client.pushBoolean(false);
        app.client.pushFloat(0);
        app.client.pushFloat(0);
    }

    static private Bitmap getBitmapFromSVG(SVG svg){
        Drawable drawable = new PictureDrawable(svg.renderToPicture());
        Bitmap bitmap = Bitmap.createBitmap(drawable.getIntrinsicWidth(), drawable.getIntrinsicHeight(), Bitmap.Config.ARGB_8888);
        Canvas canvas = new Canvas(bitmap);
        drawable.setBounds(0, 0, canvas.getWidth(), canvas.getHeight());
        drawable.draw(canvas);
        return bitmap;
    }

    static private Bitmap getBitmapFromSVG(InputStream in){
        SVG svg;
        try {
            svg = SVG.getFromInputStream(in);
        } catch(SVGParseException err){
            return null;
        }
        return getBitmapFromSVG(svg);
    }

    static private Bitmap loadResourceSource(MainActivity app, String val){
        try {
            // get file
            InputStream in = app.getAssets().open(val.substring(1));
            if (in == null){
                return null;
            }
            if (val.endsWith(".svg")){
                return getBitmapFromSVG(in);
            }
            return BitmapFactory.decodeStream(in);
        } catch (IOException e) {
            e.printStackTrace();
            return null;
        }
    }

    static private Bitmap loadUrlSource(MainActivity app, String val){
        try {
            InputStream in = new URL(val).openStream();
            if (val.endsWith(".svg")){
                return getBitmapFromSVG(in);
            }
            return BitmapFactory.decodeStream(in);
        } catch (Exception e){
            Log.e("Neft", "Can't load image from url '"+val+"'");
            e.printStackTrace();
            return null;
        }
    }

    static private Bitmap loadDataUriSource(MainActivity app, String val){
        return null;
//        Pattern svgDataUri = Pattern.compile("^data:image/svg(?:.*);(?:.*)?,(.*)$");
//        Matcher svgDataUriMatch = svgDataUri.matcher(val);
//
//        if (svgDataUriMatch.matches()){
//            try {
//                SVG svg = SVG.getFromString(svgDataUriMatch.group(1));
//                Drawable drawable = new PictureDrawable(svg.renderToPicture());
//                try {
//                    item.setLayerType(View.LAYER_TYPE_SOFTWARE, null);
//                } finally {}
//                item.setImageDrawable(drawable);
//            } catch (SVGParseException e) {
//                Log.e("Neft", "Can't parse SVG data uri '"+val+"'\n" + e.getMessage());
//                return;
//            }
//        } else {
//            item.setImageResource(R.mipmap.ic_launcher);
//        }


//        byte[] decodedString = Base64.decode("Your Base64 String", Base64.DEFAULT);
//        Bitmap bitMap = BitmapFactory.decodeByteArray(decodedString, 0, decodedString.length);

    }

    static private Bitmap validateBitmap(Bitmap bitmap){
        // resize too large bitmaps
        int width = bitmap.getWidth();
        int height = bitmap.getHeight();
        if (width > MAX_WIDTH && height > MAX_HEIGHT){
            if (width > height){
                height = height * MAX_WIDTH / width;
                width = MAX_WIDTH;
            } else {
                width = width * MAX_HEIGHT / height;
                height = MAX_HEIGHT;
            }

            return Bitmap.createScaledBitmap(bitmap, width, height, false);
        }

        return bitmap;
    }

    public void setSource(final String val){
        source = val;

        // remove source
        if (val.equals("")){
            bitmap = null;
            invalidate();
            return;
        }

        // get bitmap from cache if exists
        Bitmap fromCache = cache.get(val);
        if (fromCache != null) {
            bitmap = fromCache;
            invalidate();
            onLoad();
            return;
        }

        // get load end handler
        final Image self = this;
        final LoadHandler onLoad = new LoadHandler() {
            @Override
            void work(String source, Bitmap bitmap) {
                if (self.source != source){
                    return;
                }
                self.bitmap = bitmap;
                if (bitmap != null){
                    self.onLoad();
                } else {
                    self.onError();
                }
                self.invalidate();
            }
        };

        // wait for load if already loading exists
        ArrayList<LoadHandler> loadingArray = loading.get(val);
        if (loadingArray != null){
            loadingArray.add(onLoad);
            return;
        }

        // save in loading
        loadingArray = new ArrayList<>();
        loading.put(val, loadingArray);
        loadingArray.add(onLoad);

        // load source
        final Thread thread = new Thread(new Runnable() {
            @Override
            public void run() {
                Bitmap bitmap;
                if (val.startsWith("/static")) {
                    bitmap = loadResourceSource(app, val);
                } else if (val.startsWith("data:")) {
                    bitmap = loadDataUriSource(app, val);
                } else {
                    bitmap = loadUrlSource(app, val);
                }

                // validate bitmap
                if (bitmap != null){
                    bitmap = validateBitmap(bitmap);
                }

                // save to cache
                if (bitmap != null && !val.startsWith("data:")){
                    cache.put(val, bitmap);
                }

                // call handlers
                final Bitmap finalBitmap = bitmap;
                app.runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        final ArrayList<LoadHandler> loadingArray = loading.get(val);
                        for (final LoadHandler handler : loadingArray) {
                            handler.work(val, finalBitmap);
                        }
                        loading.remove(val);
                    }
                });
            }
        });
        thread.start();
    }

    public void setSourceWidth(float val){
        // TODO
    }

    public void setSourceHeight(float val){
        // TODO
    }

    public void setFillMode(String val){
        // TODO
    }

    public void setOffsetX(float val){
        // TODO
    }

    public void setOffsetY(float val){
        // TODO
    }

    @Override
    protected void drawShape(final Canvas canvas, final int alpha){
        if (bitmap != null) {
            paint.setAlpha(alpha);
            canvas.drawBitmap(bitmap, srcRect, dstRect, paint);
        }
    }
}
