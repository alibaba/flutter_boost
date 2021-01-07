package com.idlefish.flutterboost.example.tab;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.Nullable;

import com.idlefish.flutterboost.BoostNavigator;
import com.idlefish.flutterboost.containers.FlutterBoostFragment;

public class MsgFlutterFragment extends FlutterBoostFragment {

    private String uniqueId;

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {

        uniqueId = BoostNavigator.generateUniqueId("tab_message");
        BoostNavigator.showTabRoute("maintab", uniqueId, "tab_message", null);
        this.setContainerInfo(uniqueId,"tab_message");
        return super.onCreateView(inflater, container, savedInstanceState);
    }

    @Override
    public void onResume() {
        super.onResume();
    }

    @Override
    public void onHiddenChanged(boolean hidden) {
        if (!hidden) {
            BoostNavigator.showTabRoute("maintab", uniqueId, "tab_message", null);
        }
        super.onHiddenChanged(hidden);

    }

}
