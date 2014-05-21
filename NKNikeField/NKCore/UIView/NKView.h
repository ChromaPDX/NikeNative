//*
//*  NODE KITTEN
//*



#import "NKpch.h"
#import "NKFrameBuffer.h"

@class NKViewController;
@class NKSceneNode;
@class NKVertexBuffer;
@class NKShaderProgram;
@class NKTexture;
@class NKFrameBuffer;

// Attribute index.

#define USE_CV_DISPLAY_LINK 0
#define BUFFER_OFFSET(i) ((char *)NULL + (i))

#if NK_USE_GLES
@interface NKView : UIView
#else
@interface NKView : NSOpenGLView
#endif

{
#if NK_USE_GLES
    NKContext *context;
    CADisplayLink *displayLink;
    NKFrameBuffer *frameBuffer;
#else
#if USE_CV_DISPLAY_LINK
    static dispatch_queue_t displayThread;
    CVDisplayLinkRef displayLink;
#else
    NSTimer *displayTimer;
#endif
#endif
   
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

@property (nonatomic, weak) NKViewController *controller;
@property (nonatomic, strong) NKSceneNode *scene;
@property (nonatomic) float mscale;

#if NK_USE_GLES
-(void)startAnimation;
-(void)stopAnimation;
-(void)drawView;
- (id)initGLES;


- (BOOL)createFramebuffer;
- (void)destroyFramebuffer;

#else

/** initializes the CCGLView with a frame rect and an OpenGL context */
- (id) initWithFrame:(NSRect)frameRect shareContext:(NSOpenGLContext*)context;

/** uses and locks the OpenGL context */
-(void) lockOpenGLContext;

/** unlocks the openGL context */
-(void) unlockOpenGLContext;

/** returns the depth format of the view in BPP */
- (NSUInteger) depthFormat;

- (CVReturn) getFrameForTime:(const CVTimeStamp*)outputTime;

// private
+(void) load_;
#endif


@end


