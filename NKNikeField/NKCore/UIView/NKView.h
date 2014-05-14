//*
//*  NODE KITTEN
//*

#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

//#define SHOW_HIT_DETECTION
#define NK_GL_VERSION 2

@class NKViewController;
@class NKSceneNode;
@class NKVertexBuffer;
@class NKShaderProgram;
@class NKTexture;
@class NKFrameBuffer;

// Attribute index.

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

@interface NKView : UIView
{
	EAGLContext *context;
    
    NKFrameBuffer *frameBuffer;
    
	//GLuint frameBuffer, colorRenderbuffer,depthRenderbuffer;
    //GLint bufferWidth, bufferHeight;


    
	NSTimer *animationTimer;
    NSTimeInterval lastTime;
    
    int drawHitEveryXFrames;
    int framesSinceLastHit;

	BOOL controllerSetup;
    
    
    // 2.0 stuff
    GLuint _program;
    
    M16t _modelViewProjectionMatrix;
    M9t _normalMatrix;
    float _rotation;
    
    
    // TEMP FOR DEBUG
    NKShaderProgram *defaultShader;
    NKVertexBuffer *vertexBuffer;
    NKTexture * texture;
}

@property (nonatomic, weak) NKViewController *controller;
@property (nonatomic, strong) NKSceneNode *scene;

@property (nonatomic, strong) CADisplayLink* displayLink;

//@property (nonatomic) NSTimeInterval animationInterval;

-(void)startAnimation;
-(void)stopAnimation;
-(void)drawView;

- (id)initGLES;
- (BOOL)createFramebuffer;
- (void)destroyFramebuffer;

@end


