package com.idlefish.flutterboost;

public class FlutterBoostOptions {
    private final String initialRoute;
    private final String dartEntrypoint;
    private final String[] shellArgs;

    private FlutterBoostOptions(Builder builder) {
        this.initialRoute = builder.initialRoute;
        this.dartEntrypoint = builder.dartEntrypoint;
        this.shellArgs = builder.shellArgs;
    }

    public static FlutterBoostOptions createDefault() {
      return new Builder().build();
    }

    public String initialRoute() {
        return initialRoute;
    }

    public String dartEntrypoint() {
        return dartEntrypoint;
    }

    public String[] shellArgs() {
        return shellArgs;
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
                ", shellArgs:" + sb.toString();
    }

    public static class Builder {
        private String initialRoute = "/";
        private String dartEntrypoint = "main";
        private String[] shellArgs;

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

        public Builder shellArgs(String[] shellArgs){
            this.shellArgs = shellArgs;
            return this;
        }

        public FlutterBoostOptions build() {
            FlutterBoostOptions options = new FlutterBoostOptions(this);
            return options;
        }
    }
}