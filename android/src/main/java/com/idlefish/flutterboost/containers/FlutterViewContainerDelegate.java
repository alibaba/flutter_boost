package com.idlefish.flutterboost.containers;

import android.app.Activity;
import android.content.Intent;
import androidx.annotation.NonNull;
import androidx.fragment.app.Fragment;
import com.idlefish.flutterboost.FlutterBoost;
import com.idlefish.flutterboost.interfaces.IFlutterViewContainer;
import com.idlefish.flutterboost.interfaces.IOperateSyncer;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

public class FlutterViewContainerDelegate implements IFlutterViewContainer {


    protected static final String EXTRA_URL = "url";
    protected static final String EXTRA_PARAMS = "params";

    private Activity mActivity;
    private Fragment mFragment;

    protected IOperateSyncer mSyncer;

    public FlutterViewContainerDelegate(Activity activity) {
        this.mActivity = activity;
    }

    public FlutterViewContainerDelegate(Fragment fragment) {
        this.mFragment = fragment;
        mActivity = fragment.getActivity();
    }



    @Override
    public Activity getContextActivity() {
        return mActivity;
    }


    public void onCreateView() {

        mSyncer = FlutterBoost.instance().containerManager().generateSyncer(this);
        mSyncer.onCreate();

    }


    void onStart() {
        mSyncer.onAppear();
    }

    void onPause() {

        mSyncer.onDisappear();
    }

    void onDestroyView() {
        mSyncer.onDestroy();

    }

    void onBackPressed() {
        mSyncer.onBackPressed();
    }

    void onNewIntent(@NonNull Intent intent) {
        mSyncer.onNewIntent(intent);

    }

    void onActivityResult(int requestCode, int resultCode, Intent data) {
        mSyncer.onActivityResult(requestCode, resultCode, data);
        Map<String, Object> result = null;
        if (data != null) {
            Serializable rlt = data.getSerializableExtra(RESULT_KEY);
            if (rlt instanceof Map) {
                result = (Map<String, Object>) rlt;
            }
        }

        mSyncer.onContainerResult(requestCode, resultCode, result);
    }

    void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        mSyncer.onRequestPermissionsResult(requestCode, permissions, grantResults);

    }

    @Override
    public void finishContainer(Map<String, Object> result) {

        if (result != null) {
            setBoostResult(mActivity, new HashMap<>(result));
            mActivity.finish();
        } else {
            mActivity.finish();
        }
    }

    public void setBoostResult(Activity activity, HashMap result) {
        Intent intent = new Intent();
        if (result != null) {
            intent.putExtra(IFlutterViewContainer.RESULT_KEY, result);
        }
        activity.setResult(Activity.RESULT_OK, intent);
    }

    @Override
    public String getContainerUrl() {
        if (mFragment != null) {
            return  mFragment.getArguments().getString(EXTRA_URL);

        }
        if (mActivity.getIntent().hasExtra(EXTRA_URL)) {
            return mActivity.getIntent().getStringExtra(EXTRA_URL);
        }
        return "";
    }

    @Override
    public Map getContainerUrlParams() {

        if (mFragment != null) {
            SerializableMap serializableMap = (SerializableMap)  mFragment.getArguments().getSerializable(EXTRA_PARAMS);
            return serializableMap.getMap() ;
        }

        if (mActivity.getIntent().hasExtra(EXTRA_PARAMS)) {
            SerializableMap serializableMap = (SerializableMap) mActivity.getIntent().getSerializableExtra(EXTRA_PARAMS);
            return serializableMap.getMap();
        }
        return null;
    }

    public static class SerializableMap implements Serializable {

        private Map<String, Object> map;

        public Map<String, Object> getMap() {
            return map;
        }

        public void setMap(Map<String, Object> map) {
            this.map = map;
        }
    }

    @Override
    public void onContainerShown() {

    }

    @Override
    public void onContainerHidden() {

    }
}
