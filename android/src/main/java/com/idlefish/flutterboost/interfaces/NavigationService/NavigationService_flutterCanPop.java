package com.taobao.idlefish.flutterboost.NavigationService;

import android.util.Log;

import com.taobao.idlefish.flutterboost.FlutterBoostPlugin;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import fleamarket.taobao.com.xservicekit.handler.MessageHandler;
import fleamarket.taobao.com.xservicekit.handler.MessageResult;
import fleamarket.taobao.com.xservicekit.service.ServiceGateway;

public class NavigationService_flutterCanPop implements MessageHandler<Boolean>{
    private Object mContext = null;


    private boolean onCall(MessageResult<Boolean> result,Boolean canPop){
        return true;
    }

    @Override
    public boolean onMethodCall(String name, Map args, MessageResult<Boolean> result) {
        return this.onCall(result,(Boolean) args.get("canPop"));
    }

    @Override
    public List<String> handleMessageNames() {
        List<String> h = new ArrayList<>();
        h.add("flutterCanPop");
        return h;
    }
    @Override
    public Object getContext() {
        return mContext;
    }

    @Override
    public void setContext(Object obj) {
        mContext = obj;
    }
    @Override
    public String service() {
        return "NavigationService";
    }

    public static void register(){
        ServiceGateway.sharedInstance().registerHandler(new NavigationService_flutterCanPop());
    }


}