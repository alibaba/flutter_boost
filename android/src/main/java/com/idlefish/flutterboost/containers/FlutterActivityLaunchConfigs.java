package com.idlefish.flutterboost.containers;

public class FlutterActivityLaunchConfigs {

    // Intent extra arguments.
    static final String EXTRA_BACKGROUND_MODE = "background_mode";
    static final String EXTRA_CACHED_ENGINE_ID = "cached_engine_id";
    static final String EXTRA_DESTROY_ENGINE_WITH_ACTIVITY =
        "destroy_engine_with_activity";
    public static final String EXTRA_URL = "url";
    public static final String EXTRA_URL_PARAM = "url_param";
    public static final String EXTRA_UNIQUE_ID = "unique_id";

    static final String DEFAULT_BACKGROUND_MODE = io.flutter.embedding.android.FlutterActivityLaunchConfigs.BackgroundMode.opaque.name();

    // for onActivityResult
    public static final String ACTIVITY_RESULT_KEY = "ActivityResult";

    private FlutterActivityLaunchConfigs() {}
}
