package com.idlefish.flutterboost.example;

import android.content.Context;
import android.opengl.GLSurfaceView;
import android.view.View;

import io.flutter.plugin.platform.PlatformView;

public class GlSurface implements PlatformView {
    private final GLSurfaceView view;
    protected GlRenderer glRenderer;

    GlSurface(Context context) {
        view = new GLSurfaceView(context);
        view.setEGLContextClientVersion(2);
        view.setEGLConfigChooser(8, 8, 8, 0, 16, 0);
        glRenderer = new GlRenderer();
        glRenderer.setFrameRate(60);
        view.setRenderer(glRenderer);
        view.setRenderMode(GLSurfaceView.RENDERMODE_CONTINUOUSLY);//RENDERMODE_WHEN_DIRTY/RENDERMODE_CONTINUOUSLY
    }

    @Override
    public View getView() {
        return view;
    }

    @Override
    public void dispose() {
    }

}
