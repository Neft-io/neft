package io.neft.extensions.video_extension;

import android.media.MediaPlayer;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.VideoView;

import io.neft.renderer.NativeItem;
import io.neft.renderer.annotation.OnCall;
import io.neft.renderer.annotation.OnCreate;
import io.neft.renderer.annotation.OnSet;

public class VideoItem extends NativeItem {
    private final VideoView videoView;
    private boolean loop;

    @OnCreate("Video")
    public VideoItem() {
        super(new LinearLayout(APP.getActivity().getApplicationContext()));
        videoView = new VideoView(APP.getActivity().getApplicationContext());

        LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(itemView.getLayoutParams());
        params.gravity = Gravity.CENTER;
        videoView.setLayoutParams(params);
        ((ViewGroup) itemView).addView(videoView);

        videoView.setOnPreparedListener(new MediaPlayer.OnPreparedListener() {
            @Override
            public void onPrepared(MediaPlayer mp) {
                itemView.setVisibility(View.VISIBLE);
            }
        });
        videoView.setOnCompletionListener(new MediaPlayer.OnCompletionListener() {
            @Override
            public void onCompletion(MediaPlayer mp) {
                if (loop) {
                    videoView.start();
                }
            }
        });
    }

    @OnSet("source")
    public void setSource(final String val) {
        itemView.setVisibility(View.INVISIBLE);
        videoView.setVideoPath(val);
    }

    @OnSet("loop")
    public void setLoop(boolean val) {
        loop = val;
    }

    @OnCall("start")
    public void start() {
        videoView.start();
    }

    @OnCall("stop")
    public void stop() {
        videoView.stopPlayback();
    }
}
