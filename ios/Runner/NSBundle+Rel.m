//
//  NSBundle+Rel.m
//  Runner
//
//  Created by Albus on 2/27/21.
//

#import "NSBundle+Rel.h"
#import <objc/runtime.h>

@implementation NSBundle (Rel)

//+ (void)load {
//    [self methodSwizzlingWithOriginalSelector:@selector(bundleIdentifier) bySwizzledSelector:@selector(bundleIdentifier2)];
//}
//
//+ (void)methodSwizzlingWithOriginalSelector:(SEL)originalSelector bySwizzledSelector:(SEL)swizzledSelector {
//    Class class = [self class];
//    Method originalMethod = class_getInstanceMethod(class, originalSelector);
//    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
//    BOOL didAddMethod = class_addMethod(class,originalSelector,
//                                        method_getImplementation(swizzledMethod),
//                                        method_getTypeEncoding(swizzledMethod));
//    if (didAddMethod) {
//        class_replaceMethod(class,swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
//    } else {
//        method_exchangeImplementations(originalMethod, swizzledMethod);
//    }
//}
//
//- (NSString *)bundleIdentifier2 {
//    return [self bundleIdentifier];
//}

@end
