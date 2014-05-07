//
//  NKFrameBuffer.h
//  NKNikeField
//
//  Created by Leif Shackelford on 5/7/14.
//  Copyright (c) 2014 Chroma Developer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NKFrameBuffer : NSObject

@property (nonatomic, readonly) CGSize size;
@property (nonatomic, readonly) GLuint locFramebuffer;
@property (nonatomic, readonly) GLuint locRenderbuffer;
@property (nonatomic, readonly) GLuint locRenderTexture;

- (id)initWithPixelWidth:(int)width pixelHeight:(int)height;

- (void)bind;
- (void)bind:(void(^)())drawingBlock;
- (void)unbind;
- (GLuint)bindTexture:(int)texLoc;
- (UIImage *)imageAtRect:(CGRect)cropRect;
- (void)pixelValuesInRect:(CGRect)cropRect buffer:(GLubyte *)pixelBuffer;

@end

static inline void NKCheckGLError(NSString *contextString)
{
    for (GLint error = glGetError(); error; error = glGetError())
    {
        NSLog(@"GL Error @ %@", contextString);
        switch (error)
        {
            case GL_NO_ERROR:
                NSLog(@"GL_NO_ERROR");
                break;
            case GL_INVALID_ENUM:
                NSLog(@"GL_INVALID_ENUM");
                break;
            case GL_INVALID_VALUE:
                NSLog(@"GL_INVALID_VALUE");
                break;
            case GL_INVALID_OPERATION:
                NSLog(@"GL_INVALID_OPERATION");
                break;
            case GL_INVALID_FRAMEBUFFER_OPERATION:
                NSLog(@"GL_INVALID_FRAMEBUFFER_OPERATION");
                break;
            case GL_OUT_OF_MEMORY:
                NSLog(@"GL_OUT_OF_MEMORY");
                break;
            case GL_STACK_UNDERFLOW:
                NSLog(@"GL_STACK_UNDERFLOW");
                break;
            case GL_STACK_OVERFLOW:
                NSLog(@"GL_STACK_OVERFLOW");
                break;
        }
    }
};
