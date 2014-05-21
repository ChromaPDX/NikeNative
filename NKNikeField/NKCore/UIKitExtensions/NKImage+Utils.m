//
//  NKImage+GLBuffer.m
//  NKNikeField
//
//  Created by Leif Shackelford on 5/7/14.
//  Copyright (c) 2014 Chroma Developer. All rights reserved.
//


#import "NKImage+Utils.h"
#import "NKMath.h"

static void ReleaseDataBuffer( void *p , const void *cp , size_t l ) {
    free((void *)cp);
}

@implementation NKImage (GLBuffer)

+ (NKImage *)perlinMapOfSize:(CGSize)imgSize
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
    
    NKImage *perlinImage = [NKImage nkImageWithCGImage:imageRef];
    
    CGImageRelease(imageRef);
    CGContextRelease(context);
    free(rawData);
    
    return perlinImage;
    
}


+ (NKImage *)imageWithBuffer:(GLubyte *)buffer ofSize:(CGSize)size
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
    
    NKImage *myImage = [NKImage nkImageWithCGImage:imageRef];
    
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpaceRef);
    
    return myImage;
}

#pragma mark - Cross Platform Fixes

+(NKImage*)nkImageWithCGImage:(CGImageRef)imageRef {
    
#if NK_USE_GLES
    return [NKImage imageWithCGImage:imageRef];
#else
    unsigned long width = CGImageGetWidth(imageRef);
    unsigned long height = CGImageGetHeight(imageRef);
    return [[NKImage alloc] initWithCGImage:imageRef size:CGSizeMake(width, height)];
#endif
    
}

-(CGImageRef)getCGImage {
#if NK_USE_GLES
    return self.CGImage;
#else
	NSBitmapImageRep *imageClass = [[NSBitmapImageRep alloc] initWithData:[self TIFFRepresentation]];
    return imageClass.CGImage;
#endif
}

-(NKImageOrientation)nkImageOrientation {
#if NK_USE_GLES
    return self.imageOrientation;
#else
    return NKImageOrientationUp;
#endif
}

#pragma MARK - ALPHA

// Returns true if the image has an alpha layer
- (BOOL)hasAlpha {
    CGImageAlphaInfo alpha = CGImageGetAlphaInfo(self.getCGImage);
    return (alpha == kCGImageAlphaFirst ||
            alpha == kCGImageAlphaLast ||
            alpha == kCGImageAlphaPremultipliedFirst ||
            alpha == kCGImageAlphaPremultipliedLast);
}

// Returns a copy of the given image, adding an alpha channel if it doesn't already have one
- (NKImage *)imageWithAlpha {
    if ([self hasAlpha]) {
        return self;
    }
    
    CGImageRef imageRef = self.getCGImage;
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    
    // The bitsPerComponent and bitmapInfo values are hard-coded to prevent an "unsupported parameter combination" error
    CGContextRef offscreenContext = CGBitmapContextCreate(NULL,
                                                          width,
                                                          height,
                                                          8,
                                                          0,
                                                          CGImageGetColorSpace(imageRef),
                                                          kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedFirst);
    
    // Draw the image into the context and retrieve the new image, which will now have an alpha layer
    CGContextDrawImage(offscreenContext, CGRectMake(0, 0, width, height), imageRef);
    CGImageRef imageRefWithAlpha = CGBitmapContextCreateImage(offscreenContext);
    NKImage *imageWithAlpha = [NKImage nkImageWithCGImage:imageRefWithAlpha];
    
    // Clean up
    CGContextRelease(offscreenContext);
    CGImageRelease(imageRefWithAlpha);
    
    return imageWithAlpha;
}



// Returns a copy of the image with a transparent border of the given size added around its edges.
// If the image has no alpha layer, one will be added to it.
- (NKImage *)transparentBorderImage:(NSUInteger)borderSize {
    // If the image does not have an alpha layer, add one
    NKImage *image = [self imageWithAlpha];
    
    CGRect newRect = CGRectMake(0, 0, image.size.width + borderSize * 2, image.size.height + borderSize * 2);
    
    // Build a context that's the same dimensions as the new size
    CGContextRef bitmap = CGBitmapContextCreate(NULL,
                                                newRect.size.width,
                                                newRect.size.height,
                                                CGImageGetBitsPerComponent(self.getCGImage),
                                                0,
                                                CGImageGetColorSpace(self.getCGImage),
                                                CGImageGetBitmapInfo(self.getCGImage));
    
    // Draw the image in the center of the context, leaving a gap around the edges
    CGRect imageLocation = CGRectMake(borderSize, borderSize, image.size.width, image.size.height);
    CGContextDrawImage(bitmap, imageLocation, self.getCGImage);
    CGImageRef borderImageRef = CGBitmapContextCreateImage(bitmap);
    
    // Create a mask to make the border transparent, and combine it with the image
    CGImageRef maskImageRef = [self newBorderMask:borderSize size:newRect.size];
    CGImageRef transparentBorderImageRef = CGImageCreateWithMask(borderImageRef, maskImageRef);
    NKImage *transparentBorderImage = [NKImage nkImageWithCGImage:transparentBorderImageRef];
    
    // Clean up
    CGContextRelease(bitmap);
    CGImageRelease(borderImageRef);
    CGImageRelease(maskImageRef);
    CGImageRelease(transparentBorderImageRef);
    
    return transparentBorderImage;
}

#pragma mark -
#pragma mark Private helper methods

// Creates a mask that makes the outer edges transparent and everything else opaque
// The size must include the entire mask (opaque part + transparent border)
// The caller is responsible for releasing the returned reference by calling CGImageRelease
- (CGImageRef)newBorderMask:(NSUInteger)borderSize size:(CGSize)size {
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    
    // Build a context that's the same dimensions as the new size
    CGContextRef maskContext = CGBitmapContextCreate(NULL,
                                                     size.width,
                                                     size.height,
                                                     8, // 8-bit grayscale
                                                     0,
                                                     colorSpace,
                                                     kCGBitmapByteOrderDefault | kCGImageAlphaNone);
    
    // Start with a mask that's entirely transparent
    CGContextSetFillColorWithColor(maskContext, [NKColor blackColor].CGColor);
    CGContextFillRect(maskContext, CGRectMake(0, 0, size.width, size.height));
    
    // Make the inner part (within the border) opaque
    CGContextSetFillColorWithColor(maskContext, [NKColor whiteColor].CGColor);
    CGContextFillRect(maskContext, CGRectMake(borderSize, borderSize, size.width - borderSize * 2, size.height - borderSize * 2));
    
    // Get an image of the context
    CGImageRef maskImageRef = CGBitmapContextCreateImage(maskContext);
    
    // Clean up
    CGContextRelease(maskContext);
    CGColorSpaceRelease(colorSpace);
    
    return maskImageRef;
}


@end

@implementation NKImage (CGContext)

// THE FOLLOWING FUNCTIONS BELONG TO THE FOLLOWING LICENSE

/*
 * The MIT License
 *
 * Copyright (c) 2011 Paul Solt, PaulSolt@gmail.com
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */
static CGRect clipRectToPath(CGRect rect, CGPathRef path)
{
    size_t width                = floorf(rect.size.width);
    size_t height               = floorf(rect.size.height);
    uint8_t *points             = (unsigned char*)calloc(width * height, sizeof(*points));
    CGContextRef bitmapContext  = CGBitmapContextCreate(points, width, height, sizeof(*points) * 8, width, NULL, kCGImageAlphaOnly);
    BOOL atStart                = NO;
    NSRange range               = NSMakeRange(0, 0);
    NSUInteger x                = 0;
    
    CGContextSetShouldAntialias(bitmapContext, NO);
    CGContextTranslateCTM(bitmapContext, -rect.origin.x, -rect.origin.y);
    CGContextAddPath(bitmapContext, path);
    CGContextFillPath(bitmapContext);
    
    for (; x < width; ++x)
    {
        BOOL isCol = YES;
        for (int i = 0; i < height; ++i)
        {
            if (points[(i * width + x)] < 128)
            {
                isCol = NO;
                break;
            }
        }
        
        if (isCol && !atStart)
        {
            atStart = YES;
            range.location = x;
        }
        else if (!isCol && atStart)
        {
            break;
        }
    }
    
    if (atStart)
        range.length = x - range.location - 1;
    
    CGContextRelease(bitmapContext);
    free(points);
    
    return CGRectMake(rect.origin.x + range.location, rect.origin.y, range.length, rect.size.height);
}


- (unsigned char *) getBitmapRGBA8 {
    
	CGImageRef imageRef = self.getCGImage;
    
	// Create a bitmap context to draw the uiimage into
	CGContextRef context = [NKImage newBitmapRGBA8ContextFromImage:self];
    
	if(!context) {
		return NULL;
	}
    
	size_t width = self.size.width;
	size_t height = self.size.height;
    
	CGRect rect = CGRectMake(0, 0, width, height);
    
	// Draw image into the context to get the raw image data
	CGContextDrawImage(context, rect, imageRef);
    //[image drawInRect:rect];
    
	// Get a pointer to the data
	unsigned char *bitmapData = (unsigned char *)CGBitmapContextGetData(context);
    
	// Copy the data and release the memory (return memory allocated with new)
	size_t bytesPerRow = CGBitmapContextGetBytesPerRow(context);
	size_t bufferLength = bytesPerRow * height;
    
	unsigned char *newBitmap = NULL;
    
	if(bitmapData) {
		newBitmap = (unsigned char *)malloc(sizeof(unsigned char) * bytesPerRow * height);
        
		if(newBitmap) {	// Copy the data
			for(int i = 0; i < bufferLength; ++i) {
				newBitmap[i] = bitmapData[i];
			}
		}
        
		free(bitmapData);
        
	} else {
		NSLog(@"Error getting bitmap pixel data\n");
	}
    
	CGContextRelease(context);
    
	return newBitmap;
}


+ (NKImage *) imageWithBitmapRGBA8:(unsigned char *) buffer
								withWidth:(int) width
							   withHeight:(int) height {
    
    
	size_t bufferLength = width * height * 4;
	CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, buffer, bufferLength, NULL);
	size_t bitsPerComponent = 8;
	size_t bitsPerPixel = 32;
	size_t bytesPerRow = 4 * width;
    
	CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
	if(colorSpaceRef == NULL) {
		NSLog(@"Error allocating color space");
		CGDataProviderRelease(provider);
		return nil;
	}
	CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast;
	CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
    
	CGImageRef iref = CGImageCreate(width,
									height,
									bitsPerComponent,
									bitsPerPixel,
									bytesPerRow,
									colorSpaceRef,
									bitmapInfo,
									provider,	// data provider
									NULL,		// decode
									YES,			// should interpolate
									renderingIntent);
    
	uint32_t* pixels = (uint32_t*)malloc(bufferLength);
    
	if(pixels == NULL) {
		NSLog(@"Error: Memory not allocated for bitmap");
		CGDataProviderRelease(provider);
		CGColorSpaceRelease(colorSpaceRef);
		CGImageRelease(iref);
		return nil;
	}
    
	CGContextRef context = CGBitmapContextCreate(pixels,
												 width,
												 height,
												 bitsPerComponent,
												 bytesPerRow,
												 colorSpaceRef,
                                                 bitmapInfo);
    
	if(context == NULL) {
		NSLog(@"Error context not created");
		free(pixels);
	}
    
	NKImage *image = nil;
	if(context) {
        
		CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, width, height), iref);
        
		CGImageRef imageRef = CGBitmapContextCreateImage(context);
        
		// Support both iPad 3.2 and iPhone 4 Retina displays with the correct scale
#if NK_USE_GLES
		if([NKImage respondsToSelector:@selector(imageWithCGImage:scale:orientation:)]) {
			float scale = [[UIScreen mainScreen] scale];
			image = [NKImage imageWithCGImage:imageRef scale:scale orientation:UIImageOrientationUp];
		} else {
			image = [NKImage imageWithCGImage:imageRef];
		}
#else
        image = [[NKImage alloc]initWithCGImage:imageRef size:CGSizeMake(width, height)];
#endif
        
		CGImageRelease(imageRef);
		CGContextRelease(context);
	}
    
	CGColorSpaceRelease(colorSpaceRef);
	CGImageRelease(iref);
	CGDataProviderRelease(provider);
    
	if(pixels) {
		free(pixels);
	}
	return image;
}


+(CGContextRef)newRGBAContext:(S2t)size {
    
    CGContextRef context = NULL;
	CGColorSpaceRef colorSpace;
	uint32_t *bitmapData;
    
	size_t bitsPerPixel = 32;
	size_t bitsPerComponent = 8;
	size_t bytesPerPixel = bitsPerPixel / bitsPerComponent;
    
	size_t width = size.width;
	size_t height = size.height;
    
	size_t bytesPerRow = width * bytesPerPixel;
	size_t bufferLength = bytesPerRow * height;
    
	colorSpace = CGColorSpaceCreateDeviceRGB();
    
	if(!colorSpace) {
		NSLog(@"Error allocating color space RGB\n");
		return NULL;
	}
    
	// Allocate memory for image data
	bitmapData = (uint32_t *)malloc(bufferLength);
    
	if(!bitmapData) {
		NSLog(@"Error allocating memory for bitmap\n");
		CGColorSpaceRelease(colorSpace);
		return NULL;
	}
    
	//Create bitmap context
    
    context = CGBitmapContextCreate(bitmapData, width, height, 8, 4 * width, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big );
    
	if(!context) {
		free(bitmapData);
		NSLog(@"Bitmap context not created");
	}
    
	CGColorSpaceRelease(colorSpace);
    
	return context;
    
}

+ (CGContextRef) newBitmapRGBA8ContextFromImage:(NKImage*) image {
	CGContextRef context = NULL;
	CGColorSpaceRef colorSpace;
	uint32_t *bitmapData;
    
	size_t bitsPerPixel = 32;
	size_t bitsPerComponent = 8;
	size_t bytesPerPixel = bitsPerPixel / bitsPerComponent;
    
	size_t width = image.size.width;
	size_t height = image.size.height;
    
	size_t bytesPerRow = width * bytesPerPixel;
	size_t bufferLength = bytesPerRow * height;
    
	colorSpace = CGColorSpaceCreateDeviceRGB();
    
	if(!colorSpace) {
		NSLog(@"Error allocating color space RGB\n");
		return NULL;
	}
    
	// Allocate memory for image data
	bitmapData = (uint32_t *)malloc(bufferLength);
    
	if(!bitmapData) {
		NSLog(@"Error allocating memory for bitmap\n");
		CGColorSpaceRelease(colorSpace);
		return NULL;
	}
    
	//Create bitmap context
	context = CGBitmapContextCreate(bitmapData,
									width,
									height,
									bitsPerComponent,
									bytesPerRow,
									colorSpace,
                                    kCGImageAlphaPremultipliedLast);	// RGBA
    
	if(!context) {
		free(bitmapData);
		NSLog(@"Bitmap context not created");
	}
    
	CGColorSpaceRelease(colorSpace);
    
	return context;
}

@end

@implementation NKImage (RoundedCorner)

// Creates a copy of this image with rounded corners
// If borderSize is non-zero, a transparent border of the given size will also be added
// Original author: BjÃ¶rn SÃ¥llarp. Used with permission. See: http://blog.sallarp.com/iphone-uiimage-round-corners/
- (NKImage *)roundedCornerImage:(NSInteger)cornerSize borderSize:(NSInteger)borderSize {
    // If the image does not have an alpha layer, add one
    NKImage *image = [self imageWithAlpha];
    
    // Build a context that's the same dimensions as the new size
    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 image.size.width,
                                                 image.size.height,
                                                 CGImageGetBitsPerComponent(image.getCGImage),
                                                 0,
                                                 CGImageGetColorSpace(image.getCGImage),
                                                 CGImageGetBitmapInfo(image.getCGImage));
    
    // Create a clipping path with rounded corners
    CGContextBeginPath(context);
    [self addRoundedRectToPath:CGRectMake(borderSize, borderSize, image.size.width - borderSize * 2, image.size.height - borderSize * 2)
                       context:context
                     ovalWidth:cornerSize
                    ovalHeight:cornerSize];
    CGContextClosePath(context);
    CGContextClip(context);
    
    // Draw the image to the context; the clipping path will make anything outside the rounded rect transparent
    CGContextDrawImage(context, CGRectMake(0, 0, image.size.width, image.size.height), image.getCGImage);
    
    // Create a CGImage from the context
    CGImageRef clippedImage = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    
    // Create a NKImage from the CGImage
    NKImage *roundedImage = [NKImage nkImageWithCGImage:clippedImage];
    CGImageRelease(clippedImage);
    
    return roundedImage;
}

#pragma mark -
#pragma mark Private helper methods

// Adds a rectangular path to the given context and rounds its corners by the given extents
// Original author: BjÃ¶rn SÃ¥llarp. Used with permission. See: http://blog.sallarp.com/iphone-uiimage-round-corners/
- (void)addRoundedRectToPath:(CGRect)rect context:(CGContextRef)context ovalWidth:(CGFloat)ovalWidth ovalHeight:(CGFloat)ovalHeight {
    if (ovalWidth == 0 || ovalHeight == 0) {
        CGContextAddRect(context, rect);
        return;
    }
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextScaleCTM(context, ovalWidth, ovalHeight);
    CGFloat fw = CGRectGetWidth(rect) / ovalWidth;
    CGFloat fh = CGRectGetHeight(rect) / ovalHeight;
    CGContextMoveToPoint(context, fw, fh/2);
    CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);
    CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1);
    CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1);
    CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1);
    CGContextClosePath(context);
    CGContextRestoreGState(context);
}

@end

@implementation NKImage (Resize)

// Returns a copy of this image that is cropped to the given bounds.
// The bounds will be adjusted using CGRectIntegral.
// This method ignores the image's imageOrientation setting.
- (NKImage *)croppedImage:(CGRect)bounds {
    CGImageRef imageRef = CGImageCreateWithImageInRect([self getCGImage], bounds);
    NKImage *croppedImage = [NKImage nkImageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return croppedImage;
}

// Returns a copy of this image that is squared to the thumbnail size.
// If transparentBorder is non-zero, a transparent border of the given size will be added around the edges of the thumbnail. (Adding a transparent border of at least one pixel in size has the side-effect of antialiasing the edges of the image when rotating it using Core Animation.)
- (NKImage *)thumbnailImage:(NSInteger)thumbnailSize
          transparentBorder:(NSUInteger)borderSize
               cornerRadius:(NSUInteger)cornerRadius
       interpolationQuality:(CGInterpolationQuality)quality {
    NKImage *resizedImage = [self resizedImageWithContentMode:NKViewContentModeScaleAspectFill
                                                       bounds:CGSizeMake(thumbnailSize, thumbnailSize)
                                         interpolationQuality:quality];
    
    // Crop out any part of the image that's larger than the thumbnail size
    // The cropped rect must be centered on the resized image
    // Round the origin points so that the size isn't altered when CGRectIntegral is later invoked
    CGRect cropRect = CGRectMake(round((resizedImage.size.width - thumbnailSize) / 2),
                                 round((resizedImage.size.height - thumbnailSize) / 2),
                                 thumbnailSize,
                                 thumbnailSize);
    NKImage *croppedImage = [resizedImage croppedImage:cropRect];
    
    NKImage *transparentBorderImage = borderSize ? [croppedImage transparentBorderImage:borderSize] : croppedImage;
    
    return [transparentBorderImage roundedCornerImage:cornerRadius borderSize:borderSize];
}

// Returns a rescaled copy of the image, taking into account its orientation
// The image will be scaled disproportionately if necessary to fit the bounds specified by the parameter
- (NKImage *)resizedImage:(CGSize)newSize interpolationQuality:(CGInterpolationQuality)quality {
    BOOL drawTransposed;
    
    switch (self.nkImageOrientation) {
        case NKImageOrientationLeft:
        case NKImageOrientationLeftMirrored:
        case NKImageOrientationRight:
        case NKImageOrientationRightMirrored:
            drawTransposed = YES;
            break;
            
        default:
            drawTransposed = NO;
    }
    
    return [self resizedImage:newSize
                    transform:[self transformForOrientation:newSize]
               drawTransposed:drawTransposed
         interpolationQuality:quality];
}

// Resizes the image according to the given content mode, taking into account the image's orientation
- (NKImage *)resizedImageWithContentMode:(NKViewContentMode)contentMode
                                  bounds:(CGSize)bounds
                    interpolationQuality:(CGInterpolationQuality)quality {
    CGFloat horizontalRatio = bounds.width / self.size.width;
    CGFloat verticalRatio = bounds.height / self.size.height;
    CGFloat ratio;
    
    switch (contentMode) {
        case NKViewContentModeScaleAspectFill:
            ratio = MAX(horizontalRatio, verticalRatio);
            break;
            
        case NKViewContentModeScaleAspectFit:
            ratio = MIN(horizontalRatio, verticalRatio);
            break;
            
        default:
            [NSException raise:NSInvalidArgumentException format:@"Unsupported content mode: %d", contentMode];
    }
    
    CGSize newSize = CGSizeMake(self.size.width * ratio, self.size.height * ratio);
    return [self resizedImage:newSize interpolationQuality:quality];
}

#pragma mark -
#pragma mark Private helper methods

// Returns a copy of the image that has been transformed using the given affine transform and scaled to the new size
// The new image's orientation will be NKImageOrientationUp, regardless of the current image's orientation
// If the new size is not integral, it will be rounded up
- (NKImage *)resizedImage:(CGSize)newSize
                transform:(CGAffineTransform)transform
           drawTransposed:(BOOL)transpose
     interpolationQuality:(CGInterpolationQuality)quality {
    CGRect newRect = CGRectIntegral(CGRectMake(0, 0, newSize.width, newSize.height));
    CGRect transposedRect = CGRectMake(0, 0, newRect.size.height, newRect.size.width);
    CGImageRef imageRef = self.getCGImage;
    
    // Build a context that's the same dimensions as the new size
    CGContextRef bitmap = CGBitmapContextCreate(NULL,
                                                newRect.size.width,
                                                newRect.size.height,
                                                CGImageGetBitsPerComponent(imageRef),
                                                0,
                                                CGImageGetColorSpace(imageRef),
                                                CGImageGetBitmapInfo(imageRef));
    
    // Rotate and/or flip the image if required by its orientation
    CGContextConcatCTM(bitmap, transform);
    
    // Set the quality level to use when rescaling
    CGContextSetInterpolationQuality(bitmap, quality);
    
    // Draw into the context; this scales the image
    CGContextDrawImage(bitmap, transpose ? transposedRect : newRect, imageRef);
    
    // Get the resized image from the context and a NKImage
    CGImageRef newImageRef = CGBitmapContextCreateImage(bitmap);
    NKImage *newImage = [NKImage nkImageWithCGImage:newImageRef];
    
    // Clean up
    CGContextRelease(bitmap);
    CGImageRelease(newImageRef);
    
    return newImage;
}


// Returns an affine transform that takes into account the image orientation when drawing a scaled image
- (CGAffineTransform)transformForOrientation:(CGSize)newSize {
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (self.nkImageOrientation) {
        case NKImageOrientationDown:           // EXIF = 3
        case NKImageOrientationDownMirrored:   // EXIF = 4
            transform = CGAffineTransformTranslate(transform, newSize.width, newSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case NKImageOrientationLeft:           // EXIF = 6
        case NKImageOrientationLeftMirrored:   // EXIF = 5
            transform = CGAffineTransformTranslate(transform, newSize.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case NKImageOrientationRight:          // EXIF = 8
        case NKImageOrientationRightMirrored:  // EXIF = 7
            transform = CGAffineTransformTranslate(transform, 0, newSize.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (self.nkImageOrientation) {
        case NKImageOrientationUpMirrored:     // EXIF = 2
        case NKImageOrientationDownMirrored:   // EXIF = 4
            transform = CGAffineTransformTranslate(transform, newSize.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case NKImageOrientationLeftMirrored:   // EXIF = 5
        case NKImageOrientationRightMirrored:  // EXIF = 7
            transform = CGAffineTransformTranslate(transform, newSize.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    return transform;
}

@end
