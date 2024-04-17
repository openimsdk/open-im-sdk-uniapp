#import <Foundation/Foundation.h>
#import "DCUniModule.h"
@import OpenIMCore;

NS_ASSUME_NONNULL_BEGIN

@interface CallbackProxy : NSObject <Open_im_sdk_callbackBase>

- (id)initWithCallback:(UniModuleKeepAliveCallback)callback;

@end

NS_ASSUME_NONNULL_END
