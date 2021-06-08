package com.idlefish.flutterboost;

import java.util.Map;

public class FlutterBoostRouteOptions {
    private final String pageName;
    private final Map<String, Object> arguments;
    private final int requestCode;
    private final String uniqueId;

    private FlutterBoostRouteOptions(FlutterBoostRouteOptions.Builder builder) {
        this.pageName = builder.pageName;
        this.arguments = builder.arguments;
        this.requestCode = builder.requestCode;
        this.uniqueId = builder.uniqueId;
    }

    public String pageName() {
        return pageName;
    }

    public Map<String, Object> arguments() {
        return arguments;
    }

    public int requestCode() {
        return requestCode;
    }

    public String uniqueId() {
        return uniqueId;
    }

    public static class Builder {
        private String pageName;
        private Map<String, Object> arguments;
        private int requestCode;
        private String uniqueId;

        public Builder() {
        }

        public FlutterBoostRouteOptions.Builder pageName(String pageName) {
            this.pageName = pageName;
            return this;
        }

        public FlutterBoostRouteOptions.Builder arguments(Map<String, Object> arguments) {
            this.arguments = arguments;
            return this;
        }

        public FlutterBoostRouteOptions.Builder requestCode(int requestCode) {
            this.requestCode = requestCode;
            return this;
        }

        public FlutterBoostRouteOptions.Builder uniqueId(String uniqueId) {
            this.uniqueId = uniqueId;
            return this;
        }

        public FlutterBoostRouteOptions build() {
            return new FlutterBoostRouteOptions(this);
        }
    }

}