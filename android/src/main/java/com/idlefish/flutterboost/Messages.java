// Copyright (c) 2019 Alibaba Group. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.idlefish.flutterboost;

import android.util.Log;
import io.flutter.plugin.common.MessageCodec;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.FlutterJNI;
import java.io.ByteArrayOutputStream;
import java.nio.ByteBuffer;
import java.util.Arrays;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.HashMap;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicLong;

@SuppressWarnings({"unused", "unchecked", "CodeBlock2Expr", "RedundantSuppression"})
public class Messages {
  private static final String FLUTTER_BOOST_BRIDGE_NAME = "com.idlefish.flutterboost.direct.FlutterBoostRouterApi";
  private static final int FAST_MESSAGE_KIND_REQUEST = 0;
  private static final int METHOD_PUSH_NATIVE_ROUTE = 1;
  private static final int METHOD_PUSH_FLUTTER_ROUTE = 2;
  private static final int METHOD_POP_NATIVE_ROUTE = 3;
  private static final int METHOD_GET_STACK_FROM_HOST = 4;
  private static final int METHOD_SAVE_STACK_TO_HOST = 5;
  private static final int METHOD_SEND_EVENT_TO_NATIVE = 6;
  private static final int METHOD_PUSH_ROUTE = 101;
  private static final int METHOD_POP_ROUTE = 102;
  private static final int METHOD_REMOVE_ROUTE = 103;
  private static final int METHOD_ON_FOREGROUND = 104;
  private static final int METHOD_ON_BACKGROUND = 105;
  private static final int METHOD_ON_NATIVE_RESULT = 106;
  private static final int METHOD_ON_CONTAINER_SHOW = 107;
  private static final int METHOD_ON_CONTAINER_HIDE = 108;
  private static final int METHOD_SEND_EVENT_TO_FLUTTER = 109;
  private static final int METHOD_ON_BACK_PRESSED = 110;

  private static ByteBuffer directBuffer(ByteBuffer buffer) {
    if (buffer == null) {
      return null;
    }
    ByteBuffer source = buffer.duplicate();
    int length = source.position();
    source.position(0);
    source.limit(length);
    ByteBuffer direct = ByteBuffer.allocateDirect(length);
    direct.put(source);
    direct.flip();
    return direct;
  }

  private static int bufferLength(ByteBuffer buffer) {
    return buffer == null ? 0 : buffer.remaining();
  }

  private static void returnDartCall(long replyId, Object wrapped, MessageCodec<Object> codec) {
    ByteBuffer encoded = directBuffer(codec.encodeMessage(wrapped));
    FlutterJNI.returnNativeFastMessageToDart(
        FLUTTER_BOOST_BRIDGE_NAME, replyId, encoded, bufferLength(encoded));
  }

  public static class CommonParams {
    private Boolean opaque;
    public Boolean getOpaque() { return opaque; }
    public void setOpaque(Boolean setterArg) {
      this.opaque = setterArg;
    }

    private String key;
    public String getKey() { return key; }
    public void setKey(String setterArg) {
      this.key = setterArg;
    }

    private String pageName;
    public String getPageName() { return pageName; }
    public void setPageName(String setterArg) {
      this.pageName = setterArg;
    }

    private String uniqueId;
    public String getUniqueId() { return uniqueId; }
    public void setUniqueId(String setterArg) {
      this.uniqueId = setterArg;
    }

    private Map<String, Object> arguments;
    public Map<String, Object> getArguments() { return arguments; }
    public void setArguments(Map<String, Object> setterArg) {
      this.arguments = setterArg;
    }

    public static final class Builder {
      private Boolean opaque;
      public Builder setOpaque(Boolean setterArg) {
        this.opaque = setterArg;
        return this;
      }
      private String key;
      public Builder setKey(String setterArg) {
        this.key = setterArg;
        return this;
      }
      private String pageName;
      public Builder setPageName(String setterArg) {
        this.pageName = setterArg;
        return this;
      }
      private String uniqueId;
      public Builder setUniqueId(String setterArg) {
        this.uniqueId = setterArg;
        return this;
      }
      private Map<String, Object> arguments;
      public Builder setArguments(Map<String, Object> setterArg) {
        this.arguments = setterArg;
        return this;
      }
      public CommonParams build() {
        CommonParams returnValue = new CommonParams();
        returnValue.setOpaque(opaque);
        returnValue.setKey(key);
        returnValue.setPageName(pageName);
        returnValue.setUniqueId(uniqueId);
        returnValue.setArguments(arguments);
        return returnValue;
      }
    }
    Map<String, Object> toMap() {
      Map<String, Object> toMapResult = new HashMap<>();
      toMapResult.put("opaque", opaque);
      toMapResult.put("key", key);
      toMapResult.put("pageName", pageName);
      toMapResult.put("uniqueId", uniqueId);
      toMapResult.put("arguments", arguments);
      return toMapResult;
    }
    static CommonParams fromMap(Map<String, Object> map) {
      CommonParams resultValue = new CommonParams();
      Object opaque = map.get("opaque");
      resultValue.setOpaque((Boolean)opaque);
      Object key = map.get("key");
      resultValue.setKey((String)key);
      Object pageName = map.get("pageName");
      resultValue.setPageName((String)pageName);
      Object uniqueId = map.get("uniqueId");
      resultValue.setUniqueId((String)uniqueId);
      Object arguments = map.get("arguments");
      resultValue.setArguments((Map<String, Object>)arguments);
      return resultValue;
    }
  }

  public static class StackInfo {
    private List<String> ids;
    public List<String> getIds() { return ids; }
    public void setIds(List<String> setterArg) {
      this.ids = setterArg;
    }

    private Map<String, FlutterContainer> containers;
    public Map<String, FlutterContainer> getContainers() { return containers; }
    public void setContainers(Map<String, FlutterContainer> setterArg) {
      this.containers = setterArg;
    }

    public static final class Builder {
      private List<String> ids;
      public Builder setIds(List<String> setterArg) {
        this.ids = setterArg;
        return this;
      }
      private Map<String, FlutterContainer> containers;
      public Builder setContainers(Map<String, FlutterContainer> setterArg) {
        this.containers = setterArg;
        return this;
      }
      public StackInfo build() {
        StackInfo returnValue = new StackInfo();
        returnValue.setIds(ids);
        returnValue.setContainers(containers);
        return returnValue;
      }
    }
    Map<String, Object> toMap() {
      Map<String, Object> toMapResult = new HashMap<>();
      toMapResult.put("ids", ids);
      toMapResult.put("containers", containers);
      return toMapResult;
    }
    static StackInfo fromMap(Map<String, Object> map) {
      StackInfo resultValue = new StackInfo();
      Object ids = map.get("ids");
      resultValue.setIds((List<String>)ids);
      Object containers = map.get("containers");
      resultValue.setContainers((Map<String, FlutterContainer>)containers);
      return resultValue;
    }
  }

  public static class FlutterContainer {
    private List<FlutterPage> pages;
    public List<FlutterPage> getPages() { return pages; }
    public void setPages(List<FlutterPage> setterArg) {
      this.pages = setterArg;
    }

    public static final class Builder {
      private List<FlutterPage> pages;
      public Builder setPages(List<FlutterPage> setterArg) {
        this.pages = setterArg;
        return this;
      }
      public FlutterContainer build() {
        FlutterContainer returnValue = new FlutterContainer();
        returnValue.setPages(pages);
        return returnValue;
      }
    }
    Map<String, Object> toMap() {
      Map<String, Object> toMapResult = new HashMap<>();
      toMapResult.put("pages", pages);
      return toMapResult;
    }
    static FlutterContainer fromMap(Map<String, Object> map) {
      FlutterContainer resultValue = new FlutterContainer();
      Object pages = map.get("pages");
      resultValue.setPages((List<FlutterPage>)pages);
      return resultValue;
    }
  }

  public static class FlutterPage {
    private Boolean withContainer;
    public Boolean getWithContainer() { return withContainer; }
    public void setWithContainer(Boolean setterArg) {
      this.withContainer = setterArg;
    }

    private String pageName;
    public String getPageName() { return pageName; }
    public void setPageName(String setterArg) {
      this.pageName = setterArg;
    }

