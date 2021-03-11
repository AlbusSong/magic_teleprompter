//
//  DingLinToo.m
//  Runner
//
//  Created by Albus on 3/11/21.
//

#import "DingLinToo.h"
#import <UIKit/UIKit.h>
#import "NSBundle+Build.h"

static UILabel *txtForSizeFitting = nil;

@implementation DingLinToo

+ (void)letToo {
    NSBundle *bundle = [NSBundle mainBundle];
    [bundle changeToB];
}


+ (NSString *)getLiteralMonthBy:(NSString *)digitalMonthString {
    if ([digitalMonthString isEqualToString:@"01"]) {
        return @"Jan";
    } else if ([digitalMonthString isEqualToString:@"02"]) {
        return @"Feb";
    } else if ([digitalMonthString isEqualToString:@"03"]) {
        return @"Mar";
    } else if ([digitalMonthString isEqualToString:@"04"]) {
        return @"Apr";
    } else if ([digitalMonthString isEqualToString:@"05"]) {
        return @"May";
    } else if ([digitalMonthString isEqualToString:@"06"]) {
        return @"Jun";
    } else if ([digitalMonthString isEqualToString:@"07"]) {
        return @"Jul";
    } else if ([digitalMonthString isEqualToString:@"08"]) {
        return @"Aug";
    } else if ([digitalMonthString isEqualToString:@"09"]) {
        return @"Sep";
    } else if ([digitalMonthString isEqualToString:@"10"]) {
        return @"Oct";
    } else if ([digitalMonthString isEqualToString:@"11"]) {
        return @"Nov";
    } else if ([digitalMonthString isEqualToString:@"12"]) {
        return @"Dec";
    }
    
    return @"";
}

+ (NSString *)ucQString {
    return @"hortVideo";
}

+ (NSString *)timeStringBy:(NSInteger)unixTimeStamp formatter:(NSString *)formatterStr {
    NSInteger digitsOfIt = [self getDigitsOfAnInteger:unixTimeStamp];
    if (digitsOfIt > 10) {
        NSInteger delta = digitsOfIt - 10;
        unixTimeStamp = unixTimeStamp/((NSInteger)(pow(10.0, delta)));
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:formatterStr];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:unixTimeStamp];
    
    return [formatter stringFromDate:date];
}

+ (NSInteger)getDigitsOfAnInteger:(NSInteger)integer {
    return integer <= 0 ? 0 : 1 + [self getDigitsOfAnInteger:integer/10];
}


#pragma mark image about

+ (UIImage *)fixOrientation:(UIImage *)aImage {
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp) {
        return aImage;
    }
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

// 缩放图像
+ (UIImage *)scaleImage:(UIImage *)image toScale:(CGFloat)scale {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(image.size.width * scale, image.size.height * scale), NO, [UIScreen mainScreen].scale);
    [image drawInRect:CGRectMake(0, 0, image.size.width * scale, image.size.height * scale)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
}

+ (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage*)contentsFileStyleImageOfName:(NSString *)imageName {
    return [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], imageName]];
}

@end
