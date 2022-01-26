package com.idlefish.flutterboost.example;

import android.graphics.Color;
import android.graphics.Rect;
import android.opengl.GLES20;
import android.opengl.GLSurfaceView;

import javax.microedition.khronos.egl.EGLConfig;
import javax.microedition.khronos.opengles.GL10;

public class GlRenderer implements GLSurfaceView.Renderer {
    private int width = 0;
    private int height = 0;
    private int frame = 0;
    private long lasttime = System.currentTimeMillis();
    private long currenttime = 0;

    private long framesPerSecond;
    private long frameInterval; // the time it should take 1 frame to render
    private final long millisecondsInSeconds = 1000;

    private long drawFrameTimes = 0;
    private long totalDrawFrameConsume = 0;

    @Override
    public void onSurfaceCreated(GL10 unused, EGLConfig config) {
        GLES20.glEnable(GLES20.GL_SCISSOR_TEST);
    }

    @Override
    public void onSurfaceChanged(GL10 gl, int width, int height) {
        this.width = width;
        this.height = height;
    }

    private void drawRect(Rect r, int c) {
        GLES20.glViewport(r.left, r.top, r.width(), r.height());
        GLES20.glScissor(r.left, r.top, r.width(), r.height());
        GLES20.glClearColor(Color.red(c) / 255.f, Color.green(c) / 255.f, Color.blue(c) / 255.f, 1.0f);
        GLES20.glClear(GLES20.GL_COLOR_BUFFER_BIT);
    }

    public void setFrameRate(long fps){
        framesPerSecond = fps;
        frameInterval= millisecondsInSeconds / framesPerSecond;
    }

    @Override
    public void onDrawFrame(GL10 gl) {
        // get the time at the start of the frame
        long time = System.currentTimeMillis();

        // draw code
        drawRect(new Rect(0, 0, width, height), Color.WHITE);
        drawRect(new Rect(frame % width, 0, frame % width + 1, height), Color.BLACK);
        drawRect(new Rect(50, 50, width-50, height-50), frame % 2 == 0 ? Color.RED : Color.BLUE);
        currenttime = System.currentTimeMillis();

        // get the time taken to render the frame
        long time2 = System.currentTimeMillis() - time;
        drawFrameTimes = drawFrameTimes + 1;
        totalDrawFrameConsume = totalDrawFrameConsume + time2;

        // android.util.Log.d("JUMIN-AndroidViewTime", "DrawFrametime: "+time2+" Frametime: "+String.valueOf(currenttime-lasttime)+" frame: "+String.valueOf(frame));
        // android.util.Log.d("JUMIN-AndroidViewAverageTime", "AverageDrawFrametime: "+String.valueOf(totalDrawFrameConsume/drawFrameTimes));
        lasttime = currenttime;
        frame++;

        // if time elapsed is less than the frame interval
        if(time2 < frameInterval){
            try {
                // sleep the thread for the remaining time until the interval has elapsed
                Thread.sleep(frameInterval - time2);
            } catch (InterruptedException e) {
                // Thread error
                e.printStackTrace();
            }
        } else {
            // framerate is slower than desired
        }
    }
}
