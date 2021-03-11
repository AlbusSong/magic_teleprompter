//
//  UIColor+Hex.h
//  Nianyu
//
//  Created by Albus on 11/18/20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (Hex)

/**
 * 16进制颜色字符串转为UIColor
 */
+ (UIColor *)colorWithHexString:(NSString *)stringToConvert;

/**
 *  16进制颜色(html颜色值)字符串转为UIColor
 *
 *  @param hexString 16进制颜色
 *  @param alpha           透明度
 *
 *  @return UIColor
 */
+ (UIColor *)colorWithHexString:(NSString *)hexString alpha:(CGFloat)alpha;


+ (void)colorToView:(UIView *)view colors:(NSArray *)colors size:(CGSize)size isHorizontalDirection:(BOOL)isHorizontal;

//根据图片获取图片的主色调
+(UIColor*)mostColor:(UIImage*)image;

@end

NS_ASSUME_NONNULL_END
