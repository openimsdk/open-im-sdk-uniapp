package com.example.openim;

import android.util.Log;

import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;

import io.dcloud.feature.uniapp.annotation.UniJSMethod;
import io.dcloud.feature.uniapp.bridge.UniJSCallback;
import io.dcloud.feature.uniapp.common.UniModule;

import java.util.HashMap;
import java.util.Map;

import open_im_sdk.Open_im_sdk;
import open_im_sdk_callback.OnAdvancedMsgListener;
import open_im_sdk_callback.OnBatchMsgListener;
import open_im_sdk_callback.OnConnListener;
import open_im_sdk_callback.OnConversationListener;
import open_im_sdk_callback.OnCustomBusinessListener;
import open_im_sdk_callback.OnFriendshipListener;
import open_im_sdk_callback.OnGroupListener;
import open_im_sdk_callback.OnUserListener;
import open_im_sdk_callback.SendMsgCallBack;
import open_im_sdk_callback.UploadFileCallback;
import open_im_sdk_callback.UploadLogProgress;

public class OpenIMSDK extends UniModule {
    private Boolean initFlag;
    public OpenIMSDK() {
        initFlag = false;
    }

    @UniJSMethod(
            uiThread = false
    )
    public Boolean initSDK(String operationID, JSONObject options) {
        if(this.initFlag) return true;
        OnConnListener connListener = new OnConnListener() {
            public void onConnectFailed(int i, String s) {
                Map<String, Object> params = new HashMap();
                params.put("errCode", i);
                params.put("errMsg", s);
                OpenIMSDK.this.mUniSDKInstance.fireGlobalEventCallback("onConnectFailed", params);
            }

            public void onConnectSuccess() {
                Map<String, Object> params = new HashMap();
                params.put("errCode", 0);
                params.put("errMsg", "");
                OpenIMSDK.this.mUniSDKInstance.fireGlobalEventCallback("onConnectSuccess", params);
            }

            public void onConnecting() {
                Map<String, Object> params = new HashMap();
                params.put("errCode", 0);
                params.put("errMsg", "");
                OpenIMSDK.this.mUniSDKInstance.fireGlobalEventCallback("onConnecting", params);
            }

            public void onKickedOffline() {
                Map<String, Object> params = new HashMap();
                params.put("errCode", 0);
                params.put("errMsg", "");
                OpenIMSDK.this.mUniSDKInstance.fireGlobalEventCallback("onKickedOffline", params);
            }

            public void onUserTokenExpired() {
                Map<String, Object> params = new HashMap();
                params.put("errCode", 0);
                params.put("errMsg", "");
                OpenIMSDK.this.mUniSDKInstance.fireGlobalEventCallback("onUserTokenExpired", params);
            }
        };
        Boolean flag = Open_im_sdk.initSDK(connListener, operationID, options.toJSONString());
        if(flag){
            _setUserListener();
            _setAdvancedMsgListener();
            _setBatchMsgListener();
            _setConversationListener();
            _setFriendListener();
            _setGroupListener();
            _setCustomBusinessListener();
        }
        this.initFlag = flag;
        return flag;
    }

    @UniJSMethod(
            uiThread = false
    )
    public void unInitSDK(String operationID) {
        Open_im_sdk.unInitSDK(operationID);
    }

    @UniJSMethod(
            uiThread = false
    )
    public void login(String operationID, JSONObject options, UniJSCallback callback) {
        Open_im_sdk.getLoginStatus(operationID);
        Open_im_sdk.login(new BaseImpl(callback), operationID, options.getString("userID"), options.getString("token"));
    }

    @UniJSMethod(
            uiThread = false
    )
    public void logout(String operationID, UniJSCallback callback) {
        Open_im_sdk.logout(new BaseImpl(callback), operationID);
    }

    @UniJSMethod(
            uiThread = false
    )
    public void setAppBackgroundStatus(String operationID,boolean isBackground, UniJSCallback callback) {
        Log.e("setAppBackgroundStatus","setAppBackgroundStatus::::::::::");
        Open_im_sdk.setAppBackgroundStatus(new BaseImpl(callback), operationID,isBackground);
    }

    @UniJSMethod(
            uiThread = false
    )
    public void networkStatusChanged(String operationID, UniJSCallback callback) {
        Open_im_sdk.networkStatusChanged(new BaseImpl(callback), operationID);
    }

    @UniJSMethod(
            uiThread = false
    )
    public long getLoginStatus(String operationID) {
        return Open_im_sdk.getLoginStatus(operationID);
    }

    @UniJSMethod(
            uiThread = false
    )
    public String getLoginUserID() {
        return Open_im_sdk.getLoginUserID();
    }

    // user
    @UniJSMethod(
            uiThread = false
    )
    public void _setUserListener() {
        OnUserListener userListener = new OnUserListener() {
            @Override
            public void onSelfInfoUpdated(String s) {
                Map<String, Object> params = new HashMap();
                params.put("data", JSONObject.parseObject(s));
                OpenIMSDK.this.mUniSDKInstance.fireGlobalEventCallback("onSelfInfoUpdated", params);
            }

            @Override
            public void onUserStatusChanged(String s) {
                Map<String, Object> params = new HashMap();
                params.put("data", JSONObject.parseObject(s));
                OpenIMSDK.this.mUniSDKInstance.fireGlobalEventCallback("onUserStatusChanged", params);
            }
        };
        Open_im_sdk.setUserListener(userListener);
    }

    @UniJSMethod(
            uiThread = false
    )
    public void getUsersInfo(String operationID, JSONArray userIDList, UniJSCallback callback) {
        Open_im_sdk.getUsersInfo(new BaseImpl(callback), operationID, userIDList.toJSONString());
    }

    @UniJSMethod(
            uiThread = false
    )
    public void getUsersInfoWithCache(String operationID, JSONObject options, UniJSCallback callback) {
        Open_im_sdk.getUsersInfoWithCache(new BaseImpl(callback), operationID, options.getJSONArray("userIDList").toJSONString(), options.getString("groupID"));
    }

    @UniJSMethod(
            uiThread = false
    )
    public void setSelfInfo(String operationID, JSONObject userInfo, UniJSCallback callback) {
        Open_im_sdk.setSelfInfo(new BaseImpl(callback), operationID, userInfo.toJSONString());
    }

    @UniJSMethod(
            uiThread = false
    )
    public void getSelfUserInfo(String operationID, UniJSCallback callback) {
        Open_im_sdk.getSelfUserInfo(new BaseImpl(callback), operationID);
    }

    @UniJSMethod(
            uiThread = false
    )
    public void getUserStatus(String operationID,JSONArray userIDList, UniJSCallback callback) {
        Open_im_sdk.getUserStatus(new BaseImpl(callback), operationID, userIDList.toJSONString());
    }

    @UniJSMethod(
            uiThread = false
    )
    public void subscribeUsersStatus(String operationID,JSONArray userIDList, UniJSCallback callback) {
        Open_im_sdk.subscribeUsersStatus(new BaseImpl(callback), operationID, userIDList.toJSONString());
    }

    @UniJSMethod(
            uiThread = false
    )
    public void unsubscribeUsersStatus(String operationID,JSONArray userIDList, UniJSCallback callback) {
        Open_im_sdk.unsubscribeUsersStatus(new BaseImpl(callback), operationID, userIDList.toJSONString());
    }

    @UniJSMethod(
            uiThread = false
    )
    public void getSubscribeUsersStatus(String operationID, UniJSCallback callback) {
        Open_im_sdk.getSubscribeUsersStatus(new BaseImpl(callback), operationID);
    }

    // conversation & message
    @UniJSMethod(
            uiThread = false
    )
    public void _setAdvancedMsgListener() {
        OnAdvancedMsgListener advancedMsgListener = new OnAdvancedMsgListener() {
            @Override
            public void onMsgDeleted(String s) {
                Map<String, Object> params = new HashMap();
                params.put("data", JSONObject.parseObject(s));
                OpenIMSDK.this.mUniSDKInstance.fireGlobalEventCallback("onMsgDeleted", params);
            }

            @Override
            public void onNewRecvMessageRevoked(String s) {
                Map<String, Object> params = new HashMap();
                params.put("data", JSONObject.parseObject(s));
                OpenIMSDK.this.mUniSDKInstance.fireGlobalEventCallback("onNewRecvMessageRevoked", params);
            }

            public void onRecvC2CReadReceipt(String s) {
                Map<String, Object> params = new HashMap();
                params.put("data", JSONArray.parseArray(s));
                OpenIMSDK.this.mUniSDKInstance.fireGlobalEventCallback("onRecvC2CReadReceipt", params);
            }

            public void onRecvGroupReadReceipt(String s) {
                Map<String, Object> params = new HashMap();
                params.put("data", JSONArray.parseObject(s));
                OpenIMSDK.this.mUniSDKInstance.fireGlobalEventCallback("onRecvGroupReadReceipt", params);
            }

            @Override
            public void onRecvMessageExtensionsAdded(String s, String s1) {

            }

            @Override
            public void onRecvMessageExtensionsChanged(String s, String s1) {

            }

            @Override
            public void onRecvMessageExtensionsDeleted(String s, String s1) {

            }

            public void onRecvNewMessage(String s) {
                Map<String, Object> params = new HashMap();
                params.put("data", JSONObject.parseObject(s));
                OpenIMSDK.this.mUniSDKInstance.fireGlobalEventCallback("onRecvNewMessage", params);
            }

            @Override
            public void onRecvOfflineNewMessage(String s) {
                Map<String, Object> params = new HashMap();
                params.put("data", JSONObject.parseObject(s));
                OpenIMSDK.this.mUniSDKInstance.fireGlobalEventCallback("onRecvOfflineNewMessage", params);
            }

            @Override
            public void onRecvOnlineOnlyMessage(String s) {

            }
        };
        Open_im_sdk.setAdvancedMsgListener(advancedMsgListener);
    }

    @UniJSMethod(
            uiThread = false
    )
    public void _setBatchMsgListener() {
        OnBatchMsgListener batchMsgListener = new OnBatchMsgListener() {
            @Override
            public void onRecvNewMessages(String s) {
                Map<String, Object> params = new HashMap();
                params.put("data", JSONArray.parseArray(s));
                OpenIMSDK.this.mUniSDKInstance.fireGlobalEventCallback("onRecvNewMessages", params);
            }

            @Override
            public void onRecvOfflineNewMessages(String s) {
                Map<String, Object> params = new HashMap();
                params.put("data", JSONArray.parseArray(s));
                OpenIMSDK.this.mUniSDKInstance.fireGlobalEventCallback("onRecvOfflineNewMessages", params);
            }
        };
        Open_im_sdk.setBatchMsgListener(batchMsgListener);
    }

    @UniJSMethod(
            uiThread = false
    )
    public void _setConversationListener() {
        OnConversationListener conversationListener = new OnConversationListener() {
            public void onConversationChanged(String s) {
                Log.e("onConversationChanged",s);
                Map<String, Object> params = new HashMap();
                params.put("data", JSONObject.parseArray(s));
                OpenIMSDK.this.mUniSDKInstance.fireGlobalEventCallback("onConversationChanged", params);
            }

            @Override
            public void onConversationUserInputStatusChanged(String s) {

            }

            public void onNewConversation(String s) {
                Map<String, Object> params = new HashMap();
                params.put("data", JSONObject.parseArray(s));
                OpenIMSDK.this.mUniSDKInstance.fireGlobalEventCallback("onNewConversation", params);
            }

            public void onSyncServerFailed() {
                Map<String, Object> params = new HashMap();
                params.put("errCode", 0);
                params.put("errMsg", "");
                OpenIMSDK.this.mUniSDKInstance.fireGlobalEventCallback("onSyncServerFailed", params);
            }

            public void onSyncServerFinish() {
                Map<String, Object> params = new HashMap();
                params.put("errCode", 0);
                params.put("errMsg", "");
                OpenIMSDK.this.mUniSDKInstance.fireGlobalEventCallback("onSyncServerFinish", params);
            }

            public void onSyncServerStart() {
                Map<String, Object> params = new HashMap();
                params.put("errCode", 0);
                params.put("errMsg", "");
                OpenIMSDK.this.mUniSDKInstance.fireGlobalEventCallback("onSyncServerStart", params);
            }

            public void onTotalUnreadMessageCountChanged(int i) {
                Map<String, Object> params = new HashMap();
                params.put("data", i);
                OpenIMSDK.this.mUniSDKInstance.fireGlobalEventCallback("onTotalUnreadMessageCountChanged", params);
            }
        };
        Open_im_sdk.setConversationListener(conversationListener);
    }

    @UniJSMethod(
            uiThread = false
    )
    public void getAllConversationList(String operationID, UniJSCallback callback) {
        Open_im_sdk.getAllConversationList(new BaseImpl(callback), operationID);
    }

    @UniJSMethod(
            uiThread = false
    )
    public void getConversationListSplit(String operationID, JSONObject options, UniJSCallback callback) {
        Open_im_sdk.getConversationListSplit(new BaseImpl(callback), operationID, options.getInteger("offset"), options.getInteger("count"));
    }

    @UniJSMethod(
            uiThread = false
    )
    public void getOneConversation(String operationID, JSONObject options, UniJSCallback callback) {
        Open_im_sdk.getOneConversation(new BaseImpl(callback), operationID, options.getInteger("sessionType"), options.getString("sourceID"));
    }

    @UniJSMethod(
            uiThread = false
    )
    public void getMultipleConversation(String operationID, JSONArray conversationIDList, UniJSCallback callback) {
        Open_im_sdk.getMultipleConversation(new BaseImpl(callback), operationID, conversationIDList.toJSONString());
    }

    @UniJSMethod(
            uiThread = false
    )
    public void setGlobalRecvMessageOpt(String operationID, Integer opt, UniJSCallback callback) {
        Open_im_sdk.setGlobalRecvMessageOpt(new BaseImpl(callback), operationID, opt );
    }

    @UniJSMethod(
            uiThread = false
    )
    public void hideConversation(String operationID, String conversationID, UniJSCallback callback) {
        Open_im_sdk.hideConversation(new BaseImpl(callback), operationID, conversationID );
    }

    @UniJSMethod(
            uiThread = false
    )
    public void getConversationRecvMessageOpt(String operationID, JSONArray conversationIDList, UniJSCallback callback) {
        Open_im_sdk.getConversationRecvMessageOpt(new BaseImpl(callback), operationID, conversationIDList.toJSONString());
    }

    @UniJSMethod(
            uiThread = false
    )
    public void setConversationDraft(String operationID, JSONObject options, UniJSCallback callback) {
        Open_im_sdk.setConversationDraft(new BaseImpl(callback), operationID, options.getString("conversationID"), options.getString("draftText"));
    }

    @UniJSMethod(
            uiThread = false
    )
    public void resetConversationGroupAtType(String operationID, String conversationID, UniJSCallback callback) {
        Open_im_sdk.resetConversationGroupAtType(new BaseImpl(callback), operationID, conversationID );
    }

    @UniJSMethod(
            uiThread = false
    )
    public void pinConversation(String operationID, JSONObject options, UniJSCallback callback) {
        Open_im_sdk.pinConversation(new BaseImpl(callback), operationID, options.getString("conversationID"), options.getBoolean("isPinned"));
    }

    @UniJSMethod(
            uiThread = false
    )
    public void setConversationPrivateChat(String operationID, JSONObject options, UniJSCallback callback) {
        Open_im_sdk.setConversationPrivateChat(new BaseImpl(callback), operationID, options.getString("conversationID"), options.getBoolean("isPrivate"));
    }

    @UniJSMethod(
            uiThread = false
    )
    public void setConversationBurnDuration(String operationID, JSONObject options, UniJSCallback callback){
        Open_im_sdk.setConversationBurnDuration(new BaseImpl(callback), operationID, options.getString("conversationID"), options.getInteger("burnDuration"));
    }

    @UniJSMethod(
            uiThread = false
    )
    public void setConversationRecvMessageOpt(String operationID, JSONObject options, UniJSCallback callback) {
        Open_im_sdk.setConversationRecvMessageOpt(new BaseImpl(callback), operationID, options.getString("conversationID"), options.getInteger("opt"));
    }

    @UniJSMethod(
            uiThread = false
    )
    public void getTotalUnreadMsgCount(String operationID, UniJSCallback callback) {
        Open_im_sdk.getTotalUnreadMsgCount(new BaseImpl(callback), operationID);
    }

    @UniJSMethod(
            uiThread = false
    )
    public String getAtAllTag(String OperationID) {
        return Open_im_sdk.getAtAllTag(OperationID);
    }

    @UniJSMethod(
            uiThread = false
    )
    public String createAdvancedTextMessage(String OperationID, JSONObject options) {
        return Open_im_sdk.createAdvancedTextMessage(OperationID, options.getString("text"),options.getJSONArray("messageEntityList").toJSONString());
    }

    @UniJSMethod(
            uiThread = false
    )
    public String createTextAtMessage(String OperationID, JSONObject options) {
        String messageJson = "";
        Object message = options.get("message");
        if (message instanceof JSONObject) {
            messageJson = ((JSONObject)message).toJSONString();
        }
        return Open_im_sdk.createTextAtMessage(OperationID, options.getString("text"), options.getJSONArray("atUserIDList").toJSONString(), options.getJSONArray("atUsersInfo").toJSONString(), messageJson);
    }

    @UniJSMethod(
            uiThread = false
    )
    public String createTextMessage(String OperationID, String textMsg) {
        return Open_im_sdk.createTextMessage(OperationID, textMsg);
    }

    @UniJSMethod(
            uiThread = false
    )
    public String createLocationMessage(String OperationID, JSONObject options) {
        return Open_im_sdk.createLocationMessage(OperationID, options.getString("description"), options.getDoubleValue("longitude"), options.getDoubleValue("latitude"));
    }

    @UniJSMethod(
            uiThread = false
    )
    public String createCustomMessage(String operationID, JSONObject options) {
        return Open_im_sdk.createCustomMessage(operationID, options.getString("data"), options.getString("extension"), options.getString("description"));
    }

    @UniJSMethod(
            uiThread = false
    )
    public String createQuoteMessage(String OperationID, JSONObject options) {
        return Open_im_sdk.createQuoteMessage(OperationID, options.getString("text"), options.getJSONObject("message").toJSONString());
    }

    @UniJSMethod(
            uiThread = false
    )
    public String createAdvancedQuoteMessage(String OperationID, JSONObject options) {
        return Open_im_sdk.createAdvancedQuoteMessage(OperationID, options.getString("text"), options.getJSONObject("message").toJSONString(),options.getJSONArray("messageEntityList").toJSONString());
    }

    @UniJSMethod(
            uiThread = false
    )
    public String createCardMessage(String operationID, JSONObject cardElem) {
        return Open_im_sdk.createCardMessage(operationID, cardElem.toJSONString());
    }


    @UniJSMethod(
            uiThread = false
    )
    public String createImageMessage(String OperationID, String imagePath) {
        return Open_im_sdk.createImageMessage(OperationID, imagePath);
    }

    @UniJSMethod(
            uiThread = false
    )
    public String createImageMessageFromFullPath(String OperationID, String imagePath) {
        return Open_im_sdk.createImageMessageFromFullPath(OperationID, imagePath);
    }

    @UniJSMethod(
            uiThread = false
    )
    public String createImageMessageByURL(String OperationID, JSONObject options) {
        String jsonStr1 = options.getJSONObject("sourcePicture").toJSONString();
        String jsonStr2 = options.getJSONObject("bigPicture").toJSONString();
        String jsonStr3 = options.getJSONObject("snapshotPicture").toJSONString();
        return Open_im_sdk.createImageMessageByURL(OperationID,options.getString("sourcePath"), jsonStr1, jsonStr2, jsonStr3);
    }

    @UniJSMethod(
            uiThread = false
    )
    public String createSoundMessage(String OperationID, JSONObject options) {
        return Open_im_sdk.createSoundMessage(OperationID, options.getString("soundPath"), options.getLong("duration"));
    }

    @UniJSMethod(
            uiThread = false
    )
    public String createSoundMessageFromFullPath(String OperationID,  JSONObject options) {
        return Open_im_sdk.createSoundMessageFromFullPath(OperationID, options.getString("soundPath"), options.getLong("duration"));
    }

    @UniJSMethod(
            uiThread = false
    )
    public String createSoundMessageByURL(String OperationID, JSONObject soundInfo) {
        return Open_im_sdk.createSoundMessageByURL(OperationID, soundInfo.toJSONString());
    }

    @UniJSMethod(
            uiThread = false
    )
    public String createVideoMessage(String OperationID, JSONObject options) {
        return Open_im_sdk.createVideoMessage(OperationID, options.getString("videoPath"), options.getString("videoType"), (long)options.getLong("duration"), options.getString("snapshotPath"));
    }

    @UniJSMethod(
            uiThread = false
    )
    public String createVideoMessageFromFullPath(String OperationID, JSONObject options) {
        return Open_im_sdk.createVideoMessageFromFullPath(OperationID, options.getString("videoPath"), options.getString("videoType"), (long)options.getLong("duration"), options.getString("snapshotPath"));
    }

    @UniJSMethod(
            uiThread = false
    )
    public String createVideoMessageByURL(String OperationID, JSONObject videoInfo) {
        return Open_im_sdk.createVideoMessageByURL(OperationID, videoInfo.toJSONString());
    }

    @UniJSMethod(
            uiThread = false
    )
    public String createFileMessage(String OperationID, JSONObject options) {
        return Open_im_sdk.createFileMessage(OperationID, options.getString("filePath"), options.getString("fileName"));
    }

    @UniJSMethod(
            uiThread = false
    )
    public String createFileMessageFromFullPath(String OperationID, JSONObject options) {
        return Open_im_sdk.createFileMessageFromFullPath(OperationID, options.getString("filePath"), options.getString("fileName"));
    }

    @UniJSMethod(
            uiThread = false
    )
    public String createFileMessageByURL(String OperationID, JSONObject fileInfo) {
        return Open_im_sdk.createFileMessageByURL(OperationID, fileInfo.toJSONString());
    }

    @UniJSMethod(
            uiThread = false
    )
    public String createMergerMessage(String operationID, JSONObject options) {
        return Open_im_sdk.createMergerMessage(operationID, options.getJSONArray("messageList").toJSONString() , options.getString("title"), options.getJSONArray("summaryList").toJSONString());
    }

    @UniJSMethod(
            uiThread = false
    )
    public String createFaceMessage(String operationID, JSONObject options) {
        return Open_im_sdk.createFaceMessage(operationID, options.getInteger("index"),options.getString("dataStr"));
    }

    @UniJSMethod(
            uiThread = false
    )
    public String createForwardMessage(String operationID, JSONObject message) {
        return Open_im_sdk.createForwardMessage(operationID, message.toJSONString());
    }

    @UniJSMethod(
            uiThread = false
    )
    public String getConversationIDBySessionType(String operationID, JSONObject options) {
        return Open_im_sdk.getConversationIDBySessionType(operationID, options.getString("sourceID"), options.getInteger("sessionType"));
    }

    @UniJSMethod(
            uiThread = false
    )
    public void sendMessage(String operationID, JSONObject options, UniJSCallback callback) {
        String messageStr = options.getJSONObject("message").toJSONString();
        String offlinePushInfoStr = options.getJSONObject("offlinePushInfo").toJSONString();
        boolean isOnlineOnly = options.getBooleanValue("isOnlineOnly");
        SendMsgCallBack sendMsgCallBack = new SendMsgCallBack() {
            public void onError(int i, String s) {
                Map<String, Object> params = new HashMap();
                params.put("errCode", i);
                params.put("errMsg", s);
                params.put("data", options.getJSONObject("message"));
                callback.invoke(params);
            }

            public void onProgress(long l) {
                Map<String, Object> params = new HashMap();
                JSONObject data = new JSONObject();
                data.put("message", options.getJSONObject("message"));
                data.put("progress", l);
                params.put("data", data);
                OpenIMSDK.this.mUniSDKInstance.fireGlobalEventCallback("sendMessageProgress", params);
            }

            public void onSuccess(String s) {
                Map<String, Object> params = new HashMap();
                params.put("errCode", 0);
                params.put("errMsg", "");
                params.put("data", JSONObject.parseObject(s));
                callback.invoke(params);
            }
        };
        Open_im_sdk.sendMessage(sendMsgCallBack, operationID,messageStr, options.getString("recvID"), options.getString("groupID"), offlinePushInfoStr,isOnlineOnly);
    }

    @UniJSMethod(
            uiThread = false
    )
    public void sendMessageNotOss(String operationID, JSONObject options, UniJSCallback callback) {
        String messageStr = options.getJSONObject("message").toJSONString();
        String offlinePushInfoStr = options.getJSONObject("offlinePushInfo").toJSONString();
        boolean isOnlineOnly = options.getBooleanValue("isOnlineOnly");
        SendMsgCallBack sendMsgNotOssCallBack = new SendMsgCallBack() {
            public void onError(int i, String s) {
                Map<String, Object> params = new HashMap();
                params.put("errCode", i);
                params.put("errMsg", s);
                params.put("data", options.getJSONObject("message"));
                callback.invoke(params);
            }

            public void onProgress(long l) {
                Map<String, Object> params = new HashMap();
                JSONObject data = new JSONObject();
                data.put("message", options.getJSONObject("message"));
                data.put("progress", l);
                params.put("data", data);
                OpenIMSDK.this.mUniSDKInstance.fireGlobalEventCallback("sendMessageProgress", params);
            }

            public void onSuccess(String s) {
                Map<String, Object> params = new HashMap();
                params.put("errCode", 0);
                params.put("errMsg", "");
                params.put("data", JSONObject.parseObject(s));
                callback.invoke(params);
            }
        };
        Open_im_sdk.sendMessageNotOss(sendMsgNotOssCallBack, operationID, messageStr, options.getString("recvID"), options.getString("groupID"), offlinePushInfoStr, isOnlineOnly);
    }

    @UniJSMethod(
            uiThread = false
    )
    public void findMessageList(String operationID,JSONArray findOptions, UniJSCallback callback) {
        Open_im_sdk.findMessageList(new BaseImpl(callback), operationID,findOptions.toJSONString());
    }

