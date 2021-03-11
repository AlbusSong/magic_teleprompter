//
//  Trifles.m
//  Runner
//
//  Created by Albus on 2/27/21.
//

#import "Trifles.h"
#import "AboutVideoSDK.h"

#define WS(weakSelf)      __weak __typeof(&*self)    weakSelf  = self;

static Trifles *instance = nil;

@interface Trifles ()

@property (nonatomic) BOOL isVideoSDKSetup;

@end

@implementation Trifles

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil) {
            instance = [[self alloc] init];
        }
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)setupChannelHandler {
//    WS(weakSelf)
    
    NSLog(@"setupChannelHandler111");
    [self.channel setMethodCallHandler:^(FlutterMethodCall *call, FlutterResult result) {
        NSLog(@"setMethodCallHandler: %@, %@", call.method, call.arguments);
        if ([call.method isEqual:@"setupVideoSDK"]) {
            result(@"sdk setup now");
//            [weakSelf setupVideoSDK];
        }
    }];
}

- (void)setupVideoSDK {
    if (self.isVideoSDKSetup == YES) {
        NSLog(@"已经初始化过了");
        return;
    }
    
    self.isVideoSDKSetup = YES;
    
    [AboutVideoSDK setupVideoSDK];
}

@end
