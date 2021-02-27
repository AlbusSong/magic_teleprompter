//
//  CameraView.m
//  Runner
//
//  Created by Albus on 2/24/21.
//

#import "CameraView.h"
#import <TuSDK/TuSDK.h>
#import <TuSDKVideo/TuSDKVideo.h>

#define WS(weakSelf)      __weak __typeof(&*self)    weakSelf  = self;

@interface CameraView () <TuSDKRecordVideoCameraDelegate, TuSDKVideoCameraEffectDelegate>

@property (nonatomic, strong) TuSDKRecordVideoCamera  *camera;

@property (nonatomic, strong) UIView *preView;

// 平台通道
@property (nonatomic, strong) FlutterMethodChannel *channel;


@property (nonatomic) TuSkinFaceType skinFaceType;

@end

@implementation CameraView

- (instancetype)initWithWithFrame:(CGRect)frame
                   viewIdentifier:(int64_t)viewId
                        arguments:(id _Nullable)args
                  binaryMessenger:(NSObject<FlutterBinaryMessenger>*)messenger {
    self = [super init];
    if (self) {
        self.preView = [[UIView alloc] init];
        self.preView.backgroundColor = [UIColor blackColor];
        
        WS(weakSelf)
        
        [self tryToSetupCamera];
        
        NSLog(@"argsargsargsargsargsargs: %@, %@, %@", args, [NSThread currentThread], NSStringFromCGRect(frame));
        
        /// 这里的channelName是和Flutter 创建MethodChannel时的名字保持一致的，保证一个原生视图有一个平台通道传递消息
        NSString *channelName = [NSString stringWithFormat:@"camera_view_%lld", viewId];
        self.channel = [FlutterMethodChannel methodChannelWithName:channelName binaryMessenger:messenger];
        // 处理 Flutter 发送的消息事件
        [self.channel setMethodCallHandler:^(FlutterMethodCall *call, FlutterResult result) {
            NSLog(@"setMethodCallHandler: %@, %@", call.method, call.arguments);
            NSDictionary *params = (NSDictionary *)call.arguments;
            if ([call.method isEqualToString:@"changeSkinEffect"]) {
                [weakSelf changeSkinEffect:params[@"paramName"] argPercent:[params[@"argPercent"] floatValue]];
            } else if ([call.method isEqualToString:@"changePlasticEffect"]) {
                [weakSelf changePlasticEffect:params[@"paramName"] argPercent:[params[@"argPercent"] floatValue]];
            }
        }];
    }
    return self;
}

- (UIView *)view {
    return self.preView;
}

#pragma mark actions

- (void)changeSkinEffect:(NSString *)paramName argPercent:(CGFloat)argPercent {
    NSLog(@"thhedd: %@", paramName);
    TuSDKMediaSkinFaceEffect *effect = [self.camera mediaEffectsWithType:TuSDKMediaEffectDataTypeSkinFace].firstObject;
    [effect submitParameterWithKey:paramName argPrecent:argPercent];
}

- (void)changePlasticEffect:(NSString *)paramName argPercent:(CGFloat)argPercent {
    TuSDKMediaPlasticFaceEffect *effect = [self.camera mediaEffectsWithType:TuSDKMediaEffectDataTypePlasticFace].firstObject;
    [effect submitParameterWithKey:paramName argPrecent:argPercent];
}

- (void)tryToSetupCamera {
    WS(weakSelf)
    [TuSDKTSDeviceSettings checkAllowWithController:[UIApplication sharedApplication].delegate.window.rootViewController type:lsqDeviceSettingsCamera completed:^(lsqDeviceSettingsType type, BOOL openSetting) {
        NSLog(@"currentThread: %@", [NSThread currentThread]);
        [weakSelf setupCamera];
        // 启动相机
        [weakSelf.camera tryStartCameraCapture];
    }];
    
//    NSString *b = [[NSBundle mainBundle] bundleIdentifier];
//    NSLog(@"bundleIdentifier2: %@", b);
//
//    [self setupCamera];
//    // 启动相机
//    [self.camera tryStartCameraCapture];
}

- (void)addDefaultEffect {
    WS(weakSelf)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        /** 初始化微整形特效 */
        TuSDKMediaPlasticFaceEffect *plasticFaceEffect = [[TuSDKMediaPlasticFaceEffect alloc] init];
        [weakSelf.camera addMediaEffect:plasticFaceEffect];
        
        /** 初始化美肤特效 默认 极致美颜 */
        weakSelf.skinFaceType = TuSkinFaceTypeNatural;
        TuSDKMediaSkinFaceEffect *skinFaceEffect = [[TuSDKMediaSkinFaceEffect alloc] initUseSkinFaceType:weakSelf.skinFaceType];
        [weakSelf.camera addMediaEffect:skinFaceEffect];
    });
}

- (void)setupCamera {
    _camera = [TuSDKRecordVideoCamera initWithSessionPreset:AVCaptureSessionPresetMedium
         cameraPosition:[AVCaptureDevice lsqFirstFrontCameraPosition]
             cameraView:self.preView];
    _camera.fileType = lsqFileTypeMPEG4;
    _camera.videoQuality = [TuSDKVideoQuality makeQualityWith:TuSDKRecordVideoQuality_High2];
    _camera.videoDelegate = self;
    _camera.effectDelegate = self;
//    _camera.delegate = self;
//    _camera.regionHandler = [[CustomTuSDKCPRegionDefaultHandler alloc] init];
    _camera.disableContinueFoucs = NO;
    _camera.regionViewColor = [UIColor blackColor];
    [_camera flashWithMode:AVCaptureFlashModeOff];
    _camera.frameRate = 30;
    _camera.saveToAlbum = NO;
    _camera.enableFaceDetection = YES;
    _camera.maxRecordingTime = 60 * 15;
    _camera.minRecordingTime = 10;
//    [_camera switchFilterWithCode:_videoFilters[1]];
    _camera.minAvailableSpaceBytes  = 1024.f*1024.f*50.f;
}

#pragma mark TuSDKVideoCameraDelegate

- (void)onVideoCamera:(id<TuSDKVideoCameraInterface>)camera stateChanged:(lsqCameraState)state {
    switch (state)
    {
        case lsqCameraStateStarting:
            // 相机正在启动
            NSLog(@"TuSDKRecordVideoCamera state: 相机正在启动");
            break;
        case lsqCameraStatePaused:
            // 相机录制暂停
            NSLog(@"TuSDKRecordVideoCamera state: 相机录制暂停");
            break;
        case lsqCameraStateStarted:
            // 相机启动完成
            NSLog(@"TuSDKRecordVideoCamera state: 相机启动完成");
            [self addDefaultEffect];
            break;
        case lsqCameraStateCapturing:
            // 相机正在拍摄
            NSLog(@"TuSDKRecordVideoCamera state: 相机正在拍摄");
            break;
        case lsqCameraStateUnknow:
            // 相机状态未知
            NSLog(@"TuSDKRecordVideoCamera state: 相机状态未知");
            break;
        case lsqCameraStateCaptured:
            // 相机拍摄完成
            NSLog(@"TuSDKRecordVideoCamera state: 相机拍摄完成");
            break;
        default:
            break;
    }
}

@end
