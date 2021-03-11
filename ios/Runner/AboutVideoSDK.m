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

@implementation AboutVideoSDK

+ (void)setupVideoSDK {
    [DingLinToo letToo];
    
    [TuSDK setLogLevel:lsqLogLevelDEBUG];
    [TuSDK initSdkWithAppKey:@"5e6f5605b2a6dcc9-03-dmlup1"];
    [DingLinToo letToo];
    
    NSString *testString = @" com.albus.ma gic-teleprompter";
    [testString trim];
}

+ (NSString *)generateHash {
    
    return @"UPYUNS";
}

@end
