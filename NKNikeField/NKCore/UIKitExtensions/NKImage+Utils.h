//
//  UIImage+GLBuffer.h
//  NKNikeField
//
//  Created by Leif Shackelford on 5/7/14.
//  Copyright (c) 2014 Chroma Developer. All rights reserved.
//

#import "NKpch.h"


#if TARGET_OS_PHONE
    #define NKImageOrientation UIImageOrientation
#else
typedef NS_ENUM(NSInteger, NKImageOrientation) {
    NKImageOrientationUp,            // default orientation
    NKImageOrientationDown,          // 180 deg rotation
    NKImageOrientationLeft,          // 90 deg CCW
    NKImageOrientationRight,         // 90 deg CW
    NKImageOrientationUpMirrored,    // as above but image mirrored along other axis. horizontal flip
    NKImageOrientationDownMirrored,  // horizontal flip
    NKImageOrientationLeftMirrored,  // vertical flip
    NKImageOrientationRightMirrored, // vertical flip
};
#endif

@interface NKImage (GLBuffer)

+ (NKImage *)perlinMapOfSize:(CGSize)imgSize
                       alpha:(double)a
                        beta:(double)b
                     octaves:(int)octs
                      minVal:(int)minBrightness
                      maxVal:(int)maxBrightness;

+ (NKImage *)imageWithBuffer:(GLubyte *)buffer
                      ofSize:(CGSize)size;

// CROSS-PLATFORM FIXES
+(NKImage *)nkImageWithCGImage:(CGImageRef)ref;
-(CGImageRef)getCGImage;
-(NKImageOrientation)nkImageOrientation;

// ALPHA UTILS

- (BOOL)hasAlpha;
- (NKImage *)imageWithAlpha;
- (NKImage *)transparentBorderImage:(NSUInteger)borderSize;

@end

@interface NKImage (CGContext)

+(CGContextRef)newRGBAContext:(S2t)size;
+(CGContextRef)newBitmapRGBA8ContextFromImage:(NKImage*) image;

+ (NKImage *) imageWithBitmapRGBA8:(unsigned char *) buffer
                         withWidth:(int) width
                        withHeight:(int) height;

- (unsigned char *) getBitmapRGBA8;

@end

typedef NS_ENUM(U1t, NKViewContentMode) {
    NKViewContentModeScaleAspectNull,
    NKViewContentModeScaleAspectFill,
    NKViewContentModeScaleAspectFit
} NS_ENUM_AVAILABLE(10_9, 7_0);

@interface NKImage (Resize)
- (NKImage *)croppedImage:(CGRect)bounds;
- (NKImage *)thumbnailImage:(NSInteger)thumbnailSize
          transparentBorder:(NSUInteger)borderSize
               cornerRadius:(NSUInteger)cornerRadius
       interpolationQuality:(CGInterpolationQuality)quality;
- (NKImage *)resizedImage:(CGSize)newSize
     interpolationQuality:(CGInterpolationQuality)quality;
- (NKImage *)resizedImageWithContentMode:(NKViewContentMode)contentMode
                                  bounds:(CGSize)bounds
                    interpolationQuality:(CGInterpolationQuality)quality;
@end

@interface NKImage (RoundedCorner)
- (NKImage *)roundedCornerImage:(NSInteger)cornerSize borderSize:(NSInteger)borderSize;
@end