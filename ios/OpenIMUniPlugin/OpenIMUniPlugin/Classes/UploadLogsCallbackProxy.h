#import <Foundation/Foundation.h>
#import "DCUniModule.h"
#import "OpenIMModule.h"
@import OpenIMCore;

NS_ASSUME_NONNULL_BEGIN

@interface UploadLogsCallbackProxy : NSObject <Open_im_sdk_callbackUploadLogProgress>

- (id)initWithOpid:(NSString *)opid module:(OpenIMModule *)module;

@end

NS_ASSUME_NONNULL_END
