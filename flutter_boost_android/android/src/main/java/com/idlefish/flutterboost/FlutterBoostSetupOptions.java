// Copyright (c) 2019 Alibaba Group. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.idlefish.flutterboost;

import java.util.List;

import io.flutter.embedding.android.FlutterEngineProvider;

public class FlutterBoostSetupOptions {
    private final String initialRoute;
    private final String dartEntrypoint;
    private final List<String> dartEntrypointArgs;
    private final String[] shellArgs;
    private final boolean isDebugLoggingEnabled;
    private final boolean shouldOverrideBackForegroundEvent;
    private FlutterEngineProvider flutterEngineProvider;

    private FlutterBoostSetupOptions(Builder builder) {
        this.initialRoute = builder.initialRoute;
        this.dartEntrypoint = builder.dartEntrypoint;
        this.dartEntrypointArgs = builder.dartEntrypointArgs;
        this.shellArgs = builder.shellArgs;
        this.isDebugLoggingEnabled = builder.isDebugLoggingEnabled;
        this.shouldOverrideBackForegroundEvent = builder.shouldOverrideBackForegroundEvent;
        this.flutterEngineProvider = builder.flutterEngineProvider;
    }

    public static FlutterBoostSetupOptions createDefault() {
      return new Builder().build();
    }

    public String initialRoute() {
        return initialRoute;
    }

    public String dartEntrypoint() {
        return dartEntrypoint;
    }

    public List<String> dartEntrypointArgs() {
        return dartEntrypointArgs;
    }

    public String[] shellArgs() {
        return shellArgs;
    }

    public FlutterEngineProvider flutterEngineProvider() {
        return flutterEngineProvider;
    }

    public boolean isDebugLoggingEnabled() {
        return isDebugLoggingEnabled;
    }

    public boolean shouldOverrideBackForegroundEvent() {
        return shouldOverrideBackForegroundEvent;
    }

    @Override
    public String toString() {
        StringBuilder sb = new StringBuilder();
        sb.append('[');
        if (shellArgs == null || shellArgs.length == 0) {
            sb.append(']');
        } else {
            for (int i = 0; ; i++) {
                sb.append(String.valueOf(shellArgs[i]));
                if (i == shellArgs.length - 1) {
                    sb.append(']');
                    break;
                }
                sb.append(", ");
            }
        }
        return "initialRoute:" + this.initialRoute +
                ", dartEntrypoint:" + this.dartEntrypoint +
                ", isDebugLoggingEnabled: " + this.isDebugLoggingEnabled +
                ", shouldOverrideBackForegroundEvent:" + this.shouldOverrideBackForegroundEvent +
                ", shellArgs:" + sb.toString();
    }

    public static class Builder {
        private String initialRoute = "/";
        private String dartEntrypoint = "main";
        private List<String> dartEntrypointArgs;
        private boolean isDebugLoggingEnabled = false;
        private boolean shouldOverrideBackForegroundEvent = false;
        private String[] shellArgs;
        private FlutterEngineProvider flutterEngineProvider;

        public Builder() {
        }

        public Builder initialRoute(String initialRoute){
            this.initialRoute = initialRoute;
            return this;
        }

        public Builder dartEntrypoint(String dartEntrypoint){
            this.dartEntrypoint = dartEntrypoint;
            return this;
        }

        public Builder dartEntrypointArgs(List<String> args) {
            this.dartEntrypointArgs = args;
            return this;
        }

        public Builder shellArgs(String[] shellArgs){
            this.shellArgs = shellArgs;
            return this;
        }

        public Builder flutterEngineProvider(FlutterEngineProvider flutterEngineProvider) {
            this.flutterEngineProvider = flutterEngineProvider;
            return this;
        }

        public Builder isDebugLoggingEnabled(boolean enable) {
            isDebugLoggingEnabled = enable;
            return this;
        }

        // Determines whether to override back/foreground event.
        public Builder shouldOverrideBackForegroundEvent(boolean override) {
            shouldOverrideBackForegroundEvent = override;
            return this;
        }

        public FlutterBoostSetupOptions build() {
            FlutterBoostSetupOptions options = new FlutterBoostSetupOptions(this);
            return options;
        }
    }
}