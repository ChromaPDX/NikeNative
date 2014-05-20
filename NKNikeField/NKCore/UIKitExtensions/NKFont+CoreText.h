//
//  UIFont+UIFont_CoreText.h
//  NKNikeField
//
//  Created by Leif Shackelford on 4/30/14.
//  Copyright (c) 2014 Chroma Developer. All rights reserved.
//

#import "NKpch.h"
#import <CoreText/CoreText.h>

@interface NKFont (CoreTextExtensions)

- (CTFontRef)createCTFont;

+ (CTFontRef)bundledFontNamed:(NSString *)name size:(CGFloat)size;

@end