//
//  AboutVideoSDK.m
//  Runner
//
//  Created by Albus on 2/27/21.
//

#import "AboutVideoSDK.h"
#import "NSBundle+Build.h"
#import <TuSDK/TuSDK.h>

@implementation AboutVideoSDK

+ (void)setupVideoSDK {
    NSString *b = [[NSBundle mainBundle] bundleIdentifier];
    NSLog(@"bundleIdentifier1: %@", b);
    [TuSDK setLogLevel:lsqLogLevelDEBUG];
    [TuSDK initSdkWithAppKey:@"5e6f5605b2a6dcc9-03-dmlup1"];
}

@end
