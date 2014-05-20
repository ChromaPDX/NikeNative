//
//  NKStaticDraw.m
//  NKNative
//
//  Created by Leif Shackelford on 4/6/14.
//  Copyright (c) 2014 Chroma Developer. All rights reserved.
//

#import "NodeKitten.h"

@implementation NKStaticDraw

static NKStaticDraw *sharedObject = nil;

-(instancetype)init {
    self = [super init];
    if (self) {
        meshesCache = [NSMutableDictionary dictionary];
        vertexCache = [NSMutableDictionary dictionary];
    }
    return self;
}

+ (NKStaticDraw *)sharedInstance
{
    static dispatch_once_t _singletonPredicate;
    
    dispatch_once(&_singletonPredicate, ^{
        sharedObject = [[super alloc] init];
    });
    
    return sharedObject;
}

+(NSMutableDictionary*)meshesCache {
    return [[NKStaticDraw sharedInstance] meshesCache];
}


-(NSMutableDictionary*)meshesCache {
    return meshesCache;
}

+(NSMutableDictionary*)vertexCache {
    return [[NKStaticDraw sharedInstance] vertexCache];
}


-(NSMutableDictionary*)vertexCache {
    return vertexCache;
}

+(NSString*)stringForPrimitive:(NKPrimitive)primitive {
    
    switch (primitive) {
        case NKPrimitiveRect:
            return @"NKPrimitiveRect";
            break;
            
        case NKPrimitiveSphere:
            return @"NKPrimitiveSphere";
            break;
        
        case NKPrimitiveCube:
            return @"NKPrimitiveCube";
            break;
            
        default:
            return @"NKPrimitiveNone";
            break;
    }
    
}

@end

@implementation NKColor(OpenGL)
- (void)setOpenGLColor
{
	int numComponents = CGColorGetNumberOfComponents(self.CGColor);
	const CGFloat *components = CGColorGetComponents(self.CGColor);
	if (numComponents == 2)
	{
		CGFloat all = components[0];
		CGFloat alpha = components[1];
		glColor4f(all,all, all, alpha);
	}
	else
	{
        
		CGFloat red = components[0];
		CGFloat green = components[1];
		CGFloat blue = components[2];
		CGFloat alpha = components[3];
		glColor4f(red,green, blue, alpha);
	}
    
}
- (void)setColorArrayToColor:(NKColor *)toColor
{
	GLfloat *colorArray = malloc(sizeof(GLfloat) * 8);
    
	int numComponents = CGColorGetNumberOfComponents(self.CGColor);
	const CGFloat *components = CGColorGetComponents(self.CGColor);
    
    
	if (numComponents == 2)
	{
		colorArray[0] = components[0];
		colorArray[1] = components[0];
		colorArray[2] = components[0];
		colorArray[3] = components[1];
	}
	else
	{
		// Assuming RGBA if not grayscale
		colorArray[0] = components[0];
		colorArray[1] = components[1];
		colorArray[2] = components[2];
		colorArray[3] = components[3];
	}
    
	int otherColorNumComponents = CGColorGetNumberOfComponents(toColor.CGColor);
	const CGFloat *otherComponents = CGColorGetComponents(toColor.CGColor);
	if (otherColorNumComponents == 2)
	{
		colorArray[4] = otherComponents[0];
		colorArray[5] = otherComponents[0];
		colorArray[6] = otherComponents[0];
		colorArray[7] = otherComponents[1];
	}
	else
	{
		// Assuming RGBA if not grayscale
		colorArray[4] = otherComponents[0];
		colorArray[5] = otherComponents[1];
		colorArray[6] = otherComponents[2];
		colorArray[7] = otherComponents[3];
	}
    
	glColorPointer (4, GL_FLOAT, 4*sizeof(GLfloat), colorArray);
	free(colorArray);
    
}
@end

void GLDrawCircle (int circleSegments, CGFloat circleSize, P2t center, bool filled)
{
	GLDrawEllipse(circleSegments, circleSize, circleSize, center, filled);
}
void GLDrawEllipse (int segments, CGFloat width, CGFloat height, P2t center, bool filled)
{
	glTranslatef(center.x, center.y, 0.0);
	GLfloat vertices[segments*2];
	int count=0;
	for (GLfloat i = 0; i < 360.0f; i+=(360.0f/segments))
	{
		vertices[count++] = (cos(DEGREES_TO_RADIANS(i))*width);
		vertices[count++] = (sin(DEGREES_TO_RADIANS(i))*height);
	}
	glVertexPointer (2, GL_FLOAT , 0, vertices);
	glDrawArrays ((filled) ? GL_TRIANGLE_FAN : GL_LINE_LOOP, 0, segments);
}
void GLDrawSpokes (int spokeCount, CGFloat radius, P2t center)
{
	GLDrawEllipticalSpokes(spokeCount, radius, radius, center);
}
void GLDrawEllipticalSpokes(int spokeCount, CGFloat width, CGFloat height, P2t center)
{
	glTranslatef(center.x, center.y, 0.0);
	for (GLfloat i = 0; i < 360.0f; i+=(360.0f/spokeCount))
	{
		GLfloat vertices[4] = {0.0, 0.0, cosf(DEGREES_TO_RADIANS(i))*width, sinf(DEGREES_TO_RADIANS(i))*height};
		glVertexPointer(2, GL_FLOAT, 0, vertices);
		glDrawArrays (GL_LINES, 0, 2);
	}
}
void GLDrawEllipticalSpokesWithGradient(int spokeCount, CGFloat width, CGFloat height, P2t center, NKColor *innerColor, NKColor *outerColor)
{
	glTranslatef(center.x, center.y, 0.0);
	for (GLfloat i = 0; i < 360.0f; i+=(360.0f/spokeCount))
	{
		glEnableClientState (GL_COLOR_ARRAY);
		[innerColor setColorArrayToColor:outerColor];
		GLfloat vertices[4] = {0.0, 0.0, cosf(DEGREES_TO_RADIANS(i))*width, sinf(DEGREES_TO_RADIANS(i))*height};
		glVertexPointer(2, GL_FLOAT, 0, vertices);
		glDrawArrays (GL_LINES, 0, 2);
		glDisableClientState(GL_COLOR_ARRAY);
	}
}