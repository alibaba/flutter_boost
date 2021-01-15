package com.idlefish.flutterboost.example.tab;

import android.content.Context;
import android.util.Log;
import android.util.TypedValue;
import android.view.Gravity;
import android.widget.FrameLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;

public class TabView extends FrameLayout {
    private String title;

    public TabView(@NonNull Context context) {
        super(context);
        title = "这是一个Native view，hashCode=" + hashCode();
        TextView textView = new TextView(getContext());
        textView.setText(title);
        textView.setGravity(Gravity.CENTER);
        textView.setTextSize(TypedValue.COMPLEX_UNIT_DIP, 19);
        textView.setTextColor(0xff333333);
        this.addView(textView, -1, -1);
        onCreate();
    }

    public void onCreate() {
        Log.d("xlog", "TabContainer onCreate  " + title);
    }

    public void onResume() {
        Log.d("xlog", "TabContainer onResume " + title);
    }

    public void onPause() {
        Log.d("xlog", "TabContainer onPause  " + title);
    }

    public void onDestroy() {
        Log.d("xlog", "TabContainer onDestroy  " + title);
    }
}