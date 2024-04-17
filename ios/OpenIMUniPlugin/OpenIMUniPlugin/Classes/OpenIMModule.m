#import "OpenIMModule.h"
#import "SendMessageCallbackProxy.h"
#import "UploadFileCallbackProxy.h"
#import "UploadLogsCallbackProxy.h"

#define PUSH_EVENT(param) \
NSString *funcName = [NSString stringWithFormat:@"%s", __func__]; \
NSString *eventName = [[funcName stringByReplacingOccurrencesOfString:@":" withString:@" "] componentsSeparatedByString:@" "][1]; \
[self pushEvent:eventName msg:param];

#define PUSH_EVENT_NIL() PUSH_EVENT(nil)

@implementation NSDictionary (Extensions)

- (NSString *)json {
    NSString *json = nil;

    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:&error];
    json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    return (error ? nil : json);
}

@end


@implementation NSArray (Extensions)

- (NSString *)json {
    NSString *json = nil;

    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:&error];
    json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    return (error ? nil : json);
}

@end

@implementation NSString (Extensions)

- (NSString *)json {
    return [NSString stringWithFormat:@"\"%@\"",self];
}

@end

@implementation OpenIMModule

- (void)pushEvent:(NSString *) eventName msg:(nullable id) msg {
    NSDictionary *param = @{};
    if ([msg isKindOfClass:NSDictionary.class]) {
        param = msg;
    } else if (msg != nil) {
        param = @{@"msg": msg};
    }else{
        param = @{@"msg": eventName};
    }
    NSLog(@"pushEvent ---- %@",eventName);
    [self.uniInstance fireGlobalEvent:eventName params:param];
}

// MARK: - Init & Login

UNI_EXPORT_METHOD_SYNC(@selector(initSDK:config:))

- (BOOL)initSDK:(NSString *)opid config:(NSDictionary *)config {
    NSLog(@"initSDK ---- %@",[config json]);
    if(self.initFlag) return true;
    BOOL flag =Open_im_sdkInitSDK(self, opid, [config json]);
    if (flag){
        Open_im_sdkSetUserListener(self);
        Open_im_sdkSetConversationListener(self);
        Open_im_sdkSetAdvancedMsgListener(self);
        Open_im_sdkSetBatchMsgListener(self);
        Open_im_sdkSetFriendListener(self);
        Open_im_sdkSetGroupListener(self);
        Open_im_sdkSetCustomBusinessListener(self);
    }
    self.initFlag = flag;
    return flag;
}

UNI_EXPORT_METHOD_SYNC(@selector(unInitSDK))

- (void)unInitSDK:(NSString *)opid {
    Open_im_sdkUnInitSDK(opid);
}

UNI_EXPORT_METHOD(@selector(login:options:callback:))

- (void)login:(NSString *)opid options:(NSDictionary *)options callback:(UniModuleKeepAliveCallback)callback {
    Open_im_sdkGetLoginStatus(opid);
    CallbackProxy *proxy = [[CallbackProxy alloc] initWithCallback:callback];
    Open_im_sdkLogin(proxy,opid,[options valueForKey:@"userID"],[options valueForKey:@"token"]);
}

UNI_EXPORT_METHOD(@selector(logout:callback:))

- (void)logout:(NSString *)opid callback:(UniModuleKeepAliveCallback)callback {
    CallbackProxy *proxy = [[CallbackProxy alloc] initWithCallback:callback];
    Open_im_sdkLogout(proxy,opid);
}

UNI_EXPORT_METHOD(@selector(setAppBackgroundStatus:isBackground:callback:))

- (void)setAppBackgroundStatus:(NSString *)opid isBackground:(BOOL)isBackground callback:(UniModuleKeepAliveCallback)callback {
    CallbackProxy *proxy = [[CallbackProxy alloc] initWithCallback:callback];
    Open_im_sdkSetAppBackgroundStatus(proxy,opid,isBackground);
}

UNI_EXPORT_METHOD(@selector(networkStatusChanged:callback:))

- (void)networkStatusChanged:(NSString *)opid callback:(UniModuleKeepAliveCallback)callback {
    CallbackProxy *proxy = [[CallbackProxy alloc] initWithCallback:callback];
    Open_im_sdkNetworkStatusChanged(proxy,opid);
}

UNI_EXPORT_METHOD_SYNC(@selector(getLoginStatus))

- (long)getLoginStatus {
    return Open_im_sdkGetLoginStatus(@"opid");
}

UNI_EXPORT_METHOD_SYNC(@selector(getLoginUserID))

- (NSString *)getLoginUserID {
    return Open_im_sdkGetLoginUserID();
}


// MARK: - User

UNI_EXPORT_METHOD(@selector(getUsersInfo:userIDList:callback:))

- (void)getUsersInfo:(NSString *)opid userIDList:(NSArray *)userIDList callback:(UniModuleKeepAliveCallback)callback {
    CallbackProxy *proxy = [[CallbackProxy alloc] initWithCallback:callback];
    Open_im_sdkGetUsersInfo(proxy,opid,[userIDList json]);
}

UNI_EXPORT_METHOD(@selector(getUsersInfoWithCache:options:callback:))

- (void)getUsersInfoWithCache:(NSString *)opid options:(NSDictionary *)options callback:(UniModuleKeepAliveCallback)callback {
    CallbackProxy *proxy = [[CallbackProxy alloc] initWithCallback:callback];
    NSArray* userIDList = [options valueForKey:@"userIDList"];
    Open_im_sdkGetUsersInfoWithCache(proxy,opid,[userIDList json],[options valueForKey:@"groupID"]);
}

UNI_EXPORT_METHOD(@selector(setSelfInfo:userInfo:callback:))

- (void)setSelfInfo:(NSString *)opid userInfo:(NSDictionary*)userInfo callback:(UniModuleKeepAliveCallback)callback {
    CallbackProxy *proxy = [[CallbackProxy alloc] initWithCallback:callback];
    Open_im_sdkSetSelfInfo(proxy,opid,[userInfo json]);
}

UNI_EXPORT_METHOD(@selector(getSelfUserInfo:callback:))

- (void)getSelfUserInfo:(NSString *)opid callback:(UniModuleKeepAliveCallback)callback {
    CallbackProxy *proxy = [[CallbackProxy alloc] initWithCallback:callback];
    Open_im_sdkGetSelfUserInfo(proxy,opid);
}

UNI_EXPORT_METHOD(@selector(getUserStatus:userIDList:callback:))

- (void)getUserStatus:(NSString *)opid userIDList:(NSArray *)userIDList callback:(UniModuleKeepAliveCallback)callback {
    CallbackProxy *proxy = [[CallbackProxy alloc] initWithCallback:callback];
    Open_im_sdkGetUserStatus(proxy,opid,[userIDList json]);
}

UNI_EXPORT_METHOD(@selector(subscribeUsersStatus:userIDList:callback:))

- (void)subscribeUsersStatus:(NSString *)opid userIDList:(NSArray *)userIDList callback:(UniModuleKeepAliveCallback)callback {
    CallbackProxy *proxy = [[CallbackProxy alloc] initWithCallback:callback];
    Open_im_sdkSubscribeUsersStatus(proxy,opid,[userIDList json]);
}

UNI_EXPORT_METHOD(@selector(unsubscribeUsersStatus:userIDList:callback:))

- (void)unsubscribeUsersStatus:(NSString *)opid userIDList:(NSArray *)userIDList callback:(UniModuleKeepAliveCallback)callback {
    CallbackProxy *proxy = [[CallbackProxy alloc] initWithCallback:callback];
    Open_im_sdkUnsubscribeUsersStatus(proxy,opid,[userIDList json]);
}

UNI_EXPORT_METHOD(@selector(getSubscribeUsersStatus:callback:))

- (void)getSubscribeUsersStatus:(NSString *)opid callback:(UniModuleKeepAliveCallback)callback {
    CallbackProxy *proxy = [[CallbackProxy alloc] initWithCallback:callback];
    Open_im_sdkGetSubscribeUsersStatus(proxy,opid);
}

// MARK: - Conversation & Message

UNI_EXPORT_METHOD(@selector(getAllConversationList:callback:))

- (void)getAllConversationList:(NSString *)opid callback:(UniModuleKeepAliveCallback)callback {
    CallbackProxy *proxy = [[CallbackProxy alloc] initWithCallback:callback];
    Open_im_sdkGetAllConversationList(proxy,opid);
}

UNI_EXPORT_METHOD(@selector(getConversationListSplit:options:callback:))

- (void)getConversationListSplit:(NSString *)opid options:(NSDictionary *)options callback:(UniModuleKeepAliveCallback)callback {
    CallbackProxy *proxy = [[CallbackProxy alloc] initWithCallback:callback];
    Open_im_sdkGetConversationListSplit(proxy,opid,[[options valueForKey:@"offset"] longValue], [[options valueForKey:@"count"] longValue]);
}


UNI_EXPORT_METHOD(@selector(getOneConversation:options:callback:))

- (void)getOneConversation:(NSString *)opid options:(NSDictionary *)options callback:(UniModuleKeepAliveCallback)callback {
    CallbackProxy *proxy = [[CallbackProxy alloc] initWithCallback:callback];
    Open_im_sdkGetOneConversation(proxy,opid, [[options valueForKey:@"sessionType"] intValue], [options valueForKey:@"sourceID"]);
}

UNI_EXPORT_METHOD(@selector(getMultipleConversation:conversationIDList:callback:))

- (void)getMultipleConversation:(NSString *)opid conversationIDList:(NSArray *)conversationIDList callback:(UniModuleKeepAliveCallback)callback {
    CallbackProxy *proxy = [[CallbackProxy alloc] initWithCallback:callback];
    Open_im_sdkGetMultipleConversation(proxy, opid, [conversationIDList json]);
}


UNI_EXPORT_METHOD(@selector(setGlobalRecvMessageOpt:opt:callback:))

- (void)setGlobalRecvMessageOpt:(NSString *)opid opt:(long)opt callback:(UniModuleKeepAliveCallback)callback {
    CallbackProxy *proxy = [[CallbackProxy alloc] initWithCallback:callback];
    Open_im_sdkSetGlobalRecvMessageOpt(proxy,opid,opt);
}

UNI_EXPORT_METHOD(@selector(hideConversation:conversationID:callback:))

- (void)hideConversation:(NSString *)opid conversationID:(NSString *)conversationID callback:(UniModuleKeepAliveCallback)callback {
    CallbackProxy *proxy = [[CallbackProxy alloc] initWithCallback:callback];
    Open_im_sdkHideConversation(proxy,opid,conversationID);
}

UNI_EXPORT_METHOD(@selector(getConversationRecvMessageOpt:conversationIDList:callback:))

- (void)getConversationRecvMessageOpt:(NSString *)opid conversationIDList:(NSArray *)conversationIDList callback:(UniModuleKeepAliveCallback)callback {
    CallbackProxy *proxy = [[CallbackProxy alloc] initWithCallback:callback];
    Open_im_sdkGetConversationRecvMessageOpt(proxy, opid, [conversationIDList json]);
}

UNI_EXPORT_METHOD(@selector(setConversationDraft:options:callback:))

- (void)setConversationDraft:(NSString *)opid options:(NSDictionary *)options callback:(UniModuleKeepAliveCallback)callback {
    CallbackProxy *proxy = [[CallbackProxy alloc] initWithCallback:callback];
    Open_im_sdkSetConversationDraft(proxy,opid, [options valueForKey:@"conversationID"],[options valueForKey:@"draftText"]);
}

UNI_EXPORT_METHOD(@selector(resetConversationGroupAtType:conversationID:callback:))

- (void)resetConversationGroupAtType:(NSString *)opid conversationID:(NSString *)conversationID callback:(UniModuleKeepAliveCallback)callback {
    CallbackProxy *proxy = [[CallbackProxy alloc] initWithCallback:callback];
    Open_im_sdkResetConversationGroupAtType(proxy,opid,conversationID);
}

UNI_EXPORT_METHOD(@selector(pinConversation:options:callback:))

- (void)pinConversation:(NSString *)opid options:(NSDictionary *)options callback:(UniModuleKeepAliveCallback)callback {
    CallbackProxy *proxy = [[CallbackProxy alloc] initWithCallback:callback];
    Open_im_sdkPinConversation(proxy,opid, [options valueForKey:@"conversationID"], [[options valueForKey:@"isPinned"] boolValue]);
}

UNI_EXPORT_METHOD(@selector(setConversationPrivateChat:options:callback:))

- (void)setConversationPrivateChat:(NSString *)opid options:(NSDictionary *)options callback:(UniModuleKeepAliveCallback)callback {
    CallbackProxy *proxy = [[CallbackProxy alloc] initWithCallback:callback];
    Open_im_sdkSetConversationPrivateChat(proxy,opid, [options valueForKey:@"conversationID"], [[options valueForKey:@"isPrivate"] boolValue] );
}


UNI_EXPORT_METHOD(@selector(setConversationBurnDuration:options:callback:))

- (void)setConversationBurnDuration:(NSString *)opid options:(NSDictionary *)options callback:(UniModuleKeepAliveCallback)callback {
    CallbackProxy *proxy = [[CallbackProxy alloc] initWithCallback:callback];
    Open_im_sdkSetConversationBurnDuration(proxy,opid,[options valueForKey:@"conversationID"], [[options valueForKey:@"burnDuration"] intValue]);
}

UNI_EXPORT_METHOD(@selector(setConversationRecvMessageOpt:options:callback:))

- (void)setConversationRecvMessageOpt:(NSString *)opid options:(NSDictionary *)options callback:(UniModuleKeepAliveCallback)callback {
    CallbackProxy *proxy = [[CallbackProxy alloc] initWithCallback:callback];
    Open_im_sdkSetConversationRecvMessageOpt(proxy, opid, [options valueForKey:@"conversationID"], [[options valueForKey:@"opt"] longValue]);
}

UNI_EXPORT_METHOD(@selector(getTotalUnreadMsgCount:callback:))

- (void)getTotalUnreadMsgCount:(NSString *)opid callback:(UniModuleKeepAliveCallback)callback {
    CallbackProxy *proxy = [[CallbackProxy alloc] initWithCallback:callback];
    Open_im_sdkGetTotalUnreadMsgCount(proxy,opid);
}

UNI_EXPORT_METHOD(@selector(getAtAllTag:callback:))

- (NSString *)getAtAllTag:(NSString *)opid callback:(UniModuleKeepAliveCallback)callback {
    return Open_im_sdkGetAtAllTag(opid);
}

UNI_EXPORT_METHOD(@selector(createAdvancedTextMessage:options:callback:))

- (NSString *)createAdvancedTextMessage:(NSString *)opid options:(NSDictionary *)options callback:(UniModuleKeepAliveCallback)callback {
    NSArray* messageEntityList = [options valueForKey:@"messageEntityList"];
    return Open_im_sdkCreateAdvancedTextMessage(opid,[options valueForKey:@"text"],[messageEntityList json]);
}

UNI_EXPORT_METHOD_SYNC(@selector(createTextAtMessage:options:))

- (NSString *)createTextAtMessage:(NSString *)opid options:(NSDictionary *)options {
    NSArray* atUserIDList = [options valueForKey:@"atUserIDList"];
    NSArray* atUsersInfo = [options valueForKey:@"atUsersInfo"];
    NSDictionary* message = [options valueForKey:@"message"];
    NSString *messageJson = @"";
    if ([[options allKeys] containsObject:@"message"]) {
            if ([message isKindOfClass:[NSDictionary class]]) {
                messageJson = [message json];
            }
        }
    return Open_im_sdkCreateTextAtMessage(opid,[options valueForKey: @"text"], [atUserIDList json],[atUsersInfo json],messageJson);
}

UNI_EXPORT_METHOD_SYNC(@selector(createTextMessage:textMsg:))

- (NSString *)createTextMessage:(NSString *)opid textMsg:(NSString *)textMsg {
    return Open_im_sdkCreateTextMessage(opid,textMsg);
}

UNI_EXPORT_METHOD_SYNC(@selector(createLocationMessage:options:))

- (NSString *)createLocationMessage:(NSString *)opid options:(NSDictionary *)options {
    return Open_im_sdkCreateLocationMessage(opid,[options valueForKey: @"description"], [[options valueForKey: @"longitude"] doubleValue], [[options valueForKey: @"latitude"] doubleValue]);
}

UNI_EXPORT_METHOD_SYNC(@selector(createCustomMessage:options:))

- (NSString *)createCustomMessage:(NSString *)opid options:(NSDictionary*)options {
    return Open_im_sdkCreateCustomMessage(opid,[options valueForKey:@"data"], [options valueForKey:@"extension"], [options valueForKey:@"description"]);
}

UNI_EXPORT_METHOD_SYNC(@selector(createQuoteMessage:options:))

- (NSString *)createQuoteMessage:(NSString *)opid options:(NSDictionary *)options {
    NSDictionary* message = [options valueForKey:@"message"];
    return Open_im_sdkCreateQuoteMessage(opid,[options valueForKey:@"text"], [message json]);
}

UNI_EXPORT_METHOD_SYNC(@selector(createAdvancedQuoteMessage:options:))

- (NSString *)createAdvancedQuoteMessage:(NSString *)opid options:(NSDictionary *)options {
    NSDictionary* message = [options valueForKey:@"message"];
    NSArray* messageEntityList = [options valueForKey:@"messageEntityList"];
    return Open_im_sdkCreateAdvancedQuoteMessage(opid,[options valueForKey:@"text"], [message json],[messageEntityList json]);
}

UNI_EXPORT_METHOD_SYNC(@selector(createCardMessage:cardDesc:))

- (NSString *)createCardMessage:(NSString *)opid cardDesc:(NSDictionary *)cardDesc {
    return Open_im_sdkCreateCardMessage(opid,[cardDesc json]);
}

UNI_EXPORT_METHOD_SYNC(@selector(createImageMessage:imagePath:))

- (NSString *)createImageMessage:(NSString *)opid imagePath:(NSString *)imagePath {
    return Open_im_sdkCreateImageMessage(opid,imagePath);
}

UNI_EXPORT_METHOD_SYNC(@selector(createImageMessageFromFullPath:imagePath:))

- (NSString *)createImageMessageFromFullPath:(NSString *)opid imagePath:(NSString *)imagePath {
    return Open_im_sdkCreateImageMessageFromFullPath(opid,imagePath);
}


UNI_EXPORT_METHOD_SYNC(@selector(createImageMessageByURL:options:))

- (NSString *)createImageMessageByURL:(NSString *)opid options:(NSDictionary *)options {
    NSDictionary* sourcePicture = [options valueForKey:@"sourcePicture"];
    NSDictionary* bigPicture = [options valueForKey:@"bigPicture"];
    NSDictionary* snapshotPicture = [options valueForKey:@"snapshotPicture"];
    return Open_im_sdkCreateImageMessageByURL(opid, [options valueForKey:@"sourcePath"], [sourcePicture json], [bigPicture json], [snapshotPicture json]);
}

UNI_EXPORT_METHOD_SYNC(@selector(createSoundMessage:options:))

- (NSString *)createSoundMessage:(NSString *)opid options:(NSDictionary *)options {
    return Open_im_sdkCreateSoundMessage(opid,[options valueForKey:@"soundPath"], [[options valueForKey:@"duration"] intValue]);
}

UNI_EXPORT_METHOD_SYNC(@selector(createSoundMessageFromFullPath:options:))

- (NSString *)createSoundMessageFromFullPath:(NSString *)opid options:(NSDictionary *)options {
    return Open_im_sdkCreateSoundMessageFromFullPath(opid,[options valueForKey:@"soundPath"], [[options valueForKey:@"duration"] intValue]);
}

UNI_EXPORT_METHOD_SYNC(@selector(createSoundMessageByURL:soundInfo:))

- (NSString *)createSoundMessageByURL:(NSString *)opid soundInfo:(NSDictionary *)soundInfo {
    return Open_im_sdkCreateSoundMessageByURL(opid,[soundInfo json]);
}

UNI_EXPORT_METHOD_SYNC(@selector(createVideoMessage:options:))

- (NSString *)createVideoMessage:(NSString *)opid options:(NSDictionary *)options {

    return Open_im_sdkCreateVideoMessage(opid,[options valueForKey:@"videoPath"], [options valueForKey:@"videoType"], [[options valueForKey:@"duration"] integerValue], [options valueForKey:@"snapshotPath"]);
}

UNI_EXPORT_METHOD_SYNC(@selector(createVideoMessageFromFullPath:options:))

- (NSString *)createVideoMessageFromFullPath:(NSString *)opid options:(NSDictionary *)options {
    return Open_im_sdkCreateVideoMessageFromFullPath(opid,[options valueForKey:@"videoPath"], [options valueForKey:@"videoType"], [[options valueForKey:@"duration"] integerValue], [options valueForKey:@"snapshotPath"]);
}

UNI_EXPORT_METHOD_SYNC(@selector(createVideoMessageByURL:videoInfo:))

- (NSString *)createVideoMessageByURL:(NSString *)opid videoInfo:(NSDictionary *)videoInfo {
    return Open_im_sdkCreateVideoMessageByURL(opid,[videoInfo json]);
}

UNI_EXPORT_METHOD_SYNC(@selector(createFileMessage:options:))

- (NSString *)createFileMessage:(NSString *)opid options:(NSDictionary *)options {
    return Open_im_sdkCreateFileMessage(opid,[options valueForKey:@"filePath"], [options valueForKey:@"fileName"]);
}

UNI_EXPORT_METHOD_SYNC(@selector(createFileMessageFromFullPath:options:))

- (NSString *)createFileMessageFromFullPath:(NSString *)opid options:(NSDictionary *)options {
    return Open_im_sdkCreateFileMessageFromFullPath(opid,[options valueForKey:@"filePath"], [options valueForKey:@"fileName"]);
}

UNI_EXPORT_METHOD_SYNC(@selector(createFileMessageByURL:fileInfo:))

- (NSString *)createFileMessageByURL:(NSString *)opid fileInfo:(NSDictionary *)fileInfo {
    return Open_im_sdkCreateFileMessageByURL(opid,[fileInfo json]);
}

UNI_EXPORT_METHOD_SYNC(@selector(createMergerMessage:options:))

- (NSString *)createMergerMessage:(NSString *)opid options:(NSDictionary *)options {
    NSArray* messageList = [options valueForKey:@"messageList"];
    NSArray* summaryList = [options valueForKey:@"summaryList"];
    return Open_im_sdkCreateMergerMessage(opid,[messageList json], [options valueForKey:@"title"], [summaryList json]);
}

UNI_EXPORT_METHOD_SYNC(@selector(createFaceMessage:options:))

- (NSString *)createFaceMessage:(NSString *)opid options:(NSDictionary *)options {
    return Open_im_sdkCreateFaceMessage(opid,[[options valueForKey:@"index"] longValue], [options valueForKey:@"dataStr"]);
}

UNI_EXPORT_METHOD_SYNC(@selector(createForwardMessage:message:))

- (NSString *)createForwardMessage:(NSString *)opid message:(NSDictionary *)message {
    return Open_im_sdkCreateForwardMessage(opid,[message json]);
}


UNI_EXPORT_METHOD_SYNC(@selector(getConversationIDBySessionType:options:))

- (NSString *)getConversationIDBySessionType:(NSString *)opid options:(NSDictionary *)options {
    return Open_im_sdkGetConversationIDBySessionType(opid,[options valueForKey:@"sourceID"],[[options valueForKey:@"sessionType"] longValue]);
}

UNI_EXPORT_METHOD(@selector(sendMessage:options:callback:))

- (void)sendMessage:(NSString *)opid options:(NSDictionary *)options callback:(UniModuleKeepAliveCallback)callback {
    NSDictionary* message = [options valueForKey:@"message"];
    NSDictionary* offlinePushInfo = [options valueForKey:@"offlinePushInfo"];
    NSNumber* isOnlineOnlyNumber = [options valueForKey:@"isOnlineOnly"];
    BOOL isOnlineOnly = [isOnlineOnlyNumber boolValue];
    SendMessageCallbackProxy *proxy = [[SendMessageCallbackProxy alloc] initWithMessage:message module:self callback:callback];
    Open_im_sdkSendMessage(proxy,opid, [message json], [options valueForKey:@"recvID"], [options valueForKey:@"groupID"], [offlinePushInfo json],isOnlineOnly);
}

UNI_EXPORT_METHOD(@selector(sendMessageNotOss:options:callback:))

- (void)sendMessageNotOss:(NSString *)opid options:(NSDictionary *)options callback:(UniModuleKeepAliveCallback)callback {
    NSDictionary* message = [options valueForKey:@"message"];
    NSDictionary* offlinePushInfo = [options valueForKey:@"offlinePushInfo"];
    NSNumber* isOnlineOnlyNumber = [options valueForKey:@"isOnlineOnly"];
    BOOL isOnlineOnly = [isOnlineOnlyNumber boolValue];
    
    SendMessageCallbackProxy *proxy = [[SendMessageCallbackProxy alloc] initWithMessage:message module:self callback:callback];
    Open_im_sdkSendMessageNotOss(proxy,opid, [message json], [options valueForKey:@"recvID"], [options valueForKey:@"groupID"], [offlinePushInfo json], isOnlineOnly);
}

UNI_EXPORT_METHOD(@selector(findMessageList:findOptions:callback:))

- (void)findMessageList:(NSString *)opid findOptions:(NSArray *)findOptions callback:(UniModuleKeepAliveCallback)callback {
    CallbackProxy *proxy = [[CallbackProxy alloc] initWithCallback:callback];
    Open_im_sdkFindMessageList(proxy, opid,[findOptions json]);
}

UNI_EXPORT_METHOD(@selector(getAdvancedHistoryMessageList:messageOptions:callback:))

- (void)getAdvancedHistoryMessageList:(NSString *)opid messageOptions:(NSDictionary *)messageOptions callback:(UniModuleKeepAliveCallback)callback {
    CallbackProxy *proxy = [[CallbackProxy alloc] initWithCallback:callback];
    Open_im_sdkGetAdvancedHistoryMessageList(proxy,opid, [messageOptions json]);
}

UNI_EXPORT_METHOD(@selector(getAdvancedHistoryMessageListReverse:messageOptions:callback:))

- (void)getAdvancedHistoryMessageListReverse:(NSString *)opid messageOptions:(NSDictionary *)messageOptions callback:(UniModuleKeepAliveCallback)callback {
    CallbackProxy *proxy = [[CallbackProxy alloc] initWithCallback:callback];
    Open_im_sdkGetAdvancedHistoryMessageListReverse(proxy,opid, [messageOptions json]);
}

UNI_EXPORT_METHOD(@selector(revokeMessage:options:callback:))

- (void)revokeMessage:(NSString *)opid options:(NSDictionary *)options callback:(UniModuleKeepAliveCallback)callback {
    CallbackProxy *proxy = [[CallbackProxy alloc] initWithCallback:callback];
    Open_im_sdkRevokeMessage(proxy,opid, [options valueForKey:@"conversationID"], [options valueForKey:@"clientMsgID"]);
}

UNI_EXPORT_METHOD(@selector(typingStatusUpdate:options:callback:))

- (void)typingStatusUpdate:(NSString *)opid options:(NSDictionary *)options callback:(UniModuleKeepAliveCallback)callback {
    CallbackProxy *proxy = [[CallbackProxy alloc] initWithCallback:callback];
    Open_im_sdkTypingStatusUpdate(proxy,opid,[options valueForKey:@"recvID"], [options valueForKey:@"msgTip"]);
}

UNI_EXPORT_METHOD(@selector(markConversationMessageAsRead:conversationID:callback:))

- (void)markConversationMessageAsRead:(NSString *)opid conversationID:(NSString *)conversationID  callback:(UniModuleKeepAliveCallback)callback {
    CallbackProxy *proxy = [[CallbackProxy alloc] initWithCallback:callback];
    Open_im_sdkMarkConversationMessageAsRead(proxy,opid,conversationID);
}

UNI_EXPORT_METHOD(@selector(markMessagesAsReadByMsgID:options:callback:))

- (void)markMessagesAsReadByMsgID:(NSString *)opid options:(NSDictionary *)options callback:(UniModuleKeepAliveCallback)callback {
    NSArray* clientMsgIDList = [options valueForKey:@"clientMsgIDList"];
    CallbackProxy *proxy = [[CallbackProxy alloc] initWithCallback:callback];
    Open_im_sdkMarkMessagesAsReadByMsgID(proxy,opid, [options valueForKey:@"conversationID"], [clientMsgIDList json]);
}

UNI_EXPORT_METHOD(@selector(deleteMessageFromLocalStorage:coptions:callback:))

- (void)deleteMessageFromLocalStorage:(NSString *)opid coptions:(NSDictionary *)options callback:(UniModuleKeepAliveCallback)callback {
    CallbackProxy *proxy = [[CallbackProxy alloc] initWithCallback:callback];
    Open_im_sdkDeleteMessageFromLocalStorage(proxy,opid, [options valueForKey:@"conversationID"],[options valueForKey:@"clientMsgID"]);
}

UNI_EXPORT_METHOD(@selector(deleteMessage:options:callback:))

- (void)deleteMessage:(NSString *)opid options:(NSDictionary *)options callback:(UniModuleKeepAliveCallback)callback {
    CallbackProxy *proxy = [[CallbackProxy alloc] initWithCallback:callback];
    Open_im_sdkDeleteMessage(proxy,opid, [options valueForKey:@"conversationID"],[options valueForKey:@"clientMsgID"]);
}

// UNI_EXPORT_METHOD(@selector(deleteConversationFromLocal:conversationID:callback:))

// - (void)deleteConversationFromLocal:(NSString *)opid conversationID:(NSString *)conversationID callback:(UniModuleKeepAliveCallback)callback {
//     CallbackProxy *proxy = [[CallbackProxy alloc] initWithCallback:callback];
//     Open_im_sdkDeleteConversationFromLocal(proxy, opid,conversationID);
// }

UNI_EXPORT_METHOD(@selector(deleteAllMsgFromLocalAndSvr:callback:))

- (void)deleteAllMsgFromLocalAndSvr:(NSString *)opid callback:(UniModuleKeepAliveCallback)callback {
    CallbackProxy *proxy = [[CallbackProxy alloc] initWithCallback:callback];
    Open_im_sdkDeleteAllMsgFromLocalAndSvr(proxy,opid);
}

UNI_EXPORT_METHOD(@selector(deleteAllMsgFromLocal:callback:))

- (void)deleteAllMsgFromLocal:(NSString *)opid callback:(UniModuleKeepAliveCallback)callback {
    CallbackProxy *proxy = [[CallbackProxy alloc] initWithCallback:callback];
    Open_im_sdkDeleteAllMsgFromLocal(proxy,opid);
}

UNI_EXPORT_METHOD(@selector(clearConversationAndDeleteAllMsg:conversationID:callback:))

- (void)clearConversationAndDeleteAllMsg:(NSString *)opid conversationID:(NSString *)conversationID callback:(UniModuleKeepAliveCallback)callback {
    CallbackProxy *proxy = [[CallbackProxy alloc] initWithCallback:callback];
    Open_im_sdkClearConversationAndDeleteAllMsg(proxy,opid,conversationID);
}

UNI_EXPORT_METHOD(@selector(deleteConversationAndDeleteAllMsg:conversationID:callback:))

- (void)deleteConversationAndDeleteAllMsg:(NSString *)opid conversationID:(NSString *)conversationID callback:(UniModuleKeepAliveCallback)callback {
    CallbackProxy *proxy = [[CallbackProxy alloc] initWithCallback:callback];
    Open_im_sdkDeleteConversationAndDeleteAllMsg(proxy,opid,conversationID);
}

UNI_EXPORT_METHOD(@selector(insertSingleMessageToLocalStorage:options:callback:))

- (void)insertSingleMessageToLocalStorage:(NSString *)opid options:(NSDictionary *)options callback:(UniModuleKeepAliveCallback)callback {
    NSDictionary *message = [options valueForKey:@"message"];
    CallbackProxy *proxy = [[CallbackProxy alloc] initWithCallback:callback];
    Open_im_sdkInsertSingleMessageToLocalStorage(proxy,opid, [message json], [options valueForKey:@"recvID"], [options valueForKey:@"sendID"]);
}

UNI_EXPORT_METHOD(@selector(insertGroupMessageToLocalStorage:options:callback:))

- (void)insertGroupMessageToLocalStorage:(NSString *)opid options:(NSDictionary *)options callback:(UniModuleKeepAliveCallback)callback {
     NSDictionary *message = [options valueForKey:@"message"];
    CallbackProxy *proxy = [[CallbackProxy alloc] initWithCallback:callback];
    Open_im_sdkInsertGroupMessageToLocalStorage(proxy,opid, [message json], [options valueForKey:@"recvID"], [options valueForKey:@"sendID"]);
}

UNI_EXPORT_METHOD(@selector(searchLocalMessages:searchParam:callback:))

- (void)searchLocalMessages:(NSString *)opid searchParam:(NSDictionary *)searchParam callback:(UniModuleKeepAliveCallback)callback {
    CallbackProxy *proxy = [[CallbackProxy alloc] initWithCallback:callback];
    Open_im_sdkSearchLocalMessages(proxy, opid, [searchParam json]);
}

UNI_EXPORT_METHOD(@selector(setMessageLocalEx:options:callback:))

- (void)setMessageLocalEx:(NSString *)opid options:(NSDictionary *)options callback:(UniModuleKeepAliveCallback)callback {
    CallbackProxy *proxy = [[CallbackProxy alloc] initWithCallback:callback];
    Open_im_sdkSetMessageLocalEx(proxy,opid,[options valueForKey:@"conversationID"],[options valueForKey:@"clientMsgID"],[options valueForKey:@"localEx"]);
}

// MARK: - Friend

UNI_EXPORT_METHOD(@selector(getSpecifiedFriendsInfo:userIDList:callback:))

- (void)getSpecifiedFriendsInfo:(NSString *)opid userIDList:(NSArray *)userIDList callback:(UniModuleKeepAliveCallback)callback {
    CallbackProxy *proxy = [[CallbackProxy alloc] initWithCallback:callback];
    Open_im_sdkGetSpecifiedFriendsInfo(proxy, opid,[userIDList json]);
}

UNI_EXPORT_METHOD(@selector(getFriendList:callback:))

- (void)getFriendList:(NSString *)opid callback:(UniModuleKeepAliveCallback)callback  {
    CallbackProxy *proxy = [[CallbackProxy alloc] initWithCallback:callback];
    Open_im_sdkGetFriendList(proxy,opid);
}

UNI_EXPORT_METHOD(@selector(getFriendListPage:options:callback:))

- (void)getFriendListPage:(NSString *)opid options:(NSDictionary *)options callback:(UniModuleKeepAliveCallback)callback  {
    CallbackProxy *proxy = [[CallbackProxy alloc] initWithCallback:callback];
    Open_im_sdkGetFriendListPage(proxy,opid,[[options valueForKey:@"offset"] intValue],[[options valueForKey:@"count"] intValue]);
}

UNI_EXPORT_METHOD(@selector(searchFriends:options:callback:))

- (void)searchFriends:(NSString *)opid options:(NSDictionary *)options callback:(UniModuleKeepAliveCallback)callback {
    CallbackProxy *proxy = [[CallbackProxy alloc] initWithCallback:callback];
    Open_im_sdkSearchFriends(proxy,opid, [options json]);
}

UNI_EXPORT_METHOD(@selector(checkFriend:userIdList:callback:))

- (void)checkFriend:(NSString *)opid userIdList:(NSArray *)userIdList callback:(UniModuleKeepAliveCallback)callback {
    CallbackProxy *proxy = [[CallbackProxy alloc] initWithCallback:callback];
    Open_im_sdkCheckFriend(proxy,opid, [userIdList json]);
}


UNI_EXPORT_METHOD(@selector(addFriend:userIDReqMsg:callback:))

- (void)addFriend:(NSString *)opid userIDReqMsg:(NSDictionary *)userIDReqMsg callback:(UniModuleKeepAliveCallback)callback {
    CallbackProxy *proxy = [[CallbackProxy alloc] initWithCallback:callback];
    Open_im_sdkAddFriend(proxy,opid, [userIDReqMsg json]);
}

UNI_EXPORT_METHOD(@selector(setFriendRemark:userIDRemark:callback:))

- (void)setFriendRemark:(NSString *)opid userIDRemark:(NSDictionary *)userIDRemark callback:(UniModuleKeepAliveCallback)callback {
    CallbackProxy *proxy = [[CallbackProxy alloc] initWithCallback:callback];
    Open_im_sdkSetFriendRemark(proxy, opid,[userIDRemark json]);
}

UNI_EXPORT_METHOD(@selector(deleteFriend:friendUserID:callback:))

- (void)deleteFriend:(NSString *)opid friendUserID:(NSString *)friendUserID callback:(UniModuleKeepAliveCallback)callback {
    CallbackProxy *proxy = [[CallbackProxy alloc] initWithCallback:callback];
    Open_im_sdkDeleteFriend(proxy, opid, friendUserID );
}

UNI_EXPORT_METHOD(@selector(getFriendApplicationListAsRecipient:callback:))

- (void)getFriendApplicationListAsRecipient:(NSString *)opid callback:(UniModuleKeepAliveCallback)callback {
    CallbackProxy *proxy = [[CallbackProxy alloc] initWithCallback:callback];
    Open_im_sdkGetFriendApplicationListAsRecipient(proxy,opid);
}

UNI_EXPORT_METHOD(@selector(getFriendApplicationListAsApplicant:callback:))

- (void)getFriendApplicationListAsApplicant:(NSString *)opid callback:(UniModuleKeepAliveCallback)callback {
    CallbackProxy *proxy = [[CallbackProxy alloc] initWithCallback:callback];
    Open_im_sdkGetFriendApplicationListAsApplicant(proxy,opid);
}

UNI_EXPORT_METHOD(@selector(acceptFriendApplication:userIDHandleMsg:callback:))

- (void)acceptFriendApplication:(NSString *)opid userIDHandleMsg:(NSDictionary *)userIDHandleMsg callback:(UniModuleKeepAliveCallback)callback {
    CallbackProxy *proxy = [[CallbackProxy alloc] initWithCallback:callback];
    Open_im_sdkAcceptFriendApplication(proxy,opid, [userIDHandleMsg json]);
}

UNI_EXPORT_METHOD(@selector(refuseFriendApplication:userIDHandleMsg:callback:))

- (void)refuseFriendApplication:(NSString *)opid userIDHandleMsg:(NSDictionary *)userIDHandleMsg callback:(UniModuleKeepAliveCallback)callback {
    CallbackProxy *proxy = [[CallbackProxy alloc] initWithCallback:callback];
    Open_im_sdkRefuseFriendApplication(proxy,opid, [userIDHandleMsg json]);
}


UNI_EXPORT_METHOD(@selector(addBlack:options:callback:))

- (void)addBlack:(NSString *)opid options:(NSDictionary *)options callback:(UniModuleKeepAliveCallback)callback {
    CallbackProxy *proxy = [[CallbackProxy alloc] initWithCallback:callback];
    NSString *ex = [options valueForKey:@"ex"];
    if (ex == nil){
        ex = @"";
    }
    Open_im_sdkAddBlack(proxy, opid, [options valueForKey:@"toUserID"], ex);
}

UNI_EXPORT_METHOD(@selector(getBlackList:callback:))

- (void)getBlackList:(NSString *)opid callback:(UniModuleKeepAliveCallback)callback {
    CallbackProxy *proxy = [[CallbackProxy alloc] initWithCallback:callback];
    Open_im_sdkGetBlackList(proxy,opid);
}

UNI_EXPORT_METHOD(@selector(removeBlack:removeUserID:callback:))

- (void)removeBlack:(NSString *)opid removeUserID:(NSString *)removeUserID callback:(UniModuleKeepAliveCallback)callback {
    CallbackProxy *proxy = [[CallbackProxy alloc] initWithCallback:callback];
    Open_im_sdkRemoveBlack(proxy, opid, removeUserID );
}

// MARK: - Group

UNI_EXPORT_METHOD(@selector(createGroup:groupBaseInfo:callback:))

- (void)createGroup:(NSString *)opid groupBaseInfo:(NSDictionary *)groupBaseInfo callback:(UniModuleKeepAliveCallback)callback {
    CallbackProxy *proxy = [[CallbackProxy alloc] initWithCallback:callback];
    Open_im_sdkCreateGroup(proxy,opid,[groupBaseInfo json]);
}

UNI_EXPORT_METHOD(@selector(joinGroup:options:callback:))

- (void)joinGroup:(NSString *)opid options:(NSDictionary *)options callback:(UniModuleKeepAliveCallback)callback {
    CallbackProxy *proxy = [[CallbackProxy alloc] initWithCallback:callback];
    NSString *ex = [options valueForKey:@"ex"];
    if (ex == nil){
        ex = @"";
    }
    Open_im_sdkJoinGroup(proxy,opid,[options valueForKey:@"groupID"], [options valueForKey:@"reqMsg"],[[options valueForKey:@"joinSource"] intValue], ex);
}

UNI_EXPORT_METHOD(@selector(quitGroup:groupID:callback:))

- (void)quitGroup:(NSString *)opid groupID:(NSString *)groupID callback:(UniModuleKeepAliveCallback)callback {
    CallbackProxy *proxy = [[CallbackProxy alloc] initWithCallback:callback];
    Open_im_sdkQuitGroup(proxy,opid, groupID );
}

UNI_EXPORT_METHOD(@selector(dismissGroup:groupID:callback:))

- (void)dismissGroup:(NSString *)opid groupID:(NSString *)groupID callback:(UniModuleKeepAliveCallback)callback {
    CallbackProxy *proxy = [[CallbackProxy alloc] initWithCallback:callback];
    Open_im_sdkDismissGroup(proxy,opid,groupID);
}

UNI_EXPORT_METHOD(@selector(changeGroupMute:options:callback:))

- (void)changeGroupMute:(NSString *)opid options:(NSDictionary *)options callback:(UniModuleKeepAliveCallback)callback {
    CallbackProxy *proxy = [[CallbackProxy alloc] initWithCallback:callback];
    Open_im_sdkChangeGroupMute(proxy,opid,[options valueForKey:@"groupID"],[[options valueForKey:@"isMute"] boolValue]);
}

UNI_EXPORT_METHOD(@selector(changeGroupMemberMute:options:callback:))

- (void)changeGroupMemberMute:(NSString *)opid options:(NSDictionary *)options callback:(UniModuleKeepAliveCallback)callback {
    CallbackProxy *proxy = [[CallbackProxy alloc] initWithCallback:callback];
    Open_im_sdkChangeGroupMemberMute(proxy,opid,[options valueForKey:@"groupID"],[options valueForKey:@"userID"],[[options valueForKey:@"mutedSeconds"] longValue]);
}

UNI_EXPORT_METHOD(@selector(setGroupMemberRoleLevel:options:callback:))

- (void)setGroupMemberRoleLevel:(NSString *)opid options:(NSDictionary *)options callback:(UniModuleKeepAliveCallback)callback {
    CallbackProxy *proxy = [[CallbackProxy alloc] initWithCallback:callback];
    Open_im_sdkSetGroupMemberRoleLevel(proxy,opid, [options valueForKey:@"groupID"],[options valueForKey:@"userID"],[[options valueForKey:@"roleLevel"] longValue]);
}

UNI_EXPORT_METHOD(@selector(setGroupMemberInfo:memeberInfo:callback:))

- (void)setGroupMemberInfo:(NSString *)opid memeberInfo:(NSDictionary *)memeberInfo callback:(UniModuleKeepAliveCallback)callback {
    CallbackProxy *proxy = [[CallbackProxy alloc] initWithCallback:callback];
    Open_im_sdkSetGroupMemberInfo(proxy,opid, [memeberInfo json]);
}

UNI_EXPORT_METHOD(@selector(getJoinedGroupList:callback:))

- (void)getJoinedGroupList:(NSString *)opid callback:(UniModuleKeepAliveCallback)callback {
    CallbackProxy *proxy = [[CallbackProxy alloc] initWithCallback:callback];
    Open_im_sdkGetJoinedGroupList(proxy,opid);
}

UNI_EXPORT_METHOD(@selector(getSpecifiedGroupsInfo:groupIDList:callback:))

- (void)getSpecifiedGroupsInfo:(NSString *)opid groupIDList:(NSArray *)groupIDList callback:(UniModuleKeepAliveCallback)callback {
    CallbackProxy *proxy = [[CallbackProxy alloc] initWithCallback:callback];
    Open_im_sdkGetSpecifiedGroupsInfo(proxy,opid,[groupIDList json]);
}

UNI_EXPORT_METHOD(@selector(searchGroups:options:callback:))

- (void)searchGroups:(NSString *)opid options:(NSDictionary *)options callback:(UniModuleKeepAliveCallback)callback {
    CallbackProxy *proxy = [[CallbackProxy alloc] initWithCallback:callback];
    Open_im_sdkSearchGroups(proxy,opid, [options json]);
}

UNI_EXPORT_METHOD(@selector(setGroupInfo:groupInfo:callback:))

- (void)setGroupInfo:(NSString *)opid groupInfo:(NSDictionary *)groupInfo callback:(UniModuleKeepAliveCallback)callback {
    CallbackProxy *proxy = [[CallbackProxy alloc] initWithCallback:callback];
    Open_im_sdkSetGroupInfo(proxy,opid,[groupInfo json]);
}

UNI_EXPORT_METHOD(@selector(setGroupVerification:options:callback:))

- (void)setGroupVerification:(NSString *)opid options:(NSDictionary *)options callback:(UniModuleKeepAliveCallback)callback {
    CallbackProxy *proxy = [[CallbackProxy alloc] initWithCallback:callback];
    Open_im_sdkSetGroupVerification(proxy,opid, [options valueForKey:@"groupID"],[[options valueForKey:@"verification"] intValue]);
}

UNI_EXPORT_METHOD(@selector(setGroupLookMemberInfo:options:callback:))

- (void)setGroupLookMemberInfo:(NSString *)opid options:(NSDictionary *)options  callback:(UniModuleKeepAliveCallback)callback {
    CallbackProxy *proxy = [[CallbackProxy alloc] initWithCallback:callback];
    Open_im_sdkSetGroupLookMemberInfo(proxy,opid,[options valueForKey:@"groupID"],[[options valueForKey:@"rule"] intValue]);
}

UNI_EXPORT_METHOD(@selector(setGroupApplyMemberFriend:options:callback:))

- (void)setGroupApplyMemberFriend:(NSString *)opid options:(NSDictionary *)options callback:(UniModuleKeepAliveCallback)callback {
    CallbackProxy *proxy = [[CallbackProxy alloc] initWithCallback:callback];
    Open_im_sdkSetGroupApplyMemberFriend(proxy,opid,[options valueForKey:@"groupID"],[[options valueForKey:@"rule"] intValue]);
}

UNI_EXPORT_METHOD(@selector(getGroupMemberList:options:callback:))

- (void)getGroupMemberList:(NSString *)opid options:(NSDictionary *)options callback:(UniModuleKeepAliveCallback)callback {
    CallbackProxy *proxy = [[CallbackProxy alloc] initWithCallback:callback];
    Open_im_sdkGetGroupMemberList(proxy,opid,[options valueForKey:@"groupID"], [[options valueForKey:@"filter"] intValue], [[options valueForKey:@"offset"] intValue], [[options valueForKey:@"count"] intValue]);
}

UNI_EXPORT_METHOD(@selector(getGroupMemberOwnerAndAdmin:groupID:callback:))

- (void)getGroupMemberOwnerAndAdmin:(NSString *)opid groupID:(NSString *)groupID  callback:(UniModuleKeepAliveCallback)callback {
    CallbackProxy *proxy = [[CallbackProxy alloc] initWithCallback:callback];
    Open_im_sdkGetGroupMemberOwnerAndAdmin(proxy,opid,groupID);
}

UNI_EXPORT_METHOD(@selector(getGroupMemberListByJoinTimeFilter:options:callback:))

- (void)getGroupMemberListByJoinTimeFilter:(NSString *)opid options:(NSDictionary *)options callback:(UniModuleKeepAliveCallback)callback {
    NSArray* filterUserIDList = [options valueForKey:@"filterUserIDList"];
    CallbackProxy *proxy = [[CallbackProxy alloc] initWithCallback:callback];
    Open_im_sdkGetGroupMemberListByJoinTimeFilter(proxy,opid,[options valueForKey:@"groupID"],[[options valueForKey:@"offset"] intValue],[[options valueForKey:@"count"] intValue],[[options valueForKey:@"joinTimeBegin"] intValue],[[options valueForKey:@"joinTimeEnd"] intValue],[filterUserIDList json]);
}

UNI_EXPORT_METHOD(@selector(getSpecifiedGroupMembersInfo:options:callback:))

- (void)getSpecifiedGroupMembersInfo:(NSString *)opid options:(NSDictionary *)options callback:(UniModuleKeepAliveCallback)callback {
    NSArray *userIDList = [options valueForKey:@"userIDList"];
    CallbackProxy *proxy = [[CallbackProxy alloc] initWithCallback:callback];
    Open_im_sdkGetSpecifiedGroupMembersInfo(proxy,opid, [options valueForKey:@"groupID"],[userIDList json]);
}

UNI_EXPORT_METHOD(@selector(kickGroupMember:options:callback:))

- (void)kickGroupMember:(NSString *)opid options:(NSDictionary *)options callback:(UniModuleKeepAliveCallback)callback {
    NSArray *userIDList = [options valueForKey:@"userIDList"];
    CallbackProxy *proxy = [[CallbackProxy alloc] initWithCallback:callback];
    Open_im_sdkKickGroupMember(proxy ,opid, [options valueForKey:@"groupID"], [options valueForKey:@"reason"],[userIDList json]);
}

UNI_EXPORT_METHOD(@selector(transferGroupOwner:options:callback:))

- (void)transferGroupOwner:(NSString *)opid options:(NSDictionary *)options callback:(UniModuleKeepAliveCallback)callback {
    CallbackProxy *proxy = [[CallbackProxy alloc] initWithCallback:callback];
    Open_im_sdkTransferGroupOwner(proxy,opid, [options valueForKey:@"groupID"], [options valueForKey:@"newOwnerUserID"]);
}

UNI_EXPORT_METHOD(@selector(inviteUserToGroup:options:callback:))

- (void)inviteUserToGroup:(NSString *)opid options:(NSDictionary *)options callback:(UniModuleKeepAliveCallback)callback {
    NSArray *userIDList = [options valueForKey:@"userIDList"];
    CallbackProxy *proxy = [[CallbackProxy alloc] initWithCallback:callback];
    Open_im_sdkInviteUserToGroup(proxy, opid, [options valueForKey:@"groupID"], [options valueForKey:@"reason"], [userIDList json]);
}

UNI_EXPORT_METHOD(@selector(getGroupApplicationListAsRecipient:callback:))

- (void)getGroupApplicationListAsRecipient:(NSString *)opid callback:(UniModuleKeepAliveCallback)callback {
    CallbackProxy *proxy = [[CallbackProxy alloc] initWithCallback:callback];
    Open_im_sdkGetGroupApplicationListAsRecipient(proxy,opid);
}

UNI_EXPORT_METHOD(@selector(getGroupApplicationListAsApplicant:callback:))

- (void)getGroupApplicationListAsApplicant:(NSString *)opid callback:(UniModuleKeepAliveCallback)callback {
    CallbackProxy *proxy = [[CallbackProxy alloc] initWithCallback:callback];
    Open_im_sdkGetGroupApplicationListAsApplicant(proxy,opid);
}

UNI_EXPORT_METHOD(@selector(acceptGroupApplication:options:callback:))

- (void)acceptGroupApplication:(NSString *)opid options:(NSDictionary *)options callback:(UniModuleKeepAliveCallback)callback {
    CallbackProxy *proxy = [[CallbackProxy alloc] initWithCallback:callback];
    Open_im_sdkAcceptGroupApplication(proxy,opid, [options valueForKey:@"groupID"], [options valueForKey:@"fromUserID"],[options valueForKey:@"handleMsg"]);
}

UNI_EXPORT_METHOD(@selector(refuseGroupApplication:options:callback:))

- (void)refuseGroupApplication:(NSString *)opid options:(NSDictionary *)options callback:(UniModuleKeepAliveCallback)callback {
    CallbackProxy *proxy = [[CallbackProxy alloc] initWithCallback:callback];
    Open_im_sdkRefuseGroupApplication(proxy,opid, [options valueForKey:@"groupID"], [options valueForKey:@"fromUserID"],[options valueForKey:@"handleMsg"]);
}

UNI_EXPORT_METHOD(@selector(setGroupMemberNickname:options:callback:))

- (void)setGroupMemberNickname:(NSString *)opid options:(NSDictionary *)options callback:(UniModuleKeepAliveCallback)callback {
    CallbackProxy *proxy = [[CallbackProxy alloc] initWithCallback:callback];
    Open_im_sdkSetGroupMemberNickname(proxy,opid,[options valueForKey:@"groupID"], [options valueForKey:@"userID"],[options valueForKey:@"groupMemberNickname"]);
}

UNI_EXPORT_METHOD(@selector(searchGroupMembers:searchOptions:callback:))

- (void)searchGroupMembers:(NSString *)opid searchOptions:(NSDictionary *)searchOptions callback:(UniModuleKeepAliveCallback)callback {
    CallbackProxy *proxy = [[CallbackProxy alloc] initWithCallback:callback];
    Open_im_sdkSearchGroupMembers(proxy,opid,[searchOptions json]);
}

UNI_EXPORT_METHOD(@selector(isJoinGroup:groupID:callback:))

- (void)isJoinGroup:(NSString *)opid groupID:(NSString *)groupID callback:(UniModuleKeepAliveCallback)callback {
    CallbackProxy *proxy = [[CallbackProxy alloc] initWithCallback:callback];
    Open_im_sdkIsJoinGroup(proxy,opid,groupID);
}


// MARK: - Third

UNI_EXPORT_METHOD(@selector(setAppBadge:appUnreadCount:callback:))

- (void)setAppBadge:(NSString *)opid appUnreadCount:(int32_t)appUnreadCount callback:(UniModuleKeepAliveCallback)callback {
    CallbackProxy *proxy = [[CallbackProxy alloc] initWithCallback:callback];
    Open_im_sdkSetAppBadge(proxy,opid,appUnreadCount);
}

UNI_EXPORT_METHOD(@selector(uploadLogs:data:callback:))

- (void)uploadLogs:(NSString *)opid data:(NSArray *)data callback:(UniModuleKeepAliveCallback)callback {
    CallbackProxy *proxy = [[CallbackProxy alloc] initWithCallback:callback];
    UploadLogsCallbackProxy *uploadProxy = [[UploadLogsCallbackProxy alloc] initWithOpid:opid module:self];
    Open_im_sdkUploadLogs(proxy,opid,[data json],uploadProxy);
}

UNI_EXPORT_METHOD(@selector(getSdkVersion))

- (NSString *)getSdkVersion{
    return Open_im_sdkGetSdkVersion();
}

UNI_EXPORT_METHOD(@selector(uploadFile:reqData:callback:))

- (void)uploadFile:(NSString *)opid reqData:(NSDictionary *)reqData callback:(UniModuleKeepAliveCallback)callback {
    CallbackProxy *proxy = [[CallbackProxy alloc] initWithCallback:callback];
    UploadFileCallbackProxy *uploadProxy = [[UploadFileCallbackProxy alloc] initWithOpid:opid module:self];
    Open_im_sdkUploadFile(proxy,opid, [reqData json],uploadProxy);
}

// MARK: - utils
- (NSDictionary *)parseJsonStr2Dict:(NSString *)jsonStr {
    NSData *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    if (error) {
        NSLog(@"Error while parsing JSON: %@", error.localizedDescription);
        return nil;
    }
    NSDictionary *data = (NSDictionary *)jsonObject;
    return data;
}

- (NSArray *)parseJsonStr2Array:(NSString *)jsonStr {
    NSData *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    if (error) {
        NSLog(@"Error while parsing JSON: %@", error.localizedDescription);
        return nil;
    }
    NSArray *data = (NSArray *)jsonObject;
    return data;
}

// MARK: - Open_im_sdk_callbackOnConnListener
- (void)onConnectFailed:(int32_t)errCode errMsg:(NSString* _Nullable)errMsg{
    NSDictionary *param = @{
        @"err":errMsg,
        @"errCode": @(errCode)
    };
    [self.uniInstance fireGlobalEvent:@"onConnectFailed" params:param];
}

- (void)onConnectSuccess {
    NSDictionary *param = @{
        @"err":@"",
        @"errCode": @(0)
    };
    [self.uniInstance fireGlobalEvent:@"onConnectSuccess" params:param];
}

- (void)onConnecting {
    NSDictionary *param = @{
        @"err":@"",
        @"errCode": @(0)
    };
    [self.uniInstance fireGlobalEvent:@"onConnecting" params:param];
}

- (void)onKickedOffline {
    NSDictionary *param = @{
        @"err":@"",
        @"errCode": @(0)
    };
    [self.uniInstance fireGlobalEvent:@"onKickedOffline" params:param];
}


- (void)onUserTokenExpired {
    NSDictionary *param = @{
        @"err":@"",
        @"errCode": @(0)
    };
    [self.uniInstance fireGlobalEvent:@"onUserTokenExpired" params:param];
}


// MARK: - Open_im_sdk_callbackOnUserListener

- (void)onSelfInfoUpdated:(NSString* _Nullable)userInfo {
    NSDictionary *data = [self parseJsonStr2Dict:userInfo];
    NSDictionary *param = @{
        @"data":data,
    };
    [self.uniInstance fireGlobalEvent:@"onSelfInfoUpdated" params:param];
}

- (void)onUserStatusChanged:(NSString* _Nullable)statusMap {
    NSDictionary *data = [self parseJsonStr2Dict:statusMap];
    NSDictionary *param = @{
        @"data":data,
    };
    [self.uniInstance fireGlobalEvent:@"onUserStatusChanged" params:param];
}


// MARK: - Open_im_sdk_callbackOnBatchMsgListener

- (void)onRecvNewMessages:(NSString * _Nullable)messageList {
    NSArray *messageListArray = [self parseJsonStr2Array:messageList];
    NSDictionary *param = @{
        @"data":messageListArray,
    };
    PUSH_EVENT(param)
}

- (void)onRecvOfflineNewMessages:(NSString* _Nullable)messageList {
    NSArray *messageListArray = [self parseJsonStr2Array:messageList];
    NSDictionary *param = @{
        @"data":messageListArray,
    };
    PUSH_EVENT(param)
}

// MARK: - Open_im_sdk_callbackOnAdvancedMsgListener

- (void)onMsgDeleted:(NSString* _Nullable)message {
    NSDictionary *messageDict = [self parseJsonStr2Dict:message];
    NSDictionary *param = @{
        @"data":messageDict,
    };
    PUSH_EVENT(param)
}

- (void)onNewRecvMessageRevoked:(NSString *)messageRevoked {
    NSDictionary *messageRevokedDict = [self parseJsonStr2Dict:messageRevoked];
    NSDictionary *param = @{
        @"data":messageRevokedDict,
    };
    PUSH_EVENT(param)
}

- (void)onRecvC2CReadReceipt:(NSString* _Nullable)msgReceiptList {
    NSArray *msgReceiptListArray = [self parseJsonStr2Array:msgReceiptList];
    NSDictionary *param = @{
        @"data":msgReceiptListArray,
    };
    PUSH_EVENT(param)
}

- (void)onRecvGroupReadReceipt:(NSString* _Nullable)groupMsgReceiptList {
    NSArray *msgReceiptListArray = [self parseJsonStr2Dict:groupMsgReceiptList];
    NSDictionary *param = @{
        @"data":msgReceiptListArray,
    };
    PUSH_EVENT(param)
}

- (void)onRecvMessageExtensionsAdded:(NSString * _Nullable)msgID reactionExtensionList:(NSString * _Nullable)reactionExtensionList {
    
}


- (void)onRecvMessageExtensionsChanged:(NSString * _Nullable)msgID reactionExtensionList:(NSString * _Nullable)reactionExtensionList {
    
}


- (void)onRecvMessageExtensionsDeleted:(NSString * _Nullable)msgID reactionExtensionKeyList:(NSString * _Nullable)reactionExtensionKeyList {
    
}

- (void)onRecvNewMessage:(NSString* _Nullable)message {
    NSDictionary *messageDict = [self parseJsonStr2Dict:message];
    NSDictionary *param = @{
        @"data":messageDict,
    };
    PUSH_EVENT(param)
}

- (void)onRecvOfflineNewMessage:(NSString* _Nullable)message {
    NSDictionary *messageDict = [self parseJsonStr2Dict:message];
    NSDictionary *param = @{
        @"data":messageDict,
    };
    PUSH_EVENT(param)
}

- (void)onRecvOnlineOnlyMessage:(NSString* _Nullable)message {
    NSDictionary *messageDict = [self parseJsonStr2Dict:message];
    NSDictionary *param = @{
        @"data":messageDict,
    };
    PUSH_EVENT(param)
}

// MARK: - Open_im_sdk_callbackOnConversationListener

- (void)onConversationChanged:(NSString* _Nullable)conversationList {
    NSArray *conversationListArray = [self parseJsonStr2Array:conversationList];
    NSDictionary *param = @{
        @"data":conversationListArray,
    };
    PUSH_EVENT(param)
}

- (void)onConversationUserInputStatusChanged:(NSString* _Nullable)change {
    
}

- (void)onNewConversation:(NSString* _Nullable)conversationList {
    NSArray *conversationListArray = [self parseJsonStr2Array:conversationList];
    NSDictionary *param = @{
        @"data":conversationListArray,
    };
    PUSH_EVENT(param)
}

- (void)onSyncServerFailed {
    NSDictionary *param = @{
        @"errMsg":@"",
        @"errCode": @(0)
    };
    [self.uniInstance fireGlobalEvent:@"onSyncServerFailed" params:param];
}

- (void)onSyncServerFinish {
    NSDictionary *param = @{
        @"errMsg":@"",
        @"errCode": @(0)
    };
    [self.uniInstance fireGlobalEvent:@"onSyncServerFinish" params:param];
}

- (void)onSyncServerStart {
    NSDictionary *param = @{
        @"errMsg":@"",
        @"errCode": @(0)
    };
    [self.uniInstance fireGlobalEvent:@"onSyncServerStart" params:param];
}

- (void)onTotalUnreadMessageCountChanged:(int32_t)totalUnreadCount {
    NSDictionary *param = @{
        @"data":@(totalUnreadCount),
    };
    PUSH_EVENT(param)
}


// MARK: - Open_im_sdk_callbackOnFriendshipListener


- (void)onBlackAdded:(NSString* _Nullable)blackInfo{
    NSDictionary *blackInfoDict = [self parseJsonStr2Dict:blackInfo];
    NSDictionary *param = @{
        @"data":blackInfoDict,
    };
    PUSH_EVENT(param)
}
- (void)onBlackDeleted:(NSString* _Nullable)blackInfo{
    NSDictionary *blackInfoDict = [self parseJsonStr2Dict:blackInfo];
    NSDictionary *param = @{
        @"data":blackInfoDict,
    };
    PUSH_EVENT(param)
}
- (void)onFriendAdded:(NSString* _Nullable)friendInfo{
    NSDictionary *friendInfoDict = [self parseJsonStr2Dict:friendInfo];
    NSDictionary *param = @{
        @"data":friendInfoDict,
    };
    PUSH_EVENT(param)
}
- (void)onFriendApplicationAccepted:(NSString* _Nullable)friendApplication{
    NSDictionary *friendApplicationDict = [self parseJsonStr2Dict:friendApplication];
    NSDictionary *param = @{
        @"data":friendApplicationDict,
    };
    PUSH_EVENT(param)
}
- (void)onFriendApplicationAdded:(NSString* _Nullable)friendApplication{
    NSDictionary *friendApplicationDict = [self parseJsonStr2Dict:friendApplication];
    NSDictionary *param = @{
        @"data":friendApplicationDict,
    };
    PUSH_EVENT(param)
}
- (void)onFriendApplicationDeleted:(NSString* _Nullable)friendApplication{
    NSDictionary *friendApplicationDict = [self parseJsonStr2Dict:friendApplication];
    NSDictionary *param = @{
        @"data":friendApplicationDict,
    };
    PUSH_EVENT(param)
}
- (void)onFriendApplicationRejected:(NSString* _Nullable)friendApplication{
    NSDictionary *friendApplicationDict = [self parseJsonStr2Dict:friendApplication];
    NSDictionary *param = @{
        @"data":friendApplicationDict,
    };
    PUSH_EVENT(param)
}
- (void)onFriendDeleted:(NSString* _Nullable)friendInfo{
    NSDictionary *friendInfoDict = [self parseJsonStr2Dict:friendInfo];
    NSDictionary *param = @{
        @"data":friendInfoDict,
    };
    PUSH_EVENT(param)
}
- (void)onFriendInfoChanged:(NSString* _Nullable)friendInfo{
    NSDictionary *friendInfoDict = [self parseJsonStr2Dict:friendInfo];
    NSDictionary *param = @{
        @"data":friendInfoDict,
    };
    PUSH_EVENT(param)
}


// MARK: - Open_im_sdk_callbackOnGroupListener

- (void)onGroupApplicationAccepted:(NSString* _Nullable)groupApplication{
    NSDictionary *groupApplicationDict = [self parseJsonStr2Dict:groupApplication];
    NSDictionary *param = @{
        @"data":groupApplicationDict,
    };
    PUSH_EVENT(param)
}

- (void)onGroupApplicationAdded:(NSString* _Nullable)groupApplication{
    NSDictionary *groupApplicationDict = [self parseJsonStr2Dict:groupApplication];
    NSDictionary *param = @{
        @"data":groupApplicationDict,
    };
    PUSH_EVENT(param)
}

- (void)onGroupApplicationDeleted:(NSString* _Nullable)groupApplication{
    NSDictionary *groupApplicationDict = [self parseJsonStr2Dict:groupApplication];
    NSDictionary *param = @{
        @"data":groupApplicationDict,
    };
    PUSH_EVENT(param)
}

- (void)onGroupApplicationRejected:(NSString* _Nullable)groupApplication{
    NSDictionary *groupApplicationDict = [self parseJsonStr2Dict:groupApplication];
    NSDictionary *param = @{
        @"data":groupApplicationDict,
    };
    PUSH_EVENT(param)
}

- (void)onGroupInfoChanged:(NSString* _Nullable)groupInfo{
    NSDictionary *groupInfoDict = [self parseJsonStr2Dict:groupInfo];
    NSDictionary *param = @{
        @"data":groupInfoDict,
    };
    PUSH_EVENT(param)
}

- (void)onGroupMemberAdded:(NSString* _Nullable)groupMemberInfo{
    NSDictionary *groupMemberInfoDict = [self parseJsonStr2Dict:groupMemberInfo];
    NSDictionary *param = @{
        @"data":groupMemberInfoDict,
    };
    PUSH_EVENT(param)
}

- (void)onGroupMemberDeleted:(NSString* _Nullable)groupMemberInfo{
    NSDictionary *groupMemberInfoDict = [self parseJsonStr2Dict:groupMemberInfo];
    NSDictionary *param = @{
        @"data":groupMemberInfoDict,
    };
    PUSH_EVENT(param)
}

- (void)onGroupMemberInfoChanged:(NSString* _Nullable)groupMemberInfo{
    NSDictionary *groupMemberInfoDict = [self parseJsonStr2Dict:groupMemberInfo];
    NSDictionary *param = @{
        @"data":groupMemberInfoDict,
    };
    PUSH_EVENT(param)
}

- (void)onJoinedGroupAdded:(NSString* _Nullable)groupInfo{
    NSDictionary *groupInfoDict = [self parseJsonStr2Dict:groupInfo];
    NSDictionary *param = @{
        @"data":groupInfoDict,
    };
    PUSH_EVENT(param)
}

- (void)onJoinedGroupDeleted:(NSString* _Nullable)groupInfo{
    NSDictionary *groupInfoDict = [self parseJsonStr2Dict:groupInfo];
    NSDictionary *param = @{
        @"data":groupInfoDict,
    };
    PUSH_EVENT(param)
}

- (void)onGroupDismissed:(NSString* _Nullable)groupInfo{
    NSDictionary *groupInfoDict = [self parseJsonStr2Dict:groupInfo];
    NSDictionary *param = @{
        @"data":groupInfoDict,
    };
    PUSH_EVENT(param)
}

// MARK: Open_im_sdk_callbackOnCustomBusinessListener

- (void)onRecvCustomBusinessMessage:(NSString* _Nullable)businessMessage{
    NSDictionary *businessMessageDict = [self parseJsonStr2Dict:businessMessage];
    NSDictionary *param = @{
        @"data":businessMessageDict,
    };
    PUSH_EVENT(param)
}

@end


