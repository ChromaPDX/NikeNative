//
//  NKUIView.h
//  EMA Stage
//
//  Created by Leif Shackelford on 5/21/14.
//  Copyright (c) 2014 EMA. All rights reserved.
//

#if TARGET_OS_IPHONE

#import "NKpch.h"

@class NKUIViewController;
@class NKSceneNode;
@class NKVertexBuffer;
@class NKShaderProgram;
@class NKTexture;
@class NKFrameBuffer;

@interface NKUIView : UIView
{
    EAGLContext *context;
    CADisplayLink *displayLink;
    NKFrameBuffer *frameBuffer;
    
    NSTimeInterval lastTime;
    
    int drawHitEveryXFrames;
    int framesSinceLastHit;
    int rotate;
    
    float w;
    float h;
    float wMult;
    float hMult;
    
	BOOL controllerSetup;
    bool animating;
    
    // 2.0 stuff
    GLuint _program;
    
    //    M16t _modelViewProjectionMatrix;
    //    M9t _normalMatrix;
    float _rotation;
    
    
    // TEMP FOR DEBUG
    NKShaderProgram *defaultShader;
    NKVertexBuffer *vertexBuffer;
    NKTexture * texture;
}

@property (nonatomic, strong) NKSceneNode *scene;
@property (nonatomic, weak) NKUIViewController *controller;
@property (nonatomic) float mscale;

-(void)loadScene;
-(void)startAnimation;
-(void)stopAnimation;
-(void)drawView;
-(id)initGLES;

- (BOOL)createFramebuffer;
- (void)destroyFramebuffer;

@end

#endif
