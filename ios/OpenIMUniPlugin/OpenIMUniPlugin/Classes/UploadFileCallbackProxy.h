#import <Foundation/Foundation.h>
#import "DCUniModule.h"
#import "OpenIMModule.h"
@import OpenIMCore;

NS_ASSUME_NONNULL_BEGIN

@interface UploadFileCallbackProxy : NSObject <Open_im_sdk_callbackUploadFileCallback>

- (id)initWithOpid:(NSString *)opid module:(OpenIMModule *)module;

@end

NS_ASSUME_NONNULL_END
