//
//  UIFont+CIPadAdditions.h
//  CIPad
//
//

#import <UIKit/UIKit.h>

@interface UIFont (CIPadAdditions)

+ (UIFont *)CIPadFontOfSize:(CGFloat)fontSize;
+ (UIFont *)boldCIPadFontOfSize:(CGFloat)fontSize;
+ (UIFont *)boldItalicCIPadFontOfSize:(CGFloat)fontSize;
+ (UIFont *)italicCIPadFontOfSize:(CGFloat)fontSize;

@end