    @UniJSMethod(
            uiThread = false
    )
    public void getAdvancedHistoryMessageList(String operationID,JSONObject findOptions, UniJSCallback callback) {
        Open_im_sdk.getAdvancedHistoryMessageList(new BaseImpl(callback), operationID,findOptions.toJSONString());
    }

    @UniJSMethod(
            uiThread = false
    )
    public void getAdvancedHistoryMessageListReverse(String operationID, JSONObject options, UniJSCallback callback) {
        String optionStr = options.toJSONString();
        Open_im_sdk.getAdvancedHistoryMessageListReverse(new BaseImpl(callback), operationID, optionStr);
    }

    @UniJSMethod(
            uiThread = false
    )
    public void revokeMessage(String operationID, JSONObject options, UniJSCallback callback) {
        Open_im_sdk.revokeMessage(new BaseImpl(callback), operationID, options.getString("conversationID"), options.getString("clientMsgID"));
    }

    @UniJSMethod(
            uiThread = false
    )
    public void typingStatusUpdate(String operationID, JSONObject options, UniJSCallback callback) {
        Open_im_sdk.typingStatusUpdate(new BaseImpl(callback), operationID, options.getString("recvID"), options.getString("msgTip"));
    }

    @UniJSMethod(
            uiThread = false
    )
    public void markConversationMessageAsRead(String operationID, String conversationID, UniJSCallback callback) {
        Open_im_sdk.markConversationMessageAsRead(new BaseImpl(callback), operationID, conversationID);
    }

    @UniJSMethod(
            uiThread = false
    )
    public void markMessagesAsReadByMsgID(String operationID, JSONObject options, UniJSCallback callback) {
        Open_im_sdk.markMessagesAsReadByMsgID(new BaseImpl(callback), operationID, options.getString("conversationID"),options.getJSONArray("clientMsgIDList").toJSONString());
    }

    @UniJSMethod(
            uiThread = false
    )
    public void deleteMessageFromLocalStorage(String operationID, JSONObject options, UniJSCallback callback) {
        Open_im_sdk.deleteMessageFromLocalStorage(new BaseImpl(callback), operationID, options.getString("conversationID"), options.getString("clientMsgID"));
    }

    @UniJSMethod(
            uiThread = false
    )
    public void deleteMessage(String operationID, JSONObject options, UniJSCallback callback) {
        Open_im_sdk.deleteMessage(new BaseImpl(callback), operationID, options.getString("conversationID"), options.getString("clientMsgID"));
    }

    // @UniJSMethod(
    //         uiThread = false
    // )
    // public void deleteConversationFromLocal(String operationID, String conversationID, UniJSCallback callback) {
    //     Open_im_sdk.deleteConversationFromLocal(new BaseImpl(callback), operationID, conversationID);
    // }

    @UniJSMethod(
            uiThread = false
    )
    public void deleteAllMsgFromLocalAndSvr(String operationID, UniJSCallback callback) {
        Open_im_sdk.deleteAllMsgFromLocalAndSvr(new BaseImpl(callback), operationID);
    }

    @UniJSMethod(
            uiThread = false
    )
    public void deleteAllMsgFromLocal(String operationID, UniJSCallback callback) {
        Open_im_sdk.deleteAllMsgFromLocal(new BaseImpl(callback), operationID);
    }

    @UniJSMethod(
            uiThread = false
    )
    public void clearConversationAndDeleteAllMsg(String operationID, String conversationID, UniJSCallback callback) {
        Open_im_sdk.clearConversationAndDeleteAllMsg(new BaseImpl(callback), operationID, conversationID);
    }

    @UniJSMethod(
            uiThread = false
    )
    public void deleteConversationAndDeleteAllMsg(String operationID, String conversationID, UniJSCallback callback) {
        Open_im_sdk.deleteConversationAndDeleteAllMsg(new BaseImpl(callback), operationID, conversationID);
    }

    @UniJSMethod(
            uiThread = false
    )
    public void insertSingleMessageToLocalStorage(String operationID, JSONObject options, UniJSCallback callback) {
        Open_im_sdk.insertSingleMessageToLocalStorage(new BaseImpl(callback), operationID, options.getJSONObject("message").toJSONString(), options.getString("recvID"), options.getString("sendID"));
    }

    @UniJSMethod(
            uiThread = false
    )
    public void insertGroupMessageToLocalStorage(String operationID, JSONObject options, UniJSCallback callback) {
        Open_im_sdk.insertGroupMessageToLocalStorage(new BaseImpl(callback), operationID, options.getJSONObject("message").toJSONString(), options.getString("groupID"), options.getString("sendID"));
    }

    @UniJSMethod(
            uiThread = false
    )
    public void searchLocalMessages(String operationID, JSONObject searchParam, UniJSCallback callback) {
        Open_im_sdk.searchLocalMessages(new BaseImpl(callback), operationID, searchParam.toJSONString());
    }

    @UniJSMethod(
            uiThread = false
    )
    public void setMessageLocalEx(String operationID, JSONObject options, UniJSCallback callback) {
        Open_im_sdk.setMessageLocalEx(new BaseImpl(callback), operationID, options.getString("conversationID"),options.getString("clientMsgID"),options.getString("localEx"));
    }

    // friend
    @UniJSMethod(
            uiThread = false
    )
    public void _setFriendListener() {
        OnFriendshipListener friendshipListener = new OnFriendshipListener() {
            public void onBlackAdded(String s) {
                Map<String, Object> params = new HashMap();
                params.put("data", JSONObject.parseObject(s));
                OpenIMSDK.this.mUniSDKInstance.fireGlobalEventCallback("onBlackAdded", params);
            }

            public void onBlackDeleted(String s) {
                Map<String, Object> params = new HashMap();
                params.put("data", JSONObject.parseObject(s));
                OpenIMSDK.this.mUniSDKInstance.fireGlobalEventCallback("onBlackDeleted", params);
            }

            public void onFriendAdded(String s) {
                Map<String, Object> params = new HashMap();
                params.put("data", JSONObject.parseObject(s));
                OpenIMSDK.this.mUniSDKInstance.fireGlobalEventCallback("onFriendAdded", params);
            }

            public void onFriendApplicationAccepted(String s) {
                Map<String, Object> params = new HashMap();
                params.put("data", JSONObject.parseObject(s));
                OpenIMSDK.this.mUniSDKInstance.fireGlobalEventCallback("onFriendApplicationAccepted", params);
            }

            public void onFriendApplicationAdded(String s) {
                Map<String, Object> params = new HashMap();
                params.put("data", JSONObject.parseObject(s));
                OpenIMSDK.this.mUniSDKInstance.fireGlobalEventCallback("onFriendApplicationAdded", params);
            }

            public void onFriendApplicationDeleted(String s) {
                Map<String, Object> params = new HashMap();
                params.put("data", JSONObject.parseObject(s));
                OpenIMSDK.this.mUniSDKInstance.fireGlobalEventCallback("onFriendApplicationDeleted", params);
            }

            public void onFriendApplicationRejected(String s) {
                Map<String, Object> params = new HashMap();
                params.put("data", JSONObject.parseObject(s));
                OpenIMSDK.this.mUniSDKInstance.fireGlobalEventCallback("onFriendApplicationRejected", params);
            }

            public void onFriendDeleted(String s) {
                Map<String, Object> params = new HashMap();
                params.put("data", JSONObject.parseObject(s));
                OpenIMSDK.this.mUniSDKInstance.fireGlobalEventCallback("onFriendDeleted", params);
            }

            public void onFriendInfoChanged(String s) {
                Map<String, Object> params = new HashMap();
                params.put("data", JSONObject.parseObject(s));
                OpenIMSDK.this.mUniSDKInstance.fireGlobalEventCallback("onFriendInfoChanged", params);
            }
        };
        Open_im_sdk.setFriendListener(friendshipListener);
    }

    @UniJSMethod(
            uiThread = false
    )
    public void getSpecifiedFriendsInfo(String operationID, JSONArray userIDList, UniJSCallback callback) {
        Open_im_sdk.getSpecifiedFriendsInfo(new BaseImpl(callback), operationID, userIDList.toJSONString());
    }

    @UniJSMethod(
            uiThread = false
    )
    public void getFriendList(String operationID, UniJSCallback callback) {
        Open_im_sdk.getFriendList(new BaseImpl(callback), operationID);
    }

    @UniJSMethod(
            uiThread = false
    )
    public void getFriendListPage(String operationID, JSONObject options, UniJSCallback callback) {
        Open_im_sdk.getFriendListPage(new BaseImpl(callback), operationID, options.getInteger("offset"), options.getInteger("count"));
    }

    @UniJSMethod(
            uiThread = false
    )
    public void searchFriends(String operationID, JSONObject options, UniJSCallback callback) {
        Open_im_sdk.searchFriends(new BaseImpl(callback), operationID, options.toJSONString());
    }

    @UniJSMethod(
            uiThread = false
    )
    public void checkFriend(String operationID, JSONArray userIDList, UniJSCallback callback) {
        Open_im_sdk.checkFriend(new BaseImpl(callback), operationID, userIDList.toJSONString());
    }

    @UniJSMethod(
            uiThread = false
    )
    public void addFriend(String operationID, JSONObject paramsReq, UniJSCallback callback) {
        Open_im_sdk.addFriend(new BaseImpl(callback), operationID, paramsReq.toJSONString());
    }

    @UniJSMethod(
            uiThread = false
    )
    public void setFriendRemark(String operationID, JSONObject info, UniJSCallback callback) {
        Open_im_sdk.setFriendRemark(new BaseImpl(callback), operationID, info.toJSONString());
    }

    @UniJSMethod(
            uiThread = false
    )
    public void deleteFriend(String operationID, String userID, UniJSCallback callback) {
        Open_im_sdk.deleteFriend(new BaseImpl(callback), operationID, userID);
    }

    @UniJSMethod(
            uiThread = false
    )
    public void getFriendApplicationListAsRecipient(String operationID, UniJSCallback callback) {
        Open_im_sdk.getFriendApplicationListAsRecipient(new BaseImpl(callback), operationID);
    }

    @UniJSMethod(
            uiThread = false
    )
    public void getFriendApplicationListAsApplicant(String operationID, UniJSCallback callback) {
        Open_im_sdk.getFriendApplicationListAsApplicant(new BaseImpl(callback), operationID);
    }

    @UniJSMethod(
            uiThread = false
    )
    public void acceptFriendApplication(String operationID, JSONObject userIDHandleMsg, UniJSCallback callback) {
        Open_im_sdk.acceptFriendApplication(new BaseImpl(callback), operationID, userIDHandleMsg.toJSONString());
    }

    @UniJSMethod(
            uiThread = false
    )
    public void refuseFriendApplication(String operationID, JSONObject userIDHandleMsg, UniJSCallback callback) {
        Open_im_sdk.refuseFriendApplication(new BaseImpl(callback), operationID, userIDHandleMsg.toJSONString());
    }

    @UniJSMethod(
            uiThread = false
    )
    public void addBlack(String operationID, JSONObject options, UniJSCallback callback) {
        Open_im_sdk.addBlack(new BaseImpl(callback), operationID, options.getString("toUserID"), options.getString("ex"));
    }

    @UniJSMethod(
            uiThread = false
    )
    public void getBlackList(String operationID, UniJSCallback callback) {
        Open_im_sdk.getBlackList(new BaseImpl(callback), operationID);
    }

    @UniJSMethod(
            uiThread = false
    )
    public void removeBlack(String operationID, String userID, UniJSCallback callback) {
        Open_im_sdk.removeBlack(new BaseImpl(callback), operationID, userID);
    }

    // group
    @UniJSMethod(
            uiThread = false
    )
    public void _setGroupListener() {
        OnGroupListener groupListener = new OnGroupListener() {
            public void onGroupApplicationAccepted(String s) {
                Map<String, Object> params = new HashMap();
                params.put("data", JSONObject.parseObject(s));
                OpenIMSDK.this.mUniSDKInstance.fireGlobalEventCallback("onGroupApplicationAccepted", params);
            }

            public void onGroupApplicationAdded(String s) {
                Map<String, Object> params = new HashMap();
                params.put("data", JSONObject.parseObject(s));
                OpenIMSDK.this.mUniSDKInstance.fireGlobalEventCallback("onGroupApplicationAdded", params);
            }

            public void onGroupApplicationDeleted(String s) {
                Map<String, Object> params = new HashMap();
                params.put("data", JSONObject.parseObject(s));
                OpenIMSDK.this.mUniSDKInstance.fireGlobalEventCallback("onGroupApplicationDeleted", params);
            }

            public void onGroupApplicationRejected(String s) {
                Map<String, Object> params = new HashMap();
                params.put("data", JSONObject.parseObject(s));
                OpenIMSDK.this.mUniSDKInstance.fireGlobalEventCallback("onGroupApplicationRejected", params);
            }

            @Override
            public void onGroupDismissed(String s) {
                Map<String, Object> params = new HashMap();
                params.put("data", JSONObject.parseObject(s));
                OpenIMSDK.this.mUniSDKInstance.fireGlobalEventCallback("onGroupDismissed", params);
            }

            public void onGroupInfoChanged(String s) {
                Map<String, Object> params = new HashMap();
                params.put("data", JSONObject.parseObject(s));
                OpenIMSDK.this.mUniSDKInstance.fireGlobalEventCallback("onGroupInfoChanged", params);
            }

            public void onGroupMemberAdded(String s) {
                Map<String, Object> params = new HashMap();
                params.put("data", JSONObject.parseObject(s));
                OpenIMSDK.this.mUniSDKInstance.fireGlobalEventCallback("onGroupMemberAdded", params);
            }

            public void onGroupMemberDeleted(String s) {
                Map<String, Object> params = new HashMap();
                params.put("data", JSONObject.parseObject(s));
                OpenIMSDK.this.mUniSDKInstance.fireGlobalEventCallback("onGroupMemberDeleted", params);
            }

            public void onGroupMemberInfoChanged(String s) {
                Map<String, Object> params = new HashMap();
                params.put("data", JSONObject.parseObject(s));
                OpenIMSDK.this.mUniSDKInstance.fireGlobalEventCallback("onGroupMemberInfoChanged", params);
            }

            public void onJoinedGroupAdded(String s) {
                Map<String, Object> params = new HashMap();
                params.put("data", JSONObject.parseObject(s));
                OpenIMSDK.this.mUniSDKInstance.fireGlobalEventCallback("onJoinedGroupAdded", params);
            }

            public void onJoinedGroupDeleted(String s) {
                Map<String, Object> params = new HashMap();
                params.put("data", JSONObject.parseObject(s));
                OpenIMSDK.this.mUniSDKInstance.fireGlobalEventCallback("onJoinedGroupDeleted", params);
            }
        };
        Open_im_sdk.setGroupListener(groupListener);
    }

    @UniJSMethod(
            uiThread = false
    )
    public void createGroup(String operationID, JSONObject baseInfo, UniJSCallback callback) {
        Open_im_sdk.createGroup(new BaseImpl(callback), operationID, baseInfo.toJSONString());
    }

    @UniJSMethod(
            uiThread = false
    )
    public void joinGroup(String operationID, JSONObject options, UniJSCallback callback) {
        Open_im_sdk.joinGroup(new BaseImpl(callback), operationID, options.getString("groupID"), options.getString("reqMsg"),options.getInteger("joinSource"),options.getString("ex"));
    }

    @UniJSMethod(
            uiThread = false
    )
    public void quitGroup(String operationID, String groupID, UniJSCallback callback) {
        Open_im_sdk.quitGroup(new BaseImpl(callback), operationID, groupID);
    }

    @UniJSMethod(
            uiThread = false
    )
    public void dismissGroup(String operationID, String groupID, UniJSCallback callback) {
        Open_im_sdk.dismissGroup(new BaseImpl(callback), operationID, groupID);
    }

    @UniJSMethod(
            uiThread = false
    )
    public void changeGroupMute(String operationID, JSONObject options, UniJSCallback callback) {
        Open_im_sdk.changeGroupMute(new BaseImpl(callback), operationID, options.getString("groupID"), options.getBoolean("isMute"));
    }

    @UniJSMethod(
            uiThread = false
    )
    public void changeGroupMemberMute(String operationID, JSONObject options, UniJSCallback callback) {
        Open_im_sdk.changeGroupMemberMute(new BaseImpl(callback), operationID, options.getString("groupID"), options.getString("userID"), options.getLong("mutedSeconds"));
    }

    @UniJSMethod(
            uiThread = false
    )
    public void setGroupMemberRoleLevel(String operationID, JSONObject options, UniJSCallback callback) {
        Open_im_sdk.setGroupMemberRoleLevel(new BaseImpl(callback), operationID, options.getString("groupID"), options.getString("userID"), options.getInteger("roleLevel"));
    }

    @UniJSMethod(
            uiThread = false
    )
    public void setGroupMemberInfo(String operationID, JSONObject data, UniJSCallback callback) {
        Open_im_sdk.setGroupMemberInfo(new BaseImpl(callback), operationID, data.toJSONString());
    }

    @UniJSMethod(
            uiThread = false
    )
    public void getJoinedGroupList(String operationID, UniJSCallback callback) {
        Open_im_sdk.getJoinedGroupList(new BaseImpl(callback), operationID);
    }

    @UniJSMethod(
            uiThread = false
    )
    public void getSpecifiedGroupsInfo(String operationID, JSONArray groupIDList, UniJSCallback callback) {
        Open_im_sdk.getSpecifiedGroupsInfo(new BaseImpl(callback), operationID, groupIDList.toJSONString());
    }

    @UniJSMethod(
            uiThread = false
    )
    public void searchGroups(String operationID, JSONObject options, UniJSCallback callback) {
        Open_im_sdk.searchGroups(new BaseImpl(callback), operationID, options.toJSONString());
    }

    @UniJSMethod(
            uiThread = false
    )
    public void setGroupInfo(String operationID, JSONObject jsonGroupInfo, UniJSCallback callback) {
        Open_im_sdk.setGroupInfo(new BaseImpl(callback), operationID, jsonGroupInfo.toJSONString());
    }

    @UniJSMethod(
            uiThread = false
    )
    public void setGroupVerification(String operationID, JSONObject options, UniJSCallback callback) {
        Open_im_sdk.setGroupVerification(new BaseImpl(callback), operationID, options.getString("groupID"), options.getInteger("verification"));
    }

    @UniJSMethod(
            uiThread = false
    )
    public void setGroupLookMemberInfo(String operationID,JSONObject options, UniJSCallback callback) {
        Open_im_sdk.setGroupLookMemberInfo(new BaseImpl(callback),  operationID, options.getString("groupID"), options.getInteger("rule"));
    }

    @UniJSMethod(
            uiThread = false
    )
    public void setGroupApplyMemberFriend(String operationID,JSONObject options, UniJSCallback callback) {
        Open_im_sdk.setGroupApplyMemberFriend(new BaseImpl(callback), operationID,options.getString("groupID"), options.getInteger("rule"));
    }

    @UniJSMethod(
            uiThread = false
    )
    public void getGroupMemberList(String operationID, JSONObject options, UniJSCallback callback) {
        Open_im_sdk.getGroupMemberList(new BaseImpl(callback), operationID, options.getString("groupID"), options.getInteger("filter"), options.getInteger("offset"), options.getInteger("count"));
    }

    @UniJSMethod(
            uiThread = false
    )
    public void getGroupMemberOwnerAndAdmin(String operationID, String groupID, UniJSCallback callback) {
        Open_im_sdk.getGroupMemberOwnerAndAdmin(new BaseImpl(callback), operationID, groupID);
    }

