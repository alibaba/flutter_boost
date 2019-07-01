package com.idlefish.flutterboost;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Color;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.util.AttributeSet;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.ImageView;

import java.util.LinkedList;
import java.util.List;

public class SnapshotView extends FrameLayout {

    private ImageView mImg;

    public SnapshotView(@NonNull Context context) {
        super(context);
        init();
    }

    public SnapshotView(@NonNull Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    public SnapshotView(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }

    private void init(){
        setBackgroundColor(Color.RED);

        mImg = new ImageView(getContext());

        FrameLayout.LayoutParams params = new FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);
        params.gravity = Gravity.CENTER;

        mImg.setScaleType(ImageView.ScaleType.FIT_XY);
        mImg.setLayoutParams(params);

        addView(mImg);
    }

    public void toggleSnapshot(BoostFlutterView flutterView){
        if (!dismissSnapshot(flutterView)) {
            showSnapshot(flutterView);
        }
    }

    public boolean showSnapshot(BoostFlutterView flutterView){
        if(flutterView == null) return false;

        dismissSnapshot(flutterView);

        final Bitmap bitmap = flutterView.getEngine().getRenderer().getBitmap();
        if(bitmap == null || bitmap.isRecycled()) {
            return false;
        }

        mImg.setImageBitmap(bitmap);

        flutterView.addView(this,new FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));

        Debuger.log("showSnapshot");
        return true;
    }

    public boolean dismissSnapshot(BoostFlutterView flutterView){
        List<View> snapshots = new LinkedList<>();

        for(int index = 0;index < flutterView.getChildCount();index++){
            View view = flutterView.getChildAt(index);
            if(view instanceof SnapshotView) {
                snapshots.add(view);
            }
        }

        if(snapshots.isEmpty()) {
            return false;
        }else{
            for(View v:snapshots) {
                flutterView.removeView(v);
            }
            Debuger.log("dismissSnapshot");
            return true;
        }
    }
}
