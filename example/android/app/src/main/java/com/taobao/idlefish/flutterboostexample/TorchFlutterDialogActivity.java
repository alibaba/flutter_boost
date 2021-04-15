package com.taobao.idlefish.flutterboostexample;

import android.annotation.SuppressLint;
import android.os.Bundle;

import androidx.annotation.Nullable;
import com.idlefish.flutterboost.containers.BoostFlutterActivity;

@SuppressLint("Registered")
public class TorchFlutterDialogActivity extends BoostFlutterActivity {

    public static NewEngineIntentBuilder withNewEngine() {
        return new NewEngineIntentBuilder(TorchFlutterDialogActivity.class);
    }

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
    }

    @Override
    protected void onResume() {
        super.onResume();
    }

    @Override
    public void finish() {
        super.finish();
        overridePendingTransition(0, 0);
        clearDrawableProxy();
    }

    private void clearDrawableProxy(){
    }
}
