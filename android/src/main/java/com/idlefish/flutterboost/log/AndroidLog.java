package com.idlefish.flutterboost.log;

import android.util.Log;

public class AndroidLog implements ILog {
    @Override
    public void d(String tag, String msg) {
        Log.d(tag, msg);
    }

    @Override
    public void d(String tag, String msg, Throwable throwable) {
        Log.d(tag, msg, throwable);
    }

    @Override
    public void e(String tag, String msg) {
        Log.e(tag, msg);
    }

    @Override
    public void e(String tag, String msg, Throwable throwable) {
        Log.e(tag, msg, throwable);
    }

    @Override
    public void i(String tag, String msg) {
        Log.i(tag, msg);

    }

    @Override
    public void i(String tag, String msg, Throwable throwable) {
        Log.i(tag, msg, throwable);

    }

    @Override
    public void v(String tag, String msg) {
        Log.v(tag, msg);

    }

    @Override
    public void v(String tag, String msg, Throwable throwable) {
        Log.v(tag, msg, throwable);

    }

    @Override
    public void w(String tag, String msg) {
        Log.w(tag, msg);

    }

    @Override
    public void w(String tag, String msg, Throwable throwable) {
        Log.w(tag, msg, throwable);

    }

    @Override
    public boolean isLogLevelEnabled(int level) {
        return true;
    }
}
