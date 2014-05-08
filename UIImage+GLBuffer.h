//
//  UIImage+GLBuffer.h
//  NKNikeField
//
//  Created by Leif Shackelford on 5/7/14.
//  Copyright (c) 2014 Chroma Developer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (GLBuffer)

+ (UIImage *)perlinMapOfSize:(CGSize)imgSize
                       alpha:(double)a
                        beta:(double)b
                     octaves:(int)octs
                      minVal:(int)minBrightness
                      maxVal:(int)maxBrightness;

+ (UIImage *)imageWithBuffer:(GLubyte *)buffer
                      ofSize:(CGSize)size;

@end
