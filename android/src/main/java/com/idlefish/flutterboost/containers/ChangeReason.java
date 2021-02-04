package com.idlefish.flutterboost.containers;

/**
 * The reason for a change in the View visibility state.
 *
 * These constants must be kept in sync with the constants defined in dart.
 */
public enum ChangeReason {
    Unspecified,
    RouteReorder,
    ViewPushed,
    ViewPopped,
    Foreground,
    Background,
}