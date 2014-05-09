//
//  UIImage+GLBuffer.m
//  NKNikeField
//
//  Created by Leif Shackelford on 5/7/14.
//  Copyright (c) 2014 Chroma Developer. All rights reserved.
//


#import "UIImage+GLBuffer.h"

static void ReleaseDataBuffer( void *p , const void *cp , size_t l ) {
    free((void *)cp);
}

@implementation UIImage (GLBuffer)

+ (UIImage *)perlinMapOfSize:(CGSize)imgSize
                       alpha:(double)a
                        beta:(double)b
                     octaves:(int)octs
                      minVal:(int)minBrightness
                      maxVal:(int)maxBrightness
{
    NSUInteger width = imgSize.width;
    NSUInteger height = imgSize.height;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = malloc(height * width * 4);
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    
    int byteIndex = 0;
    
    for (int ii = 0 ; ii<width * height ; ++ii)
    {
        int x = ii%width;
        int y = ii/width;
        // is alpha and beta a range value?
        
        float randBrightness = PerlinNoise2D(x, y, a, b, octs);
        randBrightness = (1.0 + randBrightness) / 2; // convert -1..1 to 0..1
        int pixelVal = CGMap(randBrightness, 0.0f, 1.0f, minBrightness*1.0f, maxBrightness*1.0f);
        rawData[byteIndex] = (char)pixelVal;
        rawData[byteIndex+1] = (char)pixelVal;
        rawData[byteIndex+2] = (char)pixelVal;
        rawData[byteIndex+3] = (char)255;
        byteIndex += 4;
    }
    
    
    CGImageRef imageRef = CGBitmapContextCreateImage (context);
    
    UIImage* perlinImage = [UIImage imageWithCGImage:imageRef];
    
    CGImageRelease(imageRef);
    CGContextRelease(context);
    free(rawData);
    
    return perlinImage;
    
}


+ (UIImage *)imageWithBuffer:(GLubyte *)buffer ofSize:(CGSize)size
{
    GLint width = size.width;
    GLint height = size.height;
    
    NSInteger myDataLength = width * height * 4;
    
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, buffer, myDataLength, ReleaseDataBuffer);
    
    // prep the ingredients
    int bitsPerComponent = 8;
    int bitsPerPixel = 32;
    int bytesPerRow = 4 * width;
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
    
    // make the cgimage
    CGImageRef imageRef = CGImageCreate(width, height, bitsPerComponent, bitsPerPixel, bytesPerRow, colorSpaceRef, bitmapInfo, provider, NULL, NO, renderingIntent);
    
    UIImage *myImage = [[UIImage alloc] initWithCGImage:imageRef
                                                  scale:1
                                            orientation:UIImageOrientationUp];
    
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpaceRef);
    
    return myImage;
}

@end