//
//  GLView.m
//  Wavefront OBJ Loader
//
//  Created by Jeff LaMarche on 12/14/08.
//  Copyright Jeff LaMarche 2008. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>
#import <OpenGLES/ES2/gl.h>
#import "NodeKitten.h"

GLfloat gCubeVertexData[216] =
{
    // Data layout for each line below is:
    // positionX, positionY, positionZ,     normalX, normalY, normalZ,
    0.5f, -0.5f, -0.5f,        1.0f, 0.0f, 0.0f,
    0.5f, 0.5f, -0.5f,         1.0f, 0.0f, 0.0f,
    0.5f, -0.5f, 0.5f,         1.0f, 0.0f, 0.0f,
    0.5f, -0.5f, 0.5f,         1.0f, 0.0f, 0.0f,
    0.5f, 0.5f, -0.5f,         1.0f, 0.0f, 0.0f,
    0.5f, 0.5f, 0.5f,          1.0f, 0.0f, 0.0f,
    
    0.5f, 0.5f, -0.5f,         0.0f, 1.0f, 0.0f,
    -0.5f, 0.5f, -0.5f,        0.0f, 1.0f, 0.0f,
    0.5f, 0.5f, 0.5f,          0.0f, 1.0f, 0.0f,
    0.5f, 0.5f, 0.5f,          0.0f, 1.0f, 0.0f,
    -0.5f, 0.5f, -0.5f,        0.0f, 1.0f, 0.0f,
    -0.5f, 0.5f, 0.5f,         0.0f, 1.0f, 0.0f,
    
    -0.5f, 0.5f, -0.5f,        -1.0f, 0.0f, 0.0f,
    -0.5f, -0.5f, -0.5f,       -1.0f, 0.0f, 0.0f,
    -0.5f, 0.5f, 0.5f,         -1.0f, 0.0f, 0.0f,
    -0.5f, 0.5f, 0.5f,         -1.0f, 0.0f, 0.0f,
    -0.5f, -0.5f, -0.5f,       -1.0f, 0.0f, 0.0f,
    -0.5f, -0.5f, 0.5f,        -1.0f, 0.0f, 0.0f,
    
    -0.5f, -0.5f, -0.5f,       0.0f, -1.0f, 0.0f,
    0.5f, -0.5f, -0.5f,        0.0f, -1.0f, 0.0f,
    -0.5f, -0.5f, 0.5f,        0.0f, -1.0f, 0.0f,
    -0.5f, -0.5f, 0.5f,        0.0f, -1.0f, 0.0f,
    0.5f, -0.5f, -0.5f,        0.0f, -1.0f, 0.0f,
    0.5f, -0.5f, 0.5f,         0.0f, -1.0f, 0.0f,
    
    0.5f, 0.5f, 0.5f,          0.0f, 0.0f, 1.0f,
    -0.5f, 0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    0.5f, -0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    0.5f, -0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    -0.5f, 0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    -0.5f, -0.5f, 0.5f,        0.0f, 0.0f, 1.0f,
    
    0.5f, -0.5f, -0.5f,        0.0f, 0.0f, -1.0f,
    -0.5f, -0.5f, -0.5f,       0.0f, 0.0f, -1.0f,
    0.5f, 0.5f, -0.5f,         0.0f, 0.0f, -1.0f,
    0.5f, 0.5f, -0.5f,         0.0f, 0.0f, -1.0f,
    -0.5f, -0.5f, -0.5f,       0.0f, 0.0f, -1.0f,
    -0.5f, 0.5f, -0.5f,        0.0f, 0.0f, -1.0f
};

@implementation NKView

+ (Class) layerClass
{
	return [CAEAGLLayer class];
}

//-(id)initWithFrame:(CGRect)frame
//{
//	self = [super initWithFrame:frame];
//	if(self != nil)
//	{
//		self = [self initGLES];
////        self.scene = [[DevMenu alloc]initWithSize:S2Make(self.frame.size.width*2., self.frame.size.height*2.)];
////        self.scene.nkView = self;
//        
//        NSLog(@"INIT NodeKitten View");
//        [self startAnimation];
//	}
//	return self;
//}



- (id) initWithCoder:(NSCoder*)coder
{
    
    if ((self = [super initWithCoder:coder]))
    {
        // Get the layer
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        
        float contentScale = 1.0f;
        drawHitEveryXFrames = 10;
        
        if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)]) {
            contentScale = [[UIScreen mainScreen] scale];
        }
        
        eaglLayer.contentsScale = contentScale;
        
        eaglLayer.opaque = TRUE;
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithBool:FALSE], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
        
        
        if (NK_GL_VERSION == 2){
        context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        }
        else {
           context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
        }
        
        if (!context || ![EAGLContext setCurrentContext:context])
        {
            return nil;
        }
        
        if(!context || ![self createFramebuffer]){
            NSLog(@"Frame Buffer Creation Failed !!");

        }
        else {
            NSLog(@"GLES Context && Frame Buffer loaded!");
          
            
            if (NK_GL_VERSION == 2) {
                [self setupVBOs];
                defaultShader = [[NKShaderProgram alloc]initWithVertexSource:nkDefaultTextureVertexShader fragmentSource:nkDefaultTextureFragmentShader];
                [defaultShader load];
            }

        }
        
        [NKTextureManager sharedInstance];
    }
    
    return self;
}

//-(id)initGLES
//{
//	CAEAGLLayer *eaglLayer = (CAEAGLLayer*) self.layer;
//	
//	// Configure it so that it is opaque, does not retain the contents of the backbuffer when displayed, and uses RGBA8888 color.
//	eaglLayer.opaque = YES;
//	eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
//                                    [NSNumber numberWithBool:FALSE], kEAGLDrawablePropertyRetainedBacking,
//                                    kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat,
//                                    nil];
//	
//	// Create our EAGLContext, and if successful make it current and create our framebuffer.
//	context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
//	if(!context || ![EAGLContext setCurrentContext:context] || ![self createFramebuffer] || ![self attachDepthBuffer])
//	{
//		return nil;
//	}
//    else {
//        NSLog(@"GLES Context && Frame Buffer loaded!");
//    }
//	
//	// Default the animation interval to 1/60th of a second.
//	self.animationInterval = 1.0 / kRenderingFrequency;
//	return self;
//}

// If our view is resized, we'll be asked to layout subviews.
// This is the perfect opportunity to also update the framebuffer so that it is
// the same size as our display area.
-(void)layoutSubviews
{
	[EAGLContext setCurrentContext:context];
	[self destroyFramebuffer];
    NSLog(@"rebuilding framebuffer");
	[self createFramebuffer];
	[self drawView];
}

-(void)destroyFramebuffer {
    frameBuffer = nil;
}

-(BOOL) createFramebuffer {
    frameBuffer = [[NKFrameBuffer alloc ]initWithContext:context layer:(id<EAGLDrawable>)self.layer];
    if (frameBuffer) {
        return true;
    }
    return false;
}

//- (BOOL)createFramebuffer {
//
////Build the main FrameBuffer
//glGenFramebuffers(1, &frameBuffer);
//glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);
//
////Build the color Buffer
//glGenRenderbuffers(1, &colorBuffer);
//glBindRenderbuffer(GL_RENDERBUFFER, colorBuffer);
//
////setup the color buffer with the EAGLLayer (it automatically defines width and height of the buffer)
//[context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(id<EAGLDrawable>)self.layer];
//glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &bufferWidth);
//glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &bufferHeight);
//
////Attach the colorbuffer to the framebuffer
//glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, colorBuffer);
//
//if(glCheckFramebufferStatusOES(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
//{
//    NSLog(@"failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
//    return NO;
//}
//
//return YES;
//
//}
//
//-(BOOL)attachDepthBuffer {
//    glGenRenderbuffers(1, &depthRenderbuffer);
//	glBindRenderbuffer(GL_RENDERBUFFER, depthRenderbuffer);
//    
//	glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, bufferWidth, bufferHeight);
//	glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthRenderbuffer);
//    
//	if(glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
//	{
//		NSLog(@"failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
//		return NO;
//	}
//	
//	return YES;
//}

//- (BOOL)createFramebuffer
//{
//    
//    // 1 // Create the framebuffer and bind it.
//    
//    glGenFramebuffers(1, &frameBuffer);
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

-(BOOL)attachDepthBuffer {
    return true;
}

typedef struct {
    float Position[3];
    float Color[4];
} Vertex;

V3t vertices[] = {
    {-1.0f,  1.0f, -0.0},
    { 1.0f,  1.0f, -0.0},
    {-1.0f, -1.0f, -0.0},
//    { .5f, -.5f, -0.0}
};

V3t normals[] = {
    {0.0, 0.0, 1.0},
    {0.0, 0.0, 1.0},
    {0.0, 0.0, 1.0},
 //   {0.0, 0.0, 1.0}
};

C4t colors[] = {
    {1.,0.,0.,1.,},
    {0.,1.,0.,1.,},
    {0.,0.,1.,1.,},
};

GLfloat texCoords[] = {
    0.0, 1.0,
    1.0, 1.0,
    0.0, 0.0,
  //  1.0, 0.0
};


static const GLubyte Indices[] = {
    0, 1, 2,
  //  2, 3, 0
};

- (void)setupVBOs {
    
    //vertexBuffer = [[NKVertexBuffer alloc] initWithVertexData:vertices ofSize:sizeof(vertices)];
    //vertexBuffer = [NKVertexBuffer defaultRect];
    
    //texture = [NKTexture textureWithImageNamed:@"sdf"];
    
}


- (void)startAnimation

{
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(drawView)];
    [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];

    lastTime = CFAbsoluteTimeGetCurrent();
}

- (void)stopAnimation
{
    [_displayLink invalidate];
}

static int rotate = 0;
// Updates the OpenGL view when the timer fires
- (void)drawView
{
    F1t dt = (CFAbsoluteTimeGetCurrent() - lastTime) * 1000.;
    //NSLog(@"%d frame rate", (int)(1000. / dt));
    
    lastTime = CFAbsoluteTimeGetCurrent();
    
	// Make sure that you are drawing to the current context
	[EAGLContext setCurrentContext:context];
    
    framesSinceLastHit++;
    if (framesSinceLastHit > drawHitEveryXFrames) {
        if (_scene) {
            [_scene drawForHitDetection];
        }
        framesSinceLastHit = 0;
    }

    
    [frameBuffer bind];
    
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glClearColor(0.0f, 0.1f, 0.1f, 1.0f);

    if (_scene) {
       // NSLog(@"frame time: %f1.0",dt);
        [_scene updateWithTimeSinceLast:dt];
        
        [_scene draw];
        //[_scene drawForHitDetection];
    }
    
    else {
        
        if (NK_GL_VERSION == 2) {
            rotate > 359 ? rotate = 0 : rotate++;
            
            _modelViewProjectionMatrix = M16MakeRotate(Q4FromV3(V3Make(0, rotate, 0)));
            
            _normalMatrix = M9IdentityMake();
            
            [defaultShader use];
            
            [defaultShader setMatrix4:_modelViewProjectionMatrix forUniform:UNIFORM_MODELVIEWPROJECTION_MATRIX];
            [defaultShader setMatrix3:_normalMatrix forUniform:UNIFORM_NORMAL_MATRIX];
            
            // 1
            //glViewport(0, 0, self.frame.size.width*2., self.frame.size.height*2.);
            
            // 2
            [defaultShader setInt:1 forUniform:USE_UNIFORM_COLOR];
            [defaultShader setVec4:C4Make(1., 1., 1., 1.) forUniform:UNIFORM_COLOR];
            
            [texture enableAndBind:0];
            
            [vertexBuffer bind:^{
                glDrawArrays(GL_TRIANGLES, 0, vertexBuffer.numberOfElements);
            }];
        }
        else {

        }
    }

    glBindRenderbufferOES(GL_RENDERBUFFER, frameBuffer.frameBuffer);
	[context presentRenderbuffer:GL_RENDERBUFFER];
    
    
}

-(void)quickSquare {
    //rotate > 359 ? rotate = 0 : rotate++;
    
    _modelViewProjectionMatrix = M16MakeRotate(Q4FromV3(V3Make(0, rotate, 0)));
    
    _normalMatrix = M9IdentityMake();
    
    [defaultShader use];
    
    [defaultShader setMatrix4:_modelViewProjectionMatrix forUniform:UNIFORM_MODELVIEWPROJECTION_MATRIX];
    [defaultShader setMatrix3:_normalMatrix forUniform:UNIFORM_NORMAL_MATRIX];
    
    // 1
    glViewport(0, 0, self.frame.size.width*2., self.frame.size.height*2.);
    
    // 2
    [defaultShader setInt:1 forUniform:USE_UNIFORM_COLOR];
    [defaultShader setVec4:C4Make(1., 1., 1., 1.) forUniform:UNIFORM_COLOR];
    
    [texture enableAndBind:0];
    
    [vertexBuffer bind:^{
        glDrawArrays(GL_TRIANGLES, 0, vertexBuffer.numberOfElements);
    }];
}





//-(void)initViewPort{
//
//    float fieldOfView = 25;
//    float aspectRatio = (float)[[UIScreen mainScreen] bounds].size.width / (float)[[UIScreen mainScreen] bounds].size.height;
//    if([UIApplication sharedApplication].statusBarOrientation > 2)
//        aspectRatio = 1/aspectRatio;
//    
//    glMatrixMode(GL_PROJECTION);
//    glLoadIdentity();
//    float zNear = 0.01;
//    float zFar = 1000;
//    GLfloat frustum = zNear * tanf(DEGREES_TO_RADIANS(fieldOfView) / 2.0);
//    glFrustumf(-frustum, frustum, -frustum/aspectRatio, frustum/aspectRatio, zNear, zFar);
//    
//    glMatrixMode(GL_MODELVIEW);
//    glLoadIdentity();
//    glViewport(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
//    
//    glEnable(GL_CULL_FACE);
//    glCullFace(GL_FRONT);
//    glEnable(GL_DEPTH_TEST);
//    
//    NSLog(@"GL VIEWPORT INIT: %f %f",[[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
//
//    
//}


-(void)setScene:(NKSceneNode *)scene {
    _scene = scene;
    scene.nkView = self;
    lastTime = CFAbsoluteTimeGetCurrent();
}


// Stop animating and release resources when they are no longer needed.
- (void)dealloc
{
	[self stopAnimation];
	
	if([EAGLContext currentContext] == context)
	{
		[EAGLContext setCurrentContext:nil];
	}
	context = nil;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

    
    for (UITouch *t in touches) {
        [_scene touchDown:P2MakeCG([t locationInView:self]) id:0];
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {

    for (UITouch *t in touches) {
        [_scene touchMoved:P2MakeCG([t locationInView:self]) id:0];
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {

    
    for (UITouch *t in touches) {
        [_scene touchUp:P2MakeCG([t locationInView:self]) id:0];
    }
    
}

@end