    @UniJSMethod(
            uiThread = false
    )
    public void getGroupMemberListByJoinTimeFilter(String operationID, JSONObject options, UniJSCallback callback) {
        Open_im_sdk.getGroupMemberListByJoinTimeFilter(new BaseImpl(callback), operationID, options.getString("groupID"), options.getInteger("offset"), options.getInteger("count"), options.getInteger("joinTimeBegin"),options.getInteger("joinTimeEnd"),options.getJSONArray("filterUserIDList").toJSONString());
    }

    @UniJSMethod(
            uiThread = false
    )
    public void getSpecifiedGroupMembersInfo(String operationID, JSONObject options, UniJSCallback callback) {
        Open_im_sdk.getSpecifiedGroupMembersInfo(new BaseImpl(callback), operationID, options.getString("groupID"), options.getJSONArray("userIDList").toJSONString());
    }

    @UniJSMethod(
            uiThread = false
    )
    public void kickGroupMember(String operationID, JSONObject options , UniJSCallback callback) {
        Open_im_sdk.kickGroupMember(new BaseImpl(callback), operationID, options.getString("groupID"), options.getString("reason"), options.getJSONArray("userIDList").toJSONString());
    }

    @UniJSMethod(
            uiThread = false
    )
    public void transferGroupOwner(String operationID, JSONObject options, UniJSCallback callback) {
        Open_im_sdk.transferGroupOwner(new BaseImpl(callback), operationID, options.getString("groupID"), options.getString("newOwnerUserID"));
    }

    @UniJSMethod(
            uiThread = false
    )
    public void inviteUserToGroup(String operationID, JSONObject options, UniJSCallback callback) {
        Open_im_sdk.inviteUserToGroup(new BaseImpl(callback),operationID, options.getString("groupID"), options.getString("reason"), options.getJSONArray("userIDList").toJSONString());
    }

    @UniJSMethod(
            uiThread = false
    )
    public void getGroupApplicationListAsRecipient(String operationID, UniJSCallback callback) {
        Open_im_sdk.getGroupApplicationListAsRecipient(new BaseImpl(callback), operationID);
    }

    @UniJSMethod(
            uiThread = false
    )
    public void getGroupApplicationListAsApplicant(String operationID, UniJSCallback callback) {
        Open_im_sdk.getGroupApplicationListAsApplicant(new BaseImpl(callback), operationID);
    }

    @UniJSMethod(
            uiThread = false
    )
    public void acceptGroupApplication(String operationID, JSONObject options, UniJSCallback callback) {
        Open_im_sdk.acceptGroupApplication(new BaseImpl(callback), operationID, options.getString("groupID"), options.getString("fromUserID"), options.getString("handleMsg"));
    }

    @UniJSMethod(
            uiThread = false
    )
    public void refuseGroupApplication(String operationID, JSONObject options, UniJSCallback callback) {
        Open_im_sdk.refuseGroupApplication(new BaseImpl(callback), operationID, options.getString("groupID"), options.getString("fromUserID"), options.getString("handleMsg"));
    }

    @UniJSMethod(
            uiThread = false
    )
    public void setGroupMemberNickname(String operationID, JSONObject options, UniJSCallback callback) {
        Open_im_sdk.setGroupMemberNickname(new BaseImpl(callback), operationID, options.getString("groupID"), options.getString("userID"), options.getString("groupMemberNickname"));
    }

    @UniJSMethod(
            uiThread = false
    )
    public void searchGroupMembers(String operationID,JSONObject searchOptions, UniJSCallback callback) {
        Open_im_sdk.searchGroupMembers(new BaseImpl(callback), operationID,searchOptions.toJSONString());
    }

    @UniJSMethod(
            uiThread = false
    )
    public void isJoinGroup(String operationID,String groupID, UniJSCallback callback) {
        Open_im_sdk.isJoinGroup(new BaseImpl(callback), operationID,groupID);
    }

    @UniJSMethod(
            uiThread = false
    )
    public void setAppBadge(String operationID, Integer appUnreadCount, UniJSCallback callback) {
        Open_im_sdk.setAppBadge(new BaseImpl(callback), operationID,appUnreadCount);
    }

    @UniJSMethod(
            uiThread = false
    )
    public void uploadLogs(String operationID, String ex, UniJSCallback callback) {
        UploadLogProgress uploadLogProgress = new UploadLogProgress() {
            @Override
            public void onProgress(long current, long size) {
                Map<String, Object> params = new HashMap();
                JSONObject data = new JSONObject();
                data.put("current", current);
                data.put("size", size);
                params.put("data", data);
                OpenIMSDK.this.mUniSDKInstance.fireGlobalEventCallback("uploadLogsProgress", params);
            }
        };
        Open_im_sdk.uploadLogs(new BaseImpl(callback), operationID,ex,uploadLogProgress);
    }

    @UniJSMethod(
            uiThread = false
    )
    public String getSdkVersion() {
        return Open_im_sdk.getSdkVersion();
    }

    @UniJSMethod(
            uiThread = false
    )
    public void uploadFile(String operationID, JSONObject reqData,UniJSCallback callback) {
        UploadFileCallback uploadFileCallback = new UploadFileCallback() {
            @Override
            public void complete(long l, String s, long l1) {

            }

            @Override
            public void hashPartComplete(String s, String s1) {

            }

            @Override
            public void hashPartProgress(long l, long l1, String s) {

            }

            @Override
            public void open(long l) {

            }

            @Override
            public void partSize(long l, long l1) {

            }

            @Override
            public void uploadComplete(long l, long l1, long l2) {
                Map<String, Object> params = new HashMap();
                JSONObject data = new JSONObject();
                data.put("fileSize", l);
                data.put("streamSize", l1);
                data.put("storageSize", l2);
                data.put("operationID", operationID);
                params.put("data", data);
                OpenIMSDK.this.mUniSDKInstance.fireGlobalEventCallback("uploadComplete", params);
            }

            @Override
            public void uploadID(String s) {

            }

            @Override
            public void uploadPartComplete(long l, long l1, String s) {

            }
        };
        Open_im_sdk.uploadFile(new BaseImpl(callback), operationID, reqData.toJSONString(),uploadFileCallback);
    }

    @UniJSMethod(
            uiThread = false
    )
    public void _setCustomBusinessListener() {
        OnCustomBusinessListener onCustomBusinessListener = new OnCustomBusinessListener() {
            @Override
            public void onRecvCustomBusinessMessage(String s) {
                Map<String, Object> params = new HashMap();
                params.put("data", JSONObject.parseObject(s));
                OpenIMSDK.this.mUniSDKInstance.fireGlobalEventCallback("onRecvCustomBusinessMessage", params);
            }
        };
        Open_im_sdk.setCustomBusinessListener(onCustomBusinessListener);
    }
}