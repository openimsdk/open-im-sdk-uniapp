#import "CallbackProxy.h"
@import OpenIMCore;

@interface CallbackProxy()

@property (nonatomic, copy) UniModuleKeepAliveCallback callback;

@end

@implementation CallbackProxy

- (id)initWithCallback:(UniModuleKeepAliveCallback)callback {
    if (self = [super init]) {
        self.callback = callback;
    }
    return self;
}

- (void)onError:(int32_t)errCode errMsg:(NSString* _Nullable)errMsg {
    if (errMsg == nil) {
        errMsg = @"";
    }
    [self doCallback:@{@"errMsg": errMsg, @"errCode": @(errCode),@"data":@""}];
}

- (void)onSuccess:(NSString * _Nullable)data {
    if (data == nil) {
        data = @"";
    }
    [self doCallback:@{@"errMsg": @"", @"errCode": @(0),@"data":data}];
}

- (void)doCallback:(NSDictionary *)param {
    if (self.callback) {
        self.callback(param, false);
        self.callback = nil;
    }
}

@end
