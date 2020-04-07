package com.taobao.idlefish.flutterboostexample;

import android.annotation.TargetApi;
import android.content.Context;
import android.os.Build;
import androidx.annotation.NonNull;
import android.util.AttributeSet;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowInsets;
import android.widget.FrameLayout;
import androidx.annotation.Nullable;
import androidx.annotation.RequiresApi;
import androidx.core.view.ViewCompat;


public class FitSystemWindowFrameLayout extends FrameLayout {


    public FitSystemWindowFrameLayout( @NonNull Context context) {
        super(context);
    }

    public FitSystemWindowFrameLayout( @NonNull Context context,  @Nullable AttributeSet attrs) {
        super(context, attrs);
    }

    public FitSystemWindowFrameLayout( @NonNull Context context,  @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
    }

    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    public FitSystemWindowFrameLayout(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr, int defStyleRes) {
        super(context, attrs, defStyleAttr, defStyleRes);
    }

    @TargetApi(Build.VERSION_CODES.LOLLIPOP)
    @Override
    public WindowInsets dispatchApplyWindowInsets(WindowInsets insets) {
        WindowInsets result = super.dispatchApplyWindowInsets(insets);
        if (!insets.isConsumed()) {
            final int count = getChildCount();
            for (int i = 0; i < count; i++)
                result = getChildAt(i).dispatchApplyWindowInsets(insets);
        }
        return result;
    }
 
    @Override
    public void addView(View child, int index, ViewGroup.LayoutParams params) {
        super.addView(child, index, params);
        ViewCompat.requestApplyInsets(child);
    }
    
}
