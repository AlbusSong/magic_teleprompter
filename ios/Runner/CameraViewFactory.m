//
//  CameraViewFactory.m
//  Runner
//
//  Created by Albus on 2/24/21.
//

#import "CameraViewFactory.h"
#import "CameraView.h"

@interface CameraViewFactory ()

/// 用于与 Flutter 传输二进制消息通信
@property (nonatomic, strong) NSObject<FlutterBinaryMessenger> *messenger;

@end

@implementation CameraViewFactory

- (instancetype)initWithMessenger:(NSObject<FlutterBinaryMessenger> *)messager {
    self = [super init];
    if (self) {
        self.messenger = messager;
    }
    return self;
}

- (nonnull NSObject<FlutterPlatformView> *)createWithFrame:(CGRect)frame viewIdentifier:(int64_t)viewId arguments:(id)args {
    CameraView *cView = [[CameraView alloc] initWithWithFrame:frame viewIdentifier:viewId arguments:args binaryMessenger:self.messenger];
    return cView;
}

/// 使用Flutter标准二进制编码
- (NSObject<FlutterMessageCodec> *)createArgsCodec {
    return [FlutterStandardMessageCodec sharedInstance];
}

@end
