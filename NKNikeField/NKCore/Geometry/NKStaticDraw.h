//*
//*  NODE KITTEN
//*
#import <Foundation/Foundation.h>
#import <OpenGLES/ES1/gl.h>
#import <CoreGraphics/CoreGraphics.h>


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



/*  GLDraw Functions borrowed from:
 *  Created by Jeff LaMarche on 9/27/08.
 */

void GLDrawCircle (int circleSegments, CGFloat circleSize, P2t center, bool filled);
void GLDrawEllipse (int segments, CGFloat width, CGFloat height, P2t center, bool filled);
void GLDrawSpokes (int spokeCount, CGFloat radius, P2t center);
void GLDrawEllipticalSpokes(int spokeCount, CGFloat width, CGFloat height, P2t center);
void GLDrawEllipticalSpokesWithGradient(int spokeCount, CGFloat width, CGFloat height, P2t center, UIColor *innerColor, UIColor *outerColor);