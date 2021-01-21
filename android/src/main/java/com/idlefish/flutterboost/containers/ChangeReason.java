package com.idlefish.flutterboost.containers;

import androidx.annotation.IntDef;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

/**
 * The reason for a change in the View visibility state.
 *
 * These constants must be kept in sync with the constants defined in dart.
 */
@IntDef({ChangeReason.UNSPECIFIED, ChangeReason.PUSH_ROUTE, ChangeReason.POP_ROUTE,
        ChangeReason.PUSH_VIEW, ChangeReason.POP_VIEW, ChangeReason.SWITCH_TAB,
        ChangeReason.FOREGROUND, ChangeReason.BACKGROUND})
@Retention(RetentionPolicy.SOURCE)
public @interface ChangeReason {
    int UNSPECIFIED = 0;
    int PUSH_ROUTE = 1;
    int POP_ROUTE = 2;
    int PUSH_VIEW = 3;
    int POP_VIEW = 4;
    int SWITCH_TAB = 5;
    int FOREGROUND = 6;
    int BACKGROUND = 7;
}