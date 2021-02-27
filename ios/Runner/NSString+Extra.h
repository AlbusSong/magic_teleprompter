//
//  NSString+Extra.h
//  Runner
//
//  Created by Albus on 2/27/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Extra)

- (instancetype)trim;
//emoji去除
+ (NSString *)disable_emoji:(NSString *)text;

@end

NS_ASSUME_NONNULL_END
