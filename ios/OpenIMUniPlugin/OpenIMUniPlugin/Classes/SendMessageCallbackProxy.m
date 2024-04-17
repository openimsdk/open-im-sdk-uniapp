#import "SendMessageCallbackProxy.h"

@interface SendMessageCallbackProxy()

@property (nonatomic, copy) NSDictionary *message;
@property (nonatomic, weak) OpenIMModule* module;
@property (nonatomic, copy) UniModuleKeepAliveCallback callback;

@end

@implementation SendMessageCallbackProxy

- (id)initWithMessage:(NSDictionary *)message module:(OpenIMModule *)module callback:(UniModuleKeepAliveCallback)callback {
    if (self = [super init]) {
        self.message = message;
        self.module = module;
        self.callback = callback;
    }
    return self;
}

- (void)onError:(int32_t)errCode errMsg:(NSString* _Nullable)errMsg {
    if (!self.module) {
        return;
    }
    [self doCallback:@{@"errMsg": errMsg, @"errCode": @(errCode),@"data":self.message}];
}

- (void)onSuccess:(NSString * _Nullable)data {
    if (!self.module) {
        return;
    }
    NSData *jsonData = [data dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    NSDictionary *message = (NSDictionary *)jsonObject;
    [self doCallback:@{@"errMsg": @"", @"errCode": @(0),@"data":message}];
}

- (void)onProgress:(long)progress {
    if (!self.module) {
        return;
    }
    [self.module pushEvent:@"sendMessageProgress"
                       msg:@{
                           @"data": @{@"message":self.message,@"progress":@(progress)}
                       }];
}

- (void)doCallback:(NSDictionary *)param {
    if (self.callback) {
        self.callback(param, false);
        self.callback = nil;
    }
}

@end
