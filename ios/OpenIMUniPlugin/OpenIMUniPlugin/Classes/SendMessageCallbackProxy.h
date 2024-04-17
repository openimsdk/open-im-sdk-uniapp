#import <Foundation/Foundation.h>
#import "DCUniModule.h"
#import "OpenIMModule.h"
@import OpenIMCore;

NS_ASSUME_NONNULL_BEGIN

@interface SendMessageCallbackProxy : NSObject <Open_im_sdk_callbackSendMsgCallBack,Open_im_sdk_callbackBase>

- (id)initWithMessage:(NSDictionary *)message module:(OpenIMModule *)module callback:(UniModuleKeepAliveCallback)callback;

@end

NS_ASSUME_NONNULL_END
