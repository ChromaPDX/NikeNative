//
//  NKTexture.m
//  NodeKittenExample
//
//  Created by Chroma Developer on 3/5/14.
//  Copyright (c) 2014 Chroma. All rights reserved.
//

#import "NodeKitten.h"
#import "NKTextureManager.h"
#import <CoreText/CoreText.h>

@implementation NKTexture

// INIT
#pragma mark - INIT

+(instancetype) textureWithImageNamed:(NSString*)name {
    
    if (![[NKTextureManager imageCache] objectForKey:name]) {
        [[NKTextureManager imageCache] setObject:[[NKTexture alloc] initWithImageNamed:name] forKey:name];
        NSLog(@"add tex to atlas named: %@", name);
    }
    
    return [[NKTextureManager imageCache] objectForKey:name];
    
}

+(instancetype) textureWithPVRNamed:(NSString*)name size:(CGSize)size{
    
    if (![[NKTextureManager imageCache] objectForKey:name]) {
        [[NKTextureManager imageCache] setObject:[[NKTexture alloc] initWithPVRFile:name width:size.width height:size.height]forKey:name];
        NSLog(@"add tex to atlas named: %@", name);
    }
    
    return [[NKTextureManager imageCache] objectForKey:name];
    
}

+(instancetype) textureWithImage:(NKImage*)image {
    
    NKTexture *newTex = [[NKTexture alloc] initWithImage:image];
    
    return newTex;
    
}

+(instancetype) textureWithString:(NSString *)string ForLabelNode:(NKLabelNode*)node {
    
    if (![[NKTextureManager labelCache] objectForKey:string]) {
        [[NKTextureManager labelCache] setObject:[self textureWithString:string fontNamed:node.fontName color:node.fontColor Size:node.size fontSize:node.fontSize completion:nil] forKey:string];
        NSLog(@"add tex to atlas for label node named: %@", string);
    }
    return [[NKTextureManager labelCache] objectForKey:string];
}

+(instancetype) textureWithString:(NSString *)string ForLabelNode:(NKLabelNode *)node inBackGroundWithCompletionBlock:(void (^)())block {
    if (![[NKTextureManager labelCache] objectForKey:string]) {
        [[NKTextureManager labelCache] setObject:[self textureWithString:string fontNamed:node.fontName color:node.fontColor Size:node.size fontSize:node.fontSize completion:^{block();}] forKey:string];
        NSLog(@"add tex to atlas for label node named: %@", string);
    }
    else {
        block();
    }
    return [[NKTextureManager labelCache] objectForKey:string];
}

+(instancetype) textureWithString:(NSString *)text fontNamed:(NSString*)name color:(NKColor*)textColor Size:(CGSize)size fontSize:(CGFloat)fontSize completion:(void (^)())block{
    
    if (!textColor) {
        textColor = NKWHITE;
    }
    
    NKTexture *texture = [[NKTexture alloc] initForBackThreadWithSize:size];
    
    [texture setGlTexLocation:[NKTextureManager defaultTextureLocation]];
    
    dispatch_async([NKTextureManager textureThread], ^{
        
        CGContextRef ctx = [NKTexture newRGBAContext:size];
        
        //Prepare our view for drawing
        
        CGContextSetTextMatrix(ctx, CGAffineTransformIdentity);
        
        CGContextTranslateCTM(ctx, 0, size.height );
        CGContextScaleCTM(ctx, 1.0, -1.0);
        
        CGColorRef color = textColor.CGColor;
        
        CTFontRef font = CTFontCreateWithName((CFStringRef) name, fontSize, NULL);
        
        CTTextAlignment theAlignment = kCTCenterTextAlignment;
        
        CFIndex theNumberOfSettings = 1;
        CTParagraphStyleSetting theSettings[1] =
        {
            { kCTParagraphStyleSpecifierAlignment, sizeof(CTTextAlignment),
                &theAlignment }
        };
        
        CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(theSettings, theNumberOfSettings);
        
        NSDictionary *attributesDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                        (__bridge id)(font), kCTFontAttributeName,
                                        color, kCTForegroundColorAttributeName,
                                        paragraphStyle, kCTParagraphStyleAttributeName,
                                        nil];
        
        
        NSAttributedString *stringToDraw = [[NSAttributedString alloc] initWithString:text attributes:attributesDict];
        
        CFAttributedStringRef ref = (__bridge CFAttributedStringRef)(stringToDraw);
        
        CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(ref);
        
        //Create Frame
        CGMutablePathRef path = CGPathCreateMutable();
        
        CGPathAddRect(path, NULL, CGRectMake(0, 0, size.width, size.height));
        
        CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
        
        //Draw Frame
        
        //	CTFrameDraw(frame, ctx);
        //
        //    CGContextSetRGBFillColor(ctx, 1., 0., .5, 1.);
        //    CGContextFillRect(ctx, CGRectMake(0, 0, size.width, size.height));
        
        CTFrameDraw(frame, ctx);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [texture loadTexFromCGContext:ctx size:size];
            if (block) {
                block();
            }
        });
        //NKTexture *texture = [[NKTexture alloc] initWithTexture:[NKTexture texFromImage:UIGraphicsGetImageFromCurrentImageContext()]];
        
        NSLog(@"Creating texture with font %@, font named %@", font, name);
        
        
    });
    
    return texture;
    
}

-(instancetype) initWithImageNamed:(NSString*)name {
    self = [super init];
    
    if (self) {
        
        
        self.textureMapStyle = NKTextureMapStyleRepeat;
        
        NKImage* request = [NKImage imageNamed:name];
        if (!request) {
            request = [NKImage imageNamed:@"chromeKittenSmall.png"];
        }
        
        [self loadTexFromCGContext:[NKTexture contextFromImage:request] size:request.size];
        
        self.size = request.size;

        self.shouldResizeToTexture = false;

    }
    
    return self;
}

- (id)initWithPVRFile:(NSString *)inFilename width:(GLuint)inWidth height:(GLuint)inHeight;
{
    if ((self = [super init]))
    {
        glEnable(GL_TEXTURE_2D);
        
        glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);
        glGenTextures(1, &texture[0]);
        glBindTexture(GL_TEXTURE_2D, texture[0]);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
        glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
        glBlendFunc(GL_ONE, GL_SRC_COLOR);
        NSString *extension = [inFilename pathExtension];
        NSString *base = [[inFilename componentsSeparatedByString:@"."] objectAtIndex:0];
        NSString *path = [[NSBundle mainBundle] pathForResource:base ofType:extension];
        NSData *texData = [[NSData alloc] initWithContentsOfFile:path];
        
        // Assumes pvr4 is RGB not RGBA, which is how texturetool generates them
        if ([extension isEqualToString:@"pvr4"])
            glCompressedTexImage2D(GL_TEXTURE_2D, 0, GL_COMPRESSED_RGB_PVRTC_4BPPV1_IMG, inWidth, inHeight, 0, (inWidth * inHeight) / 2, [texData bytes]);
        else if ([extension isEqualToString:@"pvr2"])
            glCompressedTexImage2D(GL_TEXTURE_2D, 0, GL_COMPRESSED_RGB_PVRTC_2BPPV1_IMG, inWidth, inHeight, 0, (inWidth * inHeight) / 2, [texData bytes]);
        else
        {
            UIImage *image = [[UIImage alloc] initWithData:texData];
            if (image == nil)
                return nil;
            
            GLuint width = CGImageGetWidth(image.CGImage);
            GLuint height = CGImageGetHeight(image.CGImage);
            CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
            void *imageData = malloc( height * width * 4 );
            CGContextRef context = CGBitmapContextCreate( imageData, width, height, 8, 4 * width, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big );
            CGColorSpaceRelease( colorSpace );
            CGContextClearRect( context, CGRectMake( 0, 0, width, height ) );
            CGContextTranslateCTM( context, 0, height - height );
            CGContextDrawImage( context, CGRectMake( 0, 0, width, height ), image.CGImage );
            
            glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
            GLuint errorcode = glGetError();
            CGContextRelease(context);
            
            free(imageData);
            //			[image release];
        }
        glEnable(GL_BLEND);
        
    }
    return self;
}

-(instancetype) initWithImage:(NKImage*)image {
    self = [super init];
    
    if (self) {
        self.textureMapStyle = NKTextureMapStyleRepeat;
        

        if (!image) {
            image = [NKImage imageNamed:@"chromeKitten.png"];
        }
        
        [self loadTexFromCGContext:[NKTexture contextFromImage:image] size:image.size];
        
        self.size = image.size;

        self.shouldResizeToTexture = false;
    }
    
    return self;
}


-(instancetype) initWithCGContext:(CGContextRef)ref size:(CGSize)size{
    self = [super init];
    
    if (self) {
        self.textureMapStyle = NKTextureMapStyleRepeat;
        [self loadTexFromCGContext:ref size:size];
        self.size = size;
        self.shouldResizeToTexture = false;
    }
    
    return self;
}

-(instancetype) initForBackThreadWithSize:(CGSize)size {
    self = [super init];
    
    if (self) {
        self.textureMapStyle = NKTextureMapStyleRepeat;
        self.size = size;
        self.shouldResizeToTexture = false;
    }
    
    return self;
    
}



+(NKTexture*)blankTexture {
    return [NKTexture textureWithImageNamed:@"blank_texture"];
//    
//    CGSize sz = CGSizeMake(10, 10);
//    NKTexture* tex = [[NKTexture alloc]initForBackThreadWithSize:sz];
//    CGContextRef context = [NKTexture newRGBAContext:sz];
//    CGContextClearRect(context, CGRectMake(0, 0, sz.width, sz.height));
////    CGContextSetRGBFillColor(context, 0, 0, 0, 0.);
////    CGContextFillRect(context, CGRectMake(0, 0, sz.width, sz.height));
//    [tex loadTexFromCGContext:context size:sz];
//    
//    return tex;
    
}
#pragma mark - PROPS



+(CGContextRef) contextFromImage:(NKImage*)image {
    CGImageRef imageRef = image.CGImage;
    
    CGSize size = CGSizeMake(CGImageGetWidth(imageRef), CGImageGetHeight(imageRef));
    
    CGContextRef ctx = [NKTexture newBitmapRGBA8ContextFromImage:imageRef];
    
    CGContextTranslateCTM(ctx, 0, size.height );
    CGContextScaleCTM(ctx, 1.0, -1.0);
    
    CGContextClearRect(ctx, CGRectMake(0, 0, size.width, size.height));
    CGContextDrawImage(ctx, CGRectMake(0, 0, size.width, size.height), imageRef);
    
    return ctx;
    
}

-(void)loadTexFromCGContext:(CGContextRef)context size:(CGSize)size {
    
    int w = size.width;
    int h = size.height;
    int glFormat = GL_RGBA;
    int glType = GL_UNSIGNED_BYTE;

    if (NK_GL_VERSION == 2) {
        glActiveTexture(GL_TEXTURE0);
        glGenTextures(1, (GLuint *)&texture[0]);
        glBindTexture(GL_TEXTURE_2D, texture[0]);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        // This is necessary for non-power-of-two textures
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        glBindTexture(GL_TEXTURE_2D, 0);
        
       // glActiveTexture(GL_TEXTURE1);
       // glGenFramebuffers(1, &defaultFramebuffer);
       // glBindFramebuffer(GL_FRAMEBUFFER, defaultFramebuffer);
        
        glBindTexture(GL_TEXTURE_2D, texture[0]);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, w, h, 0, GL_RGBA, GL_UNSIGNED_BYTE, (unsigned char *)CGBitmapContextGetData(context));
        //glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, texture[0], 0);
        
        //        GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
        //
        //        NSAssert(status == GL_FRAMEBUFFER_COMPLETE, @"Incomplete filter FBO: %d", status);
        glBindTexture(GL_TEXTURE_2D, 0);
    }
    
    else {
    GLuint texTarget = GL_TEXTURE_2D;
    
    // GENERATE / BIND
	glGenTextures(1, (GLuint *)&texture[0]);   // could be more then one, but for now, just one
	glEnable(texTarget);
	glBindTexture(texTarget, texture[0]);
 
    // TEXTURE MODE
    glHint(GL_GENERATE_MIPMAP_HINT, GL_NICEST);
	glTexParameterf(texTarget, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameterf(texTarget, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameterf(texTarget, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameterf(texTarget, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAX_ANISOTROPY_EXT, 2.0);

    // DRAW TO TEXTURE
    glTexImage2D(texTarget, 0, glFormat, w, h, 0, glFormat, glType, (unsigned char *)CGBitmapContextGetData(context));
    //glTexSubImage2D(texTarget, 0, 0, 0, w, h, glFormat, glType, (unsigned char *)CGBitmapContextGetData(context));
    
    //CLEAN UP
 	glDisable(texTarget);
    GLuint errorcode = glGetError();
    if (errorcode) {
        NSLog(@"GL TEX LOAD ERROR : %d", errorcode);
    }
    else {
        NSLog(@"loaded GL tex %d , %lu bytes size: %lu %lu", texture[0],h * CGBitmapContextGetBytesPerRow(context),CGBitmapContextGetWidth(context) ,CGBitmapContextGetHeight(context) );
    }
        
    }
    
    CGContextRelease(context);
}

-(GLuint)glTexLocation {
    return texture[0];
}

-(void)setGlTexLocation:(GLuint)loc {
    texture[0] = loc;
}

//-(void)loadTexFromCGContext:(CGContextRef)context size:(CGSize)size {
//    
//    int w = size.width;
//    int h = size.height;
//    int glFormat = GL_RGBA;
//    int glType = GL_UNSIGNED_BYTE;
//    
//    
//    GLuint texTarget = GL_TEXTURE_2D;
//    
//	glEnable(texTarget);
//    
//	glGenTextures(1, (GLuint *)&texture[0]);   // could be more then one, but for now, just one
//    
//	glBindTexture(texTarget, texture[0]);
//    
//    glTexImage2D(texTarget, 0, glType, (GLint)w, (GLint)h, 0, glFormat, glType,  0);
//    
//    glTexSubImage2D(texTarget, 0, 0, 0, w, h, glFormat, glType, (unsigned char *)CGBitmapContextGetData(context));
//    
//    glHint(GL_GENERATE_MIPMAP_HINT, GL_NICEST);
//    
//	glTexParameterf(texTarget, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
//	glTexParameterf(texTarget, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
//	glTexParameterf(texTarget, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
//	glTexParameterf(texTarget, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
//    
//    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAX_ANISOTROPY_EXT, 2.0);
//    
//	glDisable(texTarget);
//    
//}

#pragma mark - UPDATE / DRAW

-(void)updateWithTimeSinceLast:(F1t)dt {
    
}

-(void)bind {

    glEnable(GL_TEXTURE_2D);
    glBindTexture(GL_TEXTURE_2D, texture[0]);

}

-(void)unbind {

    glBindTexture(GL_TEXTURE_2D, 0);
    glDisable(GL_TEXTURE_2D);

}

-(void)dealloc {

    glDeleteTextures(1, &texture[0]);
    
}

#pragma mark - CGContext Utilities

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

+(CGContextRef)newRGBAContext:(CGSize)size {
    
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

+ (CGContextRef) newBitmapRGBA8ContextFromImage:(CGImageRef) image {
	CGContextRef context = NULL;
	CGColorSpaceRef colorSpace;
	uint32_t *bitmapData;
    
	size_t bitsPerPixel = 32;
	size_t bitsPerComponent = 8;
	size_t bytesPerPixel = bitsPerPixel / bitsPerComponent;
    
	size_t width = CGImageGetWidth(image);
	size_t height = CGImageGetHeight(image);
    
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

+ (unsigned char *) convertNKImageToBitmapRGBA8:(NKImage *) image {
    
	CGImageRef imageRef = image.CGImage;
    
	// Create a bitmap context to draw the uiimage into
	CGContextRef context = [self newBitmapRGBA8ContextFromImage:imageRef];
    
	if(!context) {
		return NULL;
	}
    
	size_t width = CGImageGetWidth(imageRef);
	size_t height = CGImageGetHeight(imageRef);
    
	CGRect rect = CGRectMake(0, 0, width, height);
    
	// Draw image into the context to get the raw image data
	CGContextDrawImage(context, rect, imageRef);
    
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


+ (NKImage *) convertBitmapRGBA8ToNKImage:(unsigned char *) buffer
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
		if([NKImage respondsToSelector:@selector(imageWithCGImage:scale:orientation:)]) {
			float scale = [[UIScreen mainScreen] scale];
			image = [NKImage imageWithCGImage:imageRef scale:scale orientation:UIImageOrientationUp];
		} else {
			image = [NKImage imageWithCGImage:imageRef];
		}
        
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

@end

