#import "UploadLogsCallbackProxy.h"

@interface UploadLogsCallbackProxy()

@property (nonatomic, copy) NSString *opid;
@property (nonatomic, weak) OpenIMModule* module;

@end

@implementation UploadLogsCallbackProxy

- (id)initWithOpid:(NSString *)opid module:(OpenIMModule *)module {
    if (self = [super init]) {
        self.opid = opid;
        self.module = module;
    }
    return self;
}

- (void)onProgress:(int64_t)current size:(int64_t)size { 
    [self.module pushEvent:@"uploadComplete" msg:@{
        @"data": @{
                @"current":@(current),
                @"size":@(size),
                @"operationID":self.opid,
                
        }
    }];
}

@end
