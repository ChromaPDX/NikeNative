//
//  UIFont+UIFont_CoreText.h
//  NKNikeField
//
//  Created by Leif Shackelford on 4/30/14.
//  Copyright (c) 2014 Chroma Developer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

@interface UIFont (CoreTextExtensions)

- (CTFontRef)createCTFont;

+ (CTFontRef)bundledFontNamed:(NSString *)name size:(CGFloat)size;

@end