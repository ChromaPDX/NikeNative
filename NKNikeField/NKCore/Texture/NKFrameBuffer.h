//
//  NKFrameBuffer.h
//  NKNikeField
//
//  Created by Leif Shackelford on 5/7/14.
//  Copyright (c) 2014 Chroma Developer. All rights reserved.
//

#import "NKpch.h"

@class NKTexture;
@class NKByteColor;

@interface NKFrameBuffer : NSObject

@property (nonatomic, readonly) CGSize size;
@property (nonatomic, readonly) GLuint frameBuffer;
@property (nonatomic, readonly) GLuint renderBuffer;
@property (nonatomic, readonly) GLuint depthBuffer;

@property (nonatomic) GLint width;
@property (nonatomic) GLint height;

@property (nonatomic,strong) NKTexture *renderTexture;

#if NK_USE_GLES
- (id)initWithContext:(EAGLContext *)context layer:(id <EAGLDrawable>)layer;
#else
#endif

-(instancetype)initWithWidth:(GLuint)width height:(GLuint)height;

- (void)bind;
- (void)bind:(void(^)())drawingBlock;

- (void)unbind;
- (GLuint)bindTexture:(int)texLoc;
- (NKImage *)imageAtRect:(CGRect)cropRect;


- (NKByteColor*)colorAtPoint:(P2t)point;
- (void)pixelValuesInRect:(CGRect)cropRect buffer:(GLubyte *)pixelBuffer;

@end
