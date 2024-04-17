package com.example.openim;

import com.alibaba.fastjson.JSONObject;
import io.dcloud.feature.uniapp.bridge.UniJSCallback;
import open_im_sdk_callback.Base;


public class BaseImpl implements Base {
    UniJSCallback callback;

    public BaseImpl(UniJSCallback callback) {
        this.callback = callback;
    }


    @Override
    public void onError(int i, String s) {
        JSONObject data = new JSONObject();
        data.put("data","");
        data.put("errMsg", s);
        data.put("errCode",i);
        callback.invoke(data);
    }

    @Override
    public void onSuccess(String s) {
        JSONObject data = new JSONObject();
        data.put("data", s);
        data.put("errCode",0);
        data.put("errMsg","");
        callback.invoke(data);
    }
}