//
//  Trifles.h
//  Runner
//
//  Created by Albus on 2/27/21.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>

NS_ASSUME_NONNULL_BEGIN

@interface Trifles : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, strong) FlutterMethodChannel *channel;


- (void)setupChannelHandler;

- (void)setupVideoSDK;

@end

NS_ASSUME_NONNULL_END
