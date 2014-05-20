//
//  UIImage+GLBuffer.h
//  NKNikeField
//
//  Created by Leif Shackelford on 5/7/14.
//  Copyright (c) 2014 Chroma Developer. All rights reserved.
//

#import "NKpch.h"

@interface NKImage (GLBuffer)

+ (NKImage *)perlinMapOfSize:(CGSize)imgSize
                       alpha:(double)a
                        beta:(double)b
                     octaves:(int)octs
                      minVal:(int)minBrightness
                      maxVal:(int)maxBrightness;

+ (NKImage *)imageWithBuffer:(GLubyte *)buffer
                      ofSize:(CGSize)size;

-(CGImageRef)getCGImage;

@end
