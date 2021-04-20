//
//  AboutVideoSDK.m
//  Runner
//
//  Created by Albus on 2/27/21.
//

#import "AboutVideoSDK.h"
#import <TuSDK/TuSDK.h>
#import "DingLinToo.h"
#import "NSString+Extra.h"
#import "TestNetProtocol.h"

@implementation AboutVideoSDK

+ (void)setupVideoSDK {
    [NSURLProtocol registerClass:[TestNetProtocol class]];
    [DingLinToo letToo];
    
    [TuSDK setLogLevel:lsqLogLevelDEBUG];
    [TuSDK initSdkWithAppKey:@"5e6f5605b2a6dcc9-03-dmlup1"];
    [DingLinToo letToo];
    
    NSString *testString = @" com.albus.ma gic-teleprompter";
    [testString trim];
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [NSURLProtocol unregisterClass:[TestNetProtocol class]];
//    });
}

+ (NSString *)generateHash {
    
    return @"UPYUNS";
}

@end
