//
//  UIFont+CIPadAdditions.m
//  CIPad
//
//

#import "UIFont+CIPadAdditions.h"

@implementation UIFont (CIPadAdditions)
+ (UIFont *)CIPadFontOfSize:(CGFloat)fontSize {
	return [self fontWithName:kCIRegularFontName size:fontSize];
}


+ (UIFont *)boldCIPadFontOfSize:(CGFloat)fontSize {
	return [self fontWithName:kCIBoldFontName size:fontSize];
}


+ (UIFont *)boldItalicCIPadFontOfSize:(CGFloat)fontSize {
	return [self fontWithName:kCIBoldItalicFontName size:fontSize];
}


+ (UIFont *)italicCIPadFontOfSize:(CGFloat)fontSize {
	return [self fontWithName:kCIItalicFontName size:fontSize];
}

@end
