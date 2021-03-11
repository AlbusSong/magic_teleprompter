//
//  NSString+Util.m
//  Nianyu
//
//  Created by Albus on 11/20/20.
//

#import "NSString+Util.h"

@implementation NSString (Util)

- (BOOL)isValidEmail {
    
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:self];
    
}

- (NSString *)nonnullValue {
    if (self.length == 0) {
        return @"";
    }
    
    return self;
}

+ (NSString *)avoidNull:(NSString *)string {
    if (string == nil) {
        return @"";
    }
    
    if (string.length == 0) {
        return @"";
    }
    
    if ([string isEqualToString:@"null"] ||
        [string isEqualToString:@"<null>"] ||
        [string isEqualToString:@"(null)"]) {
        return @"";
    }
    
    return string;
}

- (NSString *)avoidNull {
    if (self.length == 0) {
        return @"";
    }
    
    if ([self isEqualToString:@"null"] ||
        [self isEqualToString:@"<null>"] ||
        [self isEqualToString:@"(null)"]) {
        return @"";
    }
    
    return self;
}

+ (BOOL)isAvailableString:(NSString *)string {
    if ([string isKindOfClass:[NSString class]] == NO) {
        return NO;
    }
    
    if ([string isEqualToString:@""]) {
        return NO;
    }
    
    if ([string isEqualToString:@"null"] ||
        [string isEqualToString:@"<null>"] ||
        [string isEqualToString:@"(null)"]) {
        return NO;
    }
    
    return YES;
}

// 将首尾的空格去掉
- (instancetype)trim {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}
//emoji去除
+ (NSString *)disable_emoji:(NSString *)text {
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[^\\u0020-\\u007E\\u00A0-\\u00BE\\u2E80-\\uA4CF\\uF900-\\uFAFF\\uFE30-\\uFE4F\\uFF00-\\uFFEF\\u0080-\\u009F\\u2000-\\u201f\r\n]" options:NSRegularExpressionCaseInsensitive error:nil];
    NSString *modifiedString = [regex stringByReplacingMatchesInString:text
                                                               options:0
                                                                 range:NSMakeRange(0, [text length])
                                                          withTemplate:@""];
    return modifiedString;
}






/**
 未知类型（仅限字典/数组/字符串）
 
 @param object 字典/数组/字符串
 @return 字符串
 */
+(NSString *)jsonStringWithObject:(id) object{
    NSString *value = nil;
    if (!object) {
        return value;
    }
    if ([object isKindOfClass:[NSString class]]) {
        value = [NSString jsonStringWithString:object];
    }else if([object isKindOfClass:[NSDictionary class]]){
        value = [NSString jsonStringWithDictionary:object];
    }else if([object isKindOfClass:[NSArray class]]){
        value = [NSString jsonStringWithArray:object];
    }
    return value;
}

/**
 字符串类型转JSON
 
 @param string 字符串类型
 @return 返回字符串
 */
+(NSString *)jsonStringWithString:(NSString *) string{
    return [NSString stringWithFormat:@"%@",
            [[string stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"] stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""]
            ];
}

/**
 数组类型转JSON
 
 @param array 数组类型
 @return 返回字符串
 */
+(NSString *)jsonStringWithArray:(NSArray *)array{
    NSMutableString *reString = [NSMutableString string];
    [reString appendString:@"["];
    NSMutableArray *values = [NSMutableArray array];
    for (id valueObj in array) {
        NSString *value = [NSString jsonStringWithObject:valueObj];
        if (value) {
            [values addObject:[NSString stringWithFormat:@"%@",value]];
        }
    }
    [reString appendFormat:@"%@",[values componentsJoinedByString:@","]];
    [reString appendString:@"]"];
    return reString;
}

/**
 字典类型转JSON
 
 @param dictionary 字典数据
 @return 返回字符串
 */
+(NSString *)jsonStringWithDictionary:(NSDictionary *)dictionary{
    NSError *parseError = nil;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:&parseError];
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

@end
