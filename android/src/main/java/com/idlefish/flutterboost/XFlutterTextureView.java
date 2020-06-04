package com.idlefish.flutterboost;
import android.content.Context;
import android.graphics.SurfaceTexture;
import android.util.AttributeSet;
import android.view.Surface;
import android.view.TextureView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import io.flutter.Log;
import io.flutter.embedding.engine.renderer.FlutterRenderer;
import io.flutter.embedding.engine.renderer.RenderSurface;

public class XFlutterTextureView extends TextureView implements RenderSurface {
  private static final String TAG = "FlutterTextureView";

  private boolean isSurfaceAvailableForRendering = false;
  private boolean isAttachedToFlutterRenderer = false;
  @Nullable
  private FlutterRenderer flutterRenderer;

  private Surface renderSurface;

  // Connects the {@code SurfaceTexture} beneath this {@code TextureView} with Flutter's native code.
  // Callbacks are received by this Object and then those messages are forwarded to our
  // FlutterRenderer, and then on to the JNI bridge over to native Flutter code.
  private final SurfaceTextureListener surfaceTextureListener = new SurfaceTextureListener() {
    @Override
    public void onSurfaceTextureAvailable(SurfaceTexture surfaceTexture, int width, int height) {
      Log.v(TAG, "SurfaceTextureListener.onSurfaceTextureAvailable()");
      isSurfaceAvailableForRendering = true;

      // If we're already attached to a FlutterRenderer then we're now attached to both a renderer
      // and the Android window, so we can begin rendering now.
      if (isAttachedToFlutterRenderer) {
        connectSurfaceToRenderer();
      }
    }

    @Override
    public void onSurfaceTextureSizeChanged(@NonNull SurfaceTexture surface, int width, int height) {
      Log.v(TAG, "SurfaceTextureListener.onSurfaceTextureSizeChanged()");
      if (isAttachedToFlutterRenderer) {
        changeSurfaceSize(width, height);
      }
    }

    @Override
    public void onSurfaceTextureUpdated(@NonNull SurfaceTexture surface) {
      // Invoked every time a new frame is available. We don't care.
    }

    @Override
    public boolean onSurfaceTextureDestroyed(@NonNull SurfaceTexture surface) {
      Log.v(TAG, "SurfaceTextureListener.onSurfaceTextureDestroyed()");
      isSurfaceAvailableForRendering = false;

      // If we're attached to a FlutterRenderer then we need to notify it that our SurfaceTexture
      // has been destroyed.
      if (isAttachedToFlutterRenderer) {
        disconnectSurfaceFromRenderer();
      }

      // Return true to indicate that no further painting will take place
      // within this SurfaceTexture.
      return true;
    }
  };

  /**
   * Constructs a {@code FlutterTextureView} programmatically, without any XML attributes.
   */
  public XFlutterTextureView(@NonNull Context context) {
    this(context, null);
  }

  /**
   * Constructs a {@code FlutterTextureView} in an XML-inflation-compliant manner.
   */
  public XFlutterTextureView(@NonNull Context context, @Nullable AttributeSet attrs) {
    super(context, attrs);
    init();
  }

  private void init() {
    // Listen for when our underlying SurfaceTexture becomes available, changes size, or
    // gets destroyed, and take the appropriate actions.
    setSurfaceTextureListener(surfaceTextureListener);
  }

  @Nullable
  @Override
  public FlutterRenderer getAttachedRenderer() {
    return flutterRenderer;
  }

  /**
   * Invoked by the owner of this {@code FlutterTextureView} when it wants to begin rendering
   * a Flutter UI to this {@code FlutterTextureView}.
   *
   * If an Android {@link SurfaceTexture} is available, this method will give that
   * {@link SurfaceTexture} to the given {@link FlutterRenderer} to begin rendering
   * Flutter's UI to this {@code FlutterTextureView}.
   *
   * If no Android {@link SurfaceTexture} is available yet, this {@code FlutterTextureView}
   * will wait until a {@link SurfaceTexture} becomes available and then give that
   * {@link SurfaceTexture} to the given {@link FlutterRenderer} to begin rendering
   * Flutter's UI to this {@code FlutterTextureView}.
   */
  public void attachToRenderer(@NonNull FlutterRenderer flutterRenderer) {
    Log.v(TAG, "Attaching to FlutterRenderer.");
    if (this.flutterRenderer != null) {
      Log.v(TAG, "Already connected to a FlutterRenderer. Detaching from old one and attaching to new one.");
      this.flutterRenderer.stopRenderingToSurface();
    }

    this.flutterRenderer = flutterRenderer;
    isAttachedToFlutterRenderer = true;

    // If we're already attached to an Android window then we're now attached to both a renderer
    // and the Android window. We can begin rendering now.
    if (isSurfaceAvailableForRendering) {
      Log.v(TAG, "Surface is available for rendering. Connecting FlutterRenderer to Android surface.");
      connectSurfaceToRenderer();
    }
  }

  /**
   * Invoked by the owner of this {@code FlutterTextureView} when it no longer wants to render
   * a Flutter UI to this {@code FlutterTextureView}.
   *
   * This method will cease any on-going rendering from Flutter to this {@code FlutterTextureView}.
   */
  public void detachFromRenderer() {
    if (flutterRenderer != null) {
      // If we're attached to an Android window then we were rendering a Flutter UI. Now that
      // this FlutterTextureView is detached from the FlutterRenderer, we need to stop rendering.
      // TODO(mattcarroll): introduce a isRendererConnectedToSurface() to wrap "getWindowToken() != null"
      if (getWindowToken() != null) {
        Log.v(TAG, "Disconnecting FlutterRenderer from Android surface.");
        disconnectSurfaceFromRenderer();
      }

      flutterRenderer = null;
      isAttachedToFlutterRenderer = false;
    } else {
      Log.w(TAG, "detachFromRenderer() invoked when no FlutterRenderer was attached.");
    }
  }

  // FlutterRenderer and getSurfaceTexture() must both be non-null.
  private void connectSurfaceToRenderer() {
    if (flutterRenderer == null || getSurfaceTexture() == null) {
      throw new IllegalStateException("connectSurfaceToRenderer() should only be called when flutterRenderer and getSurfaceTexture() are non-null.");
    }

//    flutterRenderer.startRenderingToSurface(new Surface(getSurfaceTexture()));

    renderSurface = new Surface(getSurfaceTexture());
    flutterRenderer.startRenderingToSurface(renderSurface);
  }

  // FlutterRenderer must be non-null.
  private void changeSurfaceSize(int width, int height) {
    if (flutterRenderer == null) {
      throw new IllegalStateException("changeSurfaceSize() should only be called when flutterRenderer is non-null.");
    }

    Log.v(TAG, "Notifying FlutterRenderer that Android surface size has changed to " + width + " x " + height);
    flutterRenderer.surfaceChanged(width, height);
  }

  // FlutterRenderer must be non-null.
  private void disconnectSurfaceFromRenderer() {
    if (flutterRenderer == null) {
      throw new IllegalStateException("disconnectSurfaceFromRenderer() should only be called when flutterRenderer is non-null.");
    }

    flutterRenderer.stopRenderingToSurface();
    if(renderSurface!=null){
      renderSurface.release();
      renderSurface = null;
    }

  }
}