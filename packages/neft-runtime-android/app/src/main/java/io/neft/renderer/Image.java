package io.neft.renderer;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.ColorFilter;
import android.graphics.Paint;
import android.graphics.PixelFormat;
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

import io.neft.client.InAction;
import io.neft.client.OutAction;
import io.neft.client.handlers.NoArgsActionHandler;
import io.neft.renderer.handlers.StringItemActionHandler;
import io.neft.utils.Consumer;
import io.neft.utils.StringUtils;
import io.neft.utils.ViewUtils;

public class Image extends Item {
    private static class ImageDrawable extends Drawable {
        static final Paint PAINT = new Paint(Paint.ANTI_ALIAS_FLAG | Paint.FILTER_BITMAP_FLAG);
        private int alpha = 255;
        private Bitmap bitmap;
        private final Rect srcRect = new Rect();

        void setBitmap(Bitmap bitmap) {
            this.bitmap = bitmap;
            if (bitmap != null) {
                srcRect.right = bitmap.getWidth();
                srcRect.bottom = bitmap.getHeight();
            }
            invalidateSelf();
        }

        @Override
        public void draw(Canvas canvas) {
            if (bitmap != null) {
                PAINT.setAlpha(alpha);
                canvas.drawBitmap(bitmap, srcRect, getBounds(), PAINT);
            }
        }

        @Override
        public void setAlpha(int alpha) {
            this.alpha = alpha;
            invalidateSelf();
        }

        @Override
        public void setColorFilter(ColorFilter colorFilter) {}

        @Override
        public int getOpacity() {
            return PixelFormat.TRANSLUCENT;
        }
    }

    private static final int MAX_WIDTH = 1280;
    private static final int MAX_HEIGHT = 960;

    private static final HashMap<String, Bitmap> CACHE = new HashMap<>();
    private static final HashMap<String, ArrayList<Consumer<Bitmap>>> LOADING = new HashMap<>();

    private String source;

    public static void register() {
        onAction(InAction.CREATE_IMAGE, new NoArgsActionHandler() {
            @Override
            public void accept() {
                new Image();
            }
        });

        onAction(InAction.SET_IMAGE_SOURCE, new StringItemActionHandler<Image>() {
            @Override
            public void accept(Image item, String value) {
                item.setSource(value);
            }
        });
    }

    private final ImageDrawable shape = new ImageDrawable();

    private Image() {
        super();
        ViewUtils.setBackground(view, shape);
    }

    private void onLoad() {
        float width = shape.bitmap == null ? 0 : pxToDp(shape.bitmap.getWidth());
        float height = shape.bitmap == null ? 0 : pxToDp(shape.bitmap.getHeight());
        pushAction(OutAction.IMAGE_SIZE, source, true, width, height);
    }

    private void onError() {
        pushAction(OutAction.IMAGE_SIZE, source, false, 0f, 0f);
    }

    static private Bitmap getBitmapFromSVG(SVG svg) {
        Drawable drawable = new PictureDrawable(svg.renderToPicture());
        Bitmap bitmap = Bitmap.createBitmap(drawable.getIntrinsicWidth(), drawable.getIntrinsicHeight(), Bitmap.Config.ARGB_8888);
        Canvas canvas = new Canvas(bitmap);
        drawable.setBounds(0, 0, canvas.getWidth(), canvas.getHeight());
        drawable.draw(canvas);
        return bitmap;
    }

    static private Bitmap getBitmapFromSVG(InputStream in) {
        SVG svg;
        try {
            svg = SVG.getFromInputStream(in);
        } catch(SVGParseException err) {
            return null;
        }
        return getBitmapFromSVG(svg);
    }

    static private Bitmap loadResourceSource(String val) {
        try {
            // get file
            InputStream in = APP.getActivity().getAssets().open(val.substring(1));
            if (in == null) {
                return null;
            }
            if (val.endsWith(".svg")) {
                return getBitmapFromSVG(in);
            }
            return BitmapFactory.decodeStream(in);
        } catch (IOException e) {
            e.printStackTrace();
            return null;
        }
    }

    static private Bitmap loadUrlSource(String val) {
        try {
            InputStream in = new URL(val).openStream();
            if (val.endsWith(".svg")) {
                return getBitmapFromSVG(in);
            }
            return BitmapFactory.decodeStream(in);
        } catch (Exception e) {
            Log.e("Neft", "Can't load image from url '"+val+"'");
            e.printStackTrace();
            return null;
        }
    }

    static private Bitmap validateBitmap(Bitmap bitmap) {
        // resize too large bitmaps
        int width = bitmap.getWidth();
        int height = bitmap.getHeight();
        if (width > MAX_WIDTH && height > MAX_HEIGHT) {
            if (width > height) {
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

    public static void getImageFromSource(final String val, final Consumer<Bitmap> callback) {
        // remove source
        if (val.isEmpty()) {
            callback.accept(null);
            return;
        }

        // get bitmap from CACHE if exists
        Bitmap fromCache = CACHE.get(val);
        if (fromCache != null) {
            callback.accept(fromCache);
            return;
        }

        // wait for load if already LOADING exists
        ArrayList<Consumer<Bitmap>> loadingArray = LOADING.get(val);
        if (loadingArray != null) {
            loadingArray.add(callback);
            return;
        }

        // save in LOADING
        loadingArray = new ArrayList<>();
        LOADING.put(val, loadingArray);
        loadingArray.add(callback);

        // load source
        final Thread thread = new Thread(new Runnable() {
            @Override
            public void run() {
                Bitmap bitmap;
                if (val.startsWith("/static")) {
                    bitmap = loadResourceSource(val);
                } else {
                    bitmap = loadUrlSource(val);
                }

                // validate bitmap
                if (bitmap != null) {
                    bitmap = validateBitmap(bitmap);
                }

                // save to CACHE
                if (bitmap != null && !val.startsWith("data:")) {
                    CACHE.put(val, bitmap);
                }

                // call handlers
                final Bitmap finalBitmap = bitmap;
                APP.getActivity().runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        final ArrayList<Consumer<Bitmap>> loadingArray = LOADING.get(val);
                        for (final Consumer<Bitmap> handler : loadingArray) {
                            handler.accept(finalBitmap);
                        }
                        LOADING.remove(val);
                    }
                });
            }
        });
        thread.start();
    }

    public void setSource(final String val) {
        final Image self = this;
        this.source = val;

        if (val.isEmpty()) {
            shape.setBitmap(null);
            onLoad();
            return;
        }

        getImageFromSource(val, new Consumer<Bitmap>() {
            @Override
            public void accept(Bitmap bitmap) {
                if (!StringUtils.equals(self.source, val)) {
                    return;
                }
                shape.setBitmap(bitmap);
                if (bitmap != null) {
                    self.onLoad();
                } else {
                    self.onError();
                }
            }
        });
    }
}