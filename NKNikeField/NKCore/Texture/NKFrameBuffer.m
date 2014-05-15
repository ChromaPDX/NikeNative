//
//  NKFrameBuffer.m
//  NKNikeField
//
//  Created by Leif Shackelford on 5/7/14.
//  Copyright (c) 2014 Chroma Developer. All rights reserved.
//
#import "NKFrameBuffer.h"
#import "UIImage+GLBuffer.h"
#import "NKTexture.h"

@implementation NKFrameBuffer

#pragma mark - Init

- (id)initWithContext:(EAGLContext *)context layer:(id<EAGLDrawable>)layer
{
    self = [super init];
    
    if(self){
        
        // 1 // Create the framebuffer and bind it.
        
        glGenFramebuffers(1, &_frameBuffer);
        glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
        
        // 2 // Create a color renderbuffer, allocate storage for it, and attach it to the framebuffer’s color attachment point.
        
        glGenRenderbuffers(1, &_renderBuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
        
        [context renderbufferStorage:GL_RENDERBUFFER fromDrawable:layer];
        
        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_width);
        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_height);
        
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _renderBuffer);
        
        // 3 // Create a depth or depth/stencil renderbuffer, allocate storage for it, and attach it to the framebuffer’s depth attachment point.
        
        glGenRenderbuffers(1, &_depthBuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, _depthBuffer);
        glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, _width, _height);
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _depthBuffer);
        
        // 4 // Test the framebuffer for completeness. This test only needs to be performed when the framebuffer’s configuration changes.
        
        GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER) ;
        if(status != GL_FRAMEBUFFER_COMPLETE) {
            NSLog(@"failed to make complete framebuffer object %x", status);
            return nil;
        }

       // _renderTexture = [[NKTexture alloc]initWithSize:S2Make(_width, _height)];
//        // Offscreen position framebuffer texture target
//        glGenTextures(1, &_locRenderTexture);
//        glBindTexture(GL_TEXTURE_2D, _locRenderTexture);
//        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
//        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
//        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
//        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
//        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, _size.width, _size.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, 0);
//        glBindTexture(GL_TEXTURE_2D, 0);
//        
//        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _locRenderTexture, 0);
//        
//        // Always check that our framebuffer is ok
//        if(glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
//        {
//            NKCheckGLError(@"Creating framebuffer");
//        }
        
    }
    
    return self;
    
}

-(instancetype)initWithWidth:(GLuint)width height:(GLuint)height {
    
    self = [super init];
    
    if(self){
        
        NSLog(@"init 2ndary frame buffer");
        
        _width = width;
        _height = height;
        
        // 1 // Create the framebuffer and bind it.
        
        glGenFramebuffers(1, &_frameBuffer);
        glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
        
        // 2 // Create a color renderbuffer, allocate storage for it, and attach it to the framebuffer’s color attachment point.
        
        glGenRenderbuffers(1, &_renderBuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
        glRenderbufferStorage(GL_RENDERBUFFER, GL_RGB8_OES, width,height);
        
        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_width);
        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_height);
        
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _renderBuffer);
        
        // 3 // Create a depth or depth/stencil renderbuffer, allocate storage for it, and attach it to the framebuffer’s depth attachment point.
        
        glGenRenderbuffers(1, &_depthBuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, _depthBuffer);
        glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, _width, _height);
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _depthBuffer);
        
        // 4 // Test the framebuffer for completeness. This test only needs to be performed when the framebuffer’s configuration changes.
        
        GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER) ;
        if(status != GL_FRAMEBUFFER_COMPLETE) {
            NSLog(@"failed to make complete framebuffer object %x", status);
            return false;
        }
        
        _renderTexture = [[NKTexture alloc]initWithSize:S2Make(_width, _height)];

        
//        // Offscreen position framebuffer texture target
//        glGenTextures(1, &_locRenderTexture);
//        glBindTexture(GL_TEXTURE_2D, _locRenderTexture);
//        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
//        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
//        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
//        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
//        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, _size.width, _size.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, 0);
//        glBindTexture(GL_TEXTURE_2D, 0);
//        
        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _renderTexture.glTexLocation, 0);
        
        // Always check that our framebuffer is ok
        if(glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
        {
            NSLog(@"ERROR Creating framebuffer");
            return nil;
        }
        
        
    }
    
    NSLog(@"successfully made texture / framebuffer: %d", _renderBuffer);
    
    return self;
    
}
    
//    // 1 // Create the framebuffer and bind it.
//    
//    glGenFramebuffers(1, &_locFramebuffer);
//    glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);
//    
//    // 2 // Create a color renderbuffer, allocate storage for it, and attach it to the framebuffer’s color attachment point.
//    
//    glGenRenderbuffers(1, &colorRenderbuffer);
//    glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
//    //glRenderbufferStorage(GL_RENDERBUFFER, GL_RGBA8, bufferWidth, bufferHeight);
//    [context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(id<EAGLDrawable>)self.layer];
//    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &bufferWidth);
//    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &bufferHeight);
//    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, colorRenderbuffer);
//    
//    // 3 // Create a depth or depth/stencil renderbuffer, allocate storage for it, and attach it to the framebuffer’s depth attachment point.
//    
//    glGenRenderbuffers(1, &depthRenderbuffer);
//    glBindRenderbuffer(GL_RENDERBUFFER, depthRenderbuffer);
//    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, bufferWidth, bufferHeight);
//    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthRenderbuffer);
//    
//    // 4 // Test the framebuffer for completeness. This test only needs to be performed when the framebuffer’s configuration changes.
//    
//    GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER) ;
//    if(status != GL_FRAMEBUFFER_COMPLETE) {
//        NSLog(@"failed to make complete framebuffer object %x", status);
//        return false;
//    }
//    return true;
//}

#pragma mark - Binding

- (void)bind
{
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    glViewport(0, 0, _width, _height);
}

- (void)bind:(void(^)())drawingBlock
{
    [self bind];
    drawingBlock();
    [self unbind];
}


- (void)unbind
{
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
}

-(void)dealloc {

        glBindFramebuffer(GL_FRAMEBUFFER, 0);
    
        glDeleteFramebuffersOES(1, &_frameBuffer);
        glDeleteRenderbuffersOES(1, &_renderBuffer);

        if(_depthBuffer)
        {
            glDeleteRenderbuffersOES(1, &_depthBuffer);
            _depthBuffer = 0;
        }
}
//- (GLuint)bindTexture:(int)texLoc
//{
//    glEnable(GL_TEXTURE_2D);
//    glActiveTexture(texLoc);
//    glBindTexture(GL_TEXTURE_2D, self.locRenderTexture);
//    return self.locRenderTexture;
//}

#pragma mark - Accessing Data

- (NKColor*)colorAtPoint:(P2t)point {

    //NSLog(@"read pixels at %d, %d", (int)point.x, (int)point.y);

    uB4t hitCol;
    
    [self bind];
    
    glReadPixels((int)point.x, (int)point.y,
                 1, 1,
                 GL_RGBA, GL_UNSIGNED_BYTE, &hitCol);
    
    [self unbind];

    return [NKColor colorWithRed:(hitCol.r / 255.) green:(hitCol.g / 255.) blue:(hitCol.b / 255.) alpha:1.];
    
}

- (void)pixelValuesInRect:(CGRect)cropRect buffer:(GLubyte *)pixelBuffer
{
    GLint width = cropRect.size.width;
    GLint height = cropRect.size.height;
    glReadPixels(cropRect.origin.x, cropRect.origin.y,
                 width, height,
                 GL_RGBA, GL_UNSIGNED_BYTE, pixelBuffer);
}

- (UIImage *)imageAtRect:(CGRect)cropRect
{
    GLint width = cropRect.size.width;
    GLint height = cropRect.size.height;
    
    NSInteger myDataLength = width * height * 4;
    
    // allocate array and read pixels into it.
    GLubyte *buffer = (GLubyte *) malloc(myDataLength);
    
    [self pixelValuesInRect:cropRect buffer:buffer];
    
    return [UIImage imageWithBuffer:buffer ofSize:cropRect.size];
}

@end