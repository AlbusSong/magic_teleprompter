//
//  CameraView.m
//  Runner
//
//  Created by Albus on 2/24/21.
//

#import "CameraView.h"

@interface CameraView ()

@property (nonatomic, strong) UIView *preView;

// 平台通道
@property (nonatomic, strong) FlutterMethodChannel *channel;

@end

@implementation CameraView

- (instancetype)initWithWithFrame:(CGRect)frame
                   viewIdentifier:(int64_t)viewId
                        arguments:(id _Nullable)args
                  binaryMessenger:(NSObject<FlutterBinaryMessenger>*)messenger {
    self = [super init];
    if (self) {
        self.preView = [[UIView alloc] init];
        self.preView.backgroundColor = [UIColor blueColor];
        
        NSLog(@"argsargsargsargsargsargs: %@", args);
        
        /// 这里的channelName是和Flutter 创建MethodChannel时的名字保持一致的，保证一个原生视图有一个平台通道传递消息
        NSString *channelName = [NSString stringWithFormat:@"camera_view_%lld", viewId];
        self.channel = [FlutterMethodChannel methodChannelWithName:channelName binaryMessenger:messenger];
        // 处理 Flutter 发送的消息事件
        [self.channel setMethodCallHandler:^(FlutterMethodCall *call, FlutterResult result) {
            NSLog(@"setMethodCallHandler: %@, %@", call.method, call.arguments);
            if ([call.method isEqualToString:@""]) {
                
            }
        }];
    }
    return self;
}

- (UIView *)view {
    return self.preView;
}

@end
