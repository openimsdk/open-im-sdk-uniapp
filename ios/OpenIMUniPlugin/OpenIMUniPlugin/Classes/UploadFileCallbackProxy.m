#import "UploadFileCallbackProxy.h"

@interface UploadFileCallbackProxy()

@property (nonatomic, copy) NSString *opid;
@property (nonatomic, weak) OpenIMModule* module;

@end

@implementation UploadFileCallbackProxy

- (id)initWithOpid:(NSString *)opid module:(OpenIMModule *)module {
    if (self = [super init]) {
        self.opid = opid;
        self.module = module;
    }
    return self;
}


- (void)complete:(int64_t)size url:(NSString * _Nullable)url typ:(long)typ {
    
}

- (void)hashPartComplete:(NSString * _Nullable)partsHash fileHash:(NSString * _Nullable)fileHash {
    
}

- (void)hashPartProgress:(long)index size:(int64_t)size partHash:(NSString * _Nullable)partHash {
    
}

- (void)open:(int64_t)size {
    
}

- (void)partSize:(int64_t)partSize num:(long)num {
    
}

- (void)uploadComplete:(int64_t)fileSize streamSize:(int64_t)streamSize storageSize:(int64_t)storageSize {
    [self.module pushEvent:@"uploadComplete" msg:@{
        @"data": @{
                @"fileSize":@(fileSize),
                @"streamSize":@(streamSize),
                @"storageSize":@(storageSize),
                @"operationID":self.opid,
                
        }
    }];
}

- (void)uploadID:(NSString * _Nullable)uploadID {
    
}

- (void)uploadPartComplete:(long)index partSize:(int64_t)partSize partHash:(NSString * _Nullable)partHash {
    
}

@end

