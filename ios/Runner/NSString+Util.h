//
//  NSString+Util.h
//  Nianyu
//
//  Created by Albus on 11/20/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Util)

- (instancetype)trim;
//emoji去除
+ (NSString *)disable_emoji:(NSString *)text;

- (BOOL)isValidEmail;

- (NSString *)nonnullValue;

+ (NSString *)avoidNull:(NSString *)string;

- (NSString *)avoidNull;

+ (BOOL)isAvailableString:(NSString *)string;






/**
 未知类型（仅限字典/数组/字符串）
 
 @param object 字典/数组/字符串
 @return 字符串
 */
+ (NSString *)jsonStringWithObject:(id) object;

/**
 字典类型转JSON

 @param dictionary 字典数据
 @return 返回字符串
 */
+ (NSString *)jsonStringWithDictionary:(NSDictionary *)dictionary;


/**
 数组类型转JSON

 @param array 数组类型
 @return 返回字符串
 */
+ (NSString *)jsonStringWithArray:(NSArray *)array;


/**
 字符串类型转JSON

 @param string 字符串类型
 @return 返回字符串
 */
+ (NSString *)jsonStringWithString:(NSString *) string;


@end

NS_ASSUME_NONNULL_END
