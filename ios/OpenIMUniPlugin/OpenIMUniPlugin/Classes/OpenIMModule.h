#import <Foundation/Foundation.h>
#import "DCUniModule.h"
#import "CallbackProxy.h"
@import OpenIMCore;

NS_ASSUME_NONNULL_BEGIN

@interface OpenIMModule : DCUniModule <Open_im_sdk_callbackOnConnListener,Open_im_sdk_callbackOnUserListener, Open_im_sdk_callbackOnAdvancedMsgListener, Open_im_sdk_callbackOnFriendshipListener, Open_im_sdk_callbackOnConversationListener, Open_im_sdk_callbackOnGroupListener,Open_im_sdk_callbackOnBatchMsgListener,Open_im_sdk_callbackOnCustomBusinessListener>

@property (nonatomic, readwrite) BOOL initFlag;

- (void)pushEvent:(NSString *) eventName msg:(nullable id) msg;

@end

NS_ASSUME_NONNULL_END
