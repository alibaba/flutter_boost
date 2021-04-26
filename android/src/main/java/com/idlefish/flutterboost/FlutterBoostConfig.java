package com.idlefish.flutterboost;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.FlutterShellArgs;

//The flutter boost config class.
public class FlutterBoostConfig {
    //default route is "/"
    @NonNull
    private String initialRoute = "/";

    //default entry point name is "main"
    @NonNull
    private String dartEntryPointFunctionName = "main";

    //the dartVM arguments
    private FlutterShellArgs shellArgs = null;

    ///The flutter engine,if you don't set engine,flutter boost will create a default engine.
    private FlutterEngine engine;

    /**
     * private initializer
     */
    private FlutterBoostConfig() {
    }

    /**
     * Get a default instance of FlutterBoostConfig
     *
     * @return FlutterBoostConfig
     */
    public static FlutterBoostConfig getDefaultConfig() {
        return new FlutterBoostConfig();
    }


    /**
     * Set initialRoute
     *
     * @param initialRoute initialRoute string
     * @return FlutterBoostConfig
     */
    public FlutterBoostConfig initialRoute(String initialRoute) {
        this.initialRoute = initialRoute;
        return this;
    }

    /**
     * Set dart run entryPoint
     *
     * @param dartEntryPointFunctionName the entry point name
     * @return FlutterBoostConfig
     */
    public FlutterBoostConfig entryPoint(String dartEntryPointFunctionName) {
        this.dartEntryPointFunctionName = dartEntryPointFunctionName;
        return this;
    }

    /**
     * Set flutter engine
     * If you don't set this param,flutter boost will create a default engine
     *
     * @param engine the engine you want to set
     * @return FlutterBoostConfig
     */
    public FlutterBoostConfig engine(FlutterEngine engine) {
        this.engine = engine;
        return this;
    }

    /**
     * Set the arguments passing to dartVM
     *
     * @param shellArgs FlutterShellArgs instance
     * @return FlutterBoostConfig
     */

    public FlutterBoostConfig flutterShellArgs(FlutterShellArgs shellArgs) {
        this.shellArgs = shellArgs;
        return this;
    }


    /**
     * Getter and setter below
     */


    @NonNull
    public String getInitialRoute() {
        return initialRoute;
    }

    @NonNull
    public String getDartEntryPointFunctionName() {
        return dartEntryPointFunctionName;
    }


    @Nullable
    public FlutterShellArgs getShellArgs() {
        return shellArgs;
    }

    @Nullable
    public FlutterEngine getEngine() {
        return engine;
    }
}