    private String uniqueId;
    public String getUniqueId() { return uniqueId; }
    public void setUniqueId(String setterArg) {
      this.uniqueId = setterArg;
    }

    private Map<String, Object> arguments;
    public Map<String, Object> getArguments() { return arguments; }
    public void setArguments(Map<String, Object> setterArg) {
      this.arguments = setterArg;
    }

    public static final class Builder {
      private Boolean withContainer;
      public Builder setWithContainer(Boolean setterArg) {
        this.withContainer = setterArg;
        return this;
      }
      private String pageName;
      public Builder setPageName(String setterArg) {
        this.pageName = setterArg;
        return this;
      }
      private String uniqueId;
      public Builder setUniqueId(String setterArg) {
        this.uniqueId = setterArg;
        return this;
      }
      private Map<String, Object> arguments;
      public Builder setArguments(Map<String, Object> setterArg) {
        this.arguments = setterArg;
        return this;
      }
      public FlutterPage build() {
        FlutterPage returnValue = new FlutterPage();
        returnValue.setWithContainer(withContainer);
        returnValue.setPageName(pageName);
        returnValue.setUniqueId(uniqueId);
        returnValue.setArguments(arguments);
        return returnValue;
      }
    }
    Map<String, Object> toMap() {
      Map<String, Object> toMapResult = new HashMap<>();
      toMapResult.put("withContainer", withContainer);
      toMapResult.put("pageName", pageName);
      toMapResult.put("uniqueId", uniqueId);
      toMapResult.put("arguments", arguments);
      return toMapResult;
    }
    static FlutterPage fromMap(Map<String, Object> map) {
      FlutterPage resultValue = new FlutterPage();
      Object withContainer = map.get("withContainer");
      resultValue.setWithContainer((Boolean)withContainer);
      Object pageName = map.get("pageName");
      resultValue.setPageName((String)pageName);
      Object uniqueId = map.get("uniqueId");
      resultValue.setUniqueId((String)uniqueId);
      Object arguments = map.get("arguments");
      resultValue.setArguments((Map<String, Object>)arguments);
      return resultValue;
    }
  }

  public interface Result<T> {
    void success(T result);
    void error(Throwable error);
  }
  private static class NativeRouterApiCodec extends StandardMessageCodec {
    public static final NativeRouterApiCodec INSTANCE = new NativeRouterApiCodec();
    private NativeRouterApiCodec() {}
    @Override
    protected Object readValueOfType(byte type, ByteBuffer buffer) {
      switch (type) {
        case (byte)128:
          return CommonParams.fromMap((Map<String, Object>) readValue(buffer));

        case (byte)129:
          return FlutterContainer.fromMap((Map<String, Object>) readValue(buffer));

        case (byte)130:
          return FlutterPage.fromMap((Map<String, Object>) readValue(buffer));

        case (byte)131:
          return StackInfo.fromMap((Map<String, Object>) readValue(buffer));

        default:
          return super.readValueOfType(type, buffer);

      }
    }
    @Override
    protected void writeValue(ByteArrayOutputStream stream, Object value)     {
      if (value instanceof CommonParams) {
        stream.write(128);
        writeValue(stream, ((CommonParams) value).toMap());
      } else
      if (value instanceof FlutterContainer) {
        stream.write(129);
        writeValue(stream, ((FlutterContainer) value).toMap());
      } else
      if (value instanceof FlutterPage) {
        stream.write(130);
        writeValue(stream, ((FlutterPage) value).toMap());
      } else
      if (value instanceof StackInfo) {
        stream.write(131);
        writeValue(stream, ((StackInfo) value).toMap());
      } else
{
        super.writeValue(stream, value);
      }
    }
  }

  public interface NativeRouterApi {
    void pushNativeRoute(CommonParams param);
    void pushFlutterRoute(CommonParams param);
    void popRoute(CommonParams param, Result<Void> result);
    StackInfo getStackFromHost();
    void saveStackToHost(StackInfo stack);
    void sendEventToNative(CommonParams params);

    /** The codec used by NativeRouterApi. */
    static MessageCodec<Object> getCodec() {
      return NativeRouterApiCodec.INSTANCE;
    }

    /** Sets up an instance of `NativeRouterApi` to handle native fast bridge direct calls. */
    static void setup(NativeRouterApi api) {
      if (api == null) {
        FlutterJNI.setNativeFastMessageHandler(FLUTTER_BOOST_BRIDGE_NAME, null);
        return;
      }
      FlutterJNI.setNativeFastMessageHandler(FLUTTER_BOOST_BRIDGE_NAME, (method, message, replyId) -> {
        if (replyId < 0) {
          FlutterRouterApi.handleDartReply(replyId);
          return;
        }
        Object decoded = getCodec().decodeMessage(message);
        Map<String, Object> wrapped = new HashMap<>();
        try {
          switch (method) {
            case METHOD_PUSH_NATIVE_ROUTE: {
              ArrayList<Object> args = (ArrayList<Object>) decoded;
              CommonParams paramArg = (CommonParams) args.get(0);
              if (paramArg == null) {
                throw new NullPointerException("paramArg unexpectedly null.");
              }
              api.pushNativeRoute(paramArg);
              wrapped.put("result", null);
              returnDartCall(replyId, wrapped, getCodec());
              break;
            }
            case METHOD_PUSH_FLUTTER_ROUTE: {
              ArrayList<Object> args = (ArrayList<Object>) decoded;
              CommonParams paramArg = (CommonParams) args.get(0);
              if (paramArg == null) {
                throw new NullPointerException("paramArg unexpectedly null.");
              }
              api.pushFlutterRoute(paramArg);
              wrapped.put("result", null);
              returnDartCall(replyId, wrapped, getCodec());
              break;
            }
            case METHOD_POP_NATIVE_ROUTE: {
              ArrayList<Object> args = (ArrayList<Object>) decoded;
              CommonParams paramArg = (CommonParams) args.get(0);
              if (paramArg == null) {
                throw new NullPointerException("paramArg unexpectedly null.");
              }
              Result<Void> resultCallback = new Result<Void>() {
                public void success(Void result) {
                  Map<String, Object> resultWrapped = new HashMap<>();
                  resultWrapped.put("result", null);
                  returnDartCall(replyId, resultWrapped, getCodec());
                }
                public void error(Throwable error) {
                  Map<String, Object> errorWrapped = new HashMap<>();
                  errorWrapped.put("error", wrapError(error));
                  returnDartCall(replyId, errorWrapped, getCodec());
                }
              };
              api.popRoute(paramArg, resultCallback);
              break;
            }
            case METHOD_GET_STACK_FROM_HOST: {
              StackInfo output = api.getStackFromHost();
              wrapped.put("result", output);
              returnDartCall(replyId, wrapped, getCodec());
              break;
            }
            case METHOD_SAVE_STACK_TO_HOST: {
              ArrayList<Object> args = (ArrayList<Object>) decoded;
              StackInfo stackArg = (StackInfo) args.get(0);
              if (stackArg == null) {
                throw new NullPointerException("stackArg unexpectedly null.");
              }
              api.saveStackToHost(stackArg);
              wrapped.put("result", null);
              returnDartCall(replyId, wrapped, getCodec());
              break;
            }
            case METHOD_SEND_EVENT_TO_NATIVE: {
              ArrayList<Object> args = (ArrayList<Object>) decoded;
              CommonParams paramsArg = (CommonParams) args.get(0);
              if (paramsArg == null) {
                throw new NullPointerException("paramsArg unexpectedly null.");
              }
              api.sendEventToNative(paramsArg);
              wrapped.put("result", null);
              returnDartCall(replyId, wrapped, getCodec());
              break;
            }
            default:
              throw new RuntimeException("Unknown NativeRouterApi method: " + method);
          }
        } catch (Error | RuntimeException exception) {
          wrapped.put("error", wrapError(exception));
          returnDartCall(replyId, wrapped, getCodec());
        }
      });
    }
  }
  private static class FlutterRouterApiCodec extends StandardMessageCodec {
    public static final FlutterRouterApiCodec INSTANCE = new FlutterRouterApiCodec();
    private FlutterRouterApiCodec() {}
    @Override
    protected Object readValueOfType(byte type, ByteBuffer buffer) {
      switch (type) {
        case (byte)128:
          return CommonParams.fromMap((Map<String, Object>) readValue(buffer));

        default:
          return super.readValueOfType(type, buffer);

      }
    }
    @Override
    protected void writeValue(ByteArrayOutputStream stream, Object value)     {
      if (value instanceof CommonParams) {
        stream.write(128);
        writeValue(stream, ((CommonParams) value).toMap());
      } else
{
        super.writeValue(stream, value);
      }
    }
  }

  public static class FlutterRouterApi {
    private final FlutterEngine flutterEngine;
    private static final AtomicLong nextReplyId = new AtomicLong(-1);
    private static final Map<Long, Reply<Void>> pendingReplies = new ConcurrentHashMap<>();

    public FlutterRouterApi(FlutterEngine argFlutterEngine){
      this.flutterEngine = argFlutterEngine;
    }
    public interface Reply<T> {
      void reply(T reply);
    }
    static MessageCodec<Object> getCodec() {
      return FlutterRouterApiCodec.INSTANCE;
    }

    private void invokeDart(int method, Object message, Reply<Void> callback) {
      long replyId = nextReplyId.getAndDecrement();
      if (callback != null) {
        pendingReplies.put(replyId, callback);
      }
      ByteBuffer encoded = directBuffer(getCodec().encodeMessage(message));
      flutterEngine.invokeNativeFastMessageToDart(
          FLUTTER_BOOST_BRIDGE_NAME,
          FAST_MESSAGE_KIND_REQUEST,
          method,
          encoded,
          bufferLength(encoded),
          replyId);
    }

    static void handleDartReply(long replyId) {
      Reply<Void> callback = pendingReplies.remove(replyId);
      if (callback == null) {
        return;
      }
      callback.reply(null);
    }

    public void pushRoute(CommonParams paramArg, Reply<Void> callback) {
      invokeDart(METHOD_PUSH_ROUTE, new ArrayList<Object>(Arrays.asList(paramArg)), callback);
    }
    public void popRoute(CommonParams paramArg, Reply<Void> callback) {
      invokeDart(METHOD_POP_ROUTE, new ArrayList<Object>(Arrays.asList(paramArg)), callback);
    }
    public void removeRoute(CommonParams paramArg, Reply<Void> callback) {
      invokeDart(METHOD_REMOVE_ROUTE, new ArrayList<Object>(Arrays.asList(paramArg)), callback);
    }
    public void onForeground(CommonParams paramArg, Reply<Void> callback) {
      invokeDart(METHOD_ON_FOREGROUND, new ArrayList<Object>(Arrays.asList(paramArg)), callback);
    }
    public void onBackground(CommonParams paramArg, Reply<Void> callback) {
      invokeDart(METHOD_ON_BACKGROUND, new ArrayList<Object>(Arrays.asList(paramArg)), callback);
    }
    public void onNativeResult(CommonParams paramArg, Reply<Void> callback) {
      invokeDart(METHOD_ON_NATIVE_RESULT, new ArrayList<Object>(Arrays.asList(paramArg)), callback);
    }
    public void onContainerShow(CommonParams paramArg, Reply<Void> callback) {
      invokeDart(METHOD_ON_CONTAINER_SHOW, new ArrayList<Object>(Arrays.asList(paramArg)), callback);
    }
    public void onContainerHide(CommonParams paramArg, Reply<Void> callback) {
      invokeDart(METHOD_ON_CONTAINER_HIDE, new ArrayList<Object>(Arrays.asList(paramArg)), callback);
    }
    public void sendEventToFlutter(CommonParams paramArg, Reply<Void> callback) {
      invokeDart(METHOD_SEND_EVENT_TO_FLUTTER, new ArrayList<Object>(Arrays.asList(paramArg)), callback);
    }
    public void onBackPressed(Reply<Void> callback) {
      invokeDart(METHOD_ON_BACK_PRESSED, null, callback);
    }
  }
  private static Map<String, Object> wrapError(Throwable exception) {
    Map<String, Object> errorMap = new HashMap<>();
    errorMap.put("message", exception.toString());
    errorMap.put("code", exception.getClass().getSimpleName());
    errorMap.put("details", "Cause: " + exception.getCause() + ", Stacktrace: " + Log.getStackTraceString(exception));
    return errorMap;
  }
}
