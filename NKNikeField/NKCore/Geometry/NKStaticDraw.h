//
//  NKStaticDraw.h
//  NKNative
//
//  Created by Leif Shackelford on 4/6/14.
//  Copyright (c) 2014 Chroma Developer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES1/gl.h>
#import <CoreGraphics/CoreGraphics.h>


/*  GLDraw Functions borrowed from:
 *  Created by Jeff LaMarche on 9/27/08.
 *  Copyright 2008 __MyCompanyName__. All rights reserved.
 */



@interface NKStaticDraw : NSObject
{
    NSMutableDictionary *meshesCache;
    NSMutableDictionary *vertexCache;
}

+ (NKStaticDraw *)sharedInstance;
+ (NSMutableDictionary*) meshesCache;
+ (NSMutableDictionary*) vertexCache;
+ (NSMutableDictionary*) normalsCache;

+(NSString*)stringForPrimitive:(NKPrimitive)primitive;

@end

@interface UIColor(OpenGL)
- (void)setOpenGLColor;
- (void)setColorArrayToColor:(UIColor *)toColor;
@end

void GLDrawCircle (int circleSegments, CGFloat circleSize, CGPoint center, bool filled);
void GLDrawEllipse (int segments, CGFloat width, CGFloat height, CGPoint center, bool filled);
void GLDrawSpokes (int spokeCount, CGFloat radius, CGPoint center);
void GLDrawEllipticalSpokes(int spokeCount, CGFloat width, CGFloat height, CGPoint center);
void GLDrawEllipticalSpokesWithGradient(int spokeCount, CGFloat width, CGFloat height, CGPoint center, UIColor *innerColor, UIColor *outerColor);