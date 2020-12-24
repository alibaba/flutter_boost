package com.idlefish.flutterboost.containers;

import android.os.Bundle;
import android.os.PersistableBundle;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.lifecycle.Lifecycle;
import androidx.lifecycle.LifecycleRegistry;

import com.idlefish.flutterboost.FlutterRouterApi;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.android.FlutterView;
import io.flutter.embedding.android.RenderMode;

public class FBFlutterActivity extends FlutterActivity {
    private FlutterView flutterView;

    @Override
    public void onCreate(Bundle savedInstanceState) {

        ((LifecycleRegistry) this.getLifecycle()).handleLifecycleEvent(Lifecycle.Event.ON_DESTROY);
        super.onCreate(savedInstanceState);

    }


    private void findFlutterView(View view) {
        if (view instanceof ViewGroup) {
            ViewGroup vp = (ViewGroup) view;
            for (int i = 0; i < vp.getChildCount(); i++) {
                View viewchild = vp.getChildAt(i);
                if (viewchild instanceof FlutterView) {
                    flutterView = (FlutterView) viewchild;
                    return;
                } else {
                    findFlutterView(viewchild);
                }

            }
        }
    }


    @Override
    protected void onResume() {
        if (flutterView == null) {
            findFlutterView(this.getWindow().getDecorView());
        }
        super.onResume();
        if (flutterView != null) {
//            flutterView.detachFromFlutterEngine();
            flutterView.attachToFlutterEngine(this.getFlutterEngine());
        }
    }
    @Override
    protected void onPause() {
        super.onPause();
        flutterView.detachFromFlutterEngine();
    }

    @NonNull
    @Override
    public RenderMode getRenderMode() {
        return RenderMode.texture;
    }

    @Override
    public void onBackPressed() {
        FlutterRouterApi.instance().popRoute(new FlutterRouterApi.Reply<Void>() {

            @Override
            public void reply(Void reply) {

            }
        });
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
    }

    @Override
    protected void onStop() {
        super.onStop();
    }

}
