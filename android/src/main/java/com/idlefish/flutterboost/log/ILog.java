package com.idlefish.flutterboost.log;

public interface ILog {
    public enum LogLevelEnum {
        VERBOSE(0, "V"), DEBUG(1, "D"), INFO(2, "I"), WARNING(3, "W"), ERROR(4, "E");
        private String logLevelName;
        private int loglevel;

        LogLevelEnum(int loglevel, String name) {
            this.loglevel = loglevel;
            this.logLevelName = name;
        }

        public String getLogLevelName() {
            return logLevelName;
        }

        public int getLoglevel() {
            return loglevel;
        }
    }

    void d(String tag, String msg);

    void d(String tag, String msg, Throwable throwable);

    void e(String tag, String msg);

    void e(String tag, String msg, Throwable throwable);

    void i(String tag, String msg);

    void i(String tag, String msg, Throwable throwable);

    void v(String tag, String msg);

    void v(String tag, String msg, Throwable throwable);

    void w(String tag, String msg);

    void w(String tag, String msg, Throwable throwable);

    boolean isLogLevelEnabled(int level);
}
