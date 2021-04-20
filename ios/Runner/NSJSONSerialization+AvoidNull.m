//
//  NSJSONSerialization+AvoidNull.m
//  Runner
//
//  Created by Albus on 4/6/21.
//

#import "NSJSONSerialization+AvoidNull.h"
#import <objc/runtime.h>

@implementation NSJSONSerialization (AvoidNull)

+ (nullable NSData *)safeDataWithJSONObject:(id)obj options:(NSJSONWritingOptions)opt error:(NSError **)error {
    if (obj == nil) {
        return nil;
    }

    return [self safeDataWithJSONObject:obj options:opt error:error];
}

+ (void)load {
    [self methodSwizzlingWithOriginalSelector:@selector(dataWithJSONObject:options:error:) bySwizzledSelector:@selector(safeDataWithJSONObject:options:error:)];
}

+ (void)methodSwizzlingWithOriginalSelector:(SEL)originalSelector bySwizzledSelector:(SEL)swizzledSelector {
    Class class = [self class];
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    BOOL didAddMethod = class_addMethod(class,originalSelector,
                                        method_getImplementation(swizzledMethod),
                                        method_getTypeEncoding(swizzledMethod));
    if (didAddMethod) {
        class_replaceMethod(class,swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

@end
