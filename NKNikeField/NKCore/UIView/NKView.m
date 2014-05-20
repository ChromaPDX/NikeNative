//
//  GLView.m
//  Wavefront OBJ Loader
//
//  Created by Jeff LaMarche on 12/14/08.
//  Copyright Jeff LaMarche 2008. All rights reserved.
//

#import "NodeKitten.h"

@implementation NKView

#pragma mark -
#pragma mark - SHARED METHODS
#pragma mark - 

-(void)setScene:(NKSceneNode *)scene {
    _scene = scene;
    scene.nkView = self;
    lastTime = CFAbsoluteTimeGetCurrent();
}

-(void)drawScene {
    
    if (_scene.userInteractionEnabled) {
        
        
        framesSinceLastHit++;
        if (framesSinceLastHit > drawHitEveryXFrames) {
            if (_scene) {
                [_scene drawForHitDetection];
            }
            framesSinceLastHit = 0;
        }
        
    }
    
#if TARGET_OS_IPHONE
    [frameBuffer bind];
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glViewport(0, 0, _scene.size.width, _scene.size.height);
#endif
    
    if (_scene) {
        glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
        
        
        //NSLog(@"draw scene");
        F1t dt = (CFAbsoluteTimeGetCurrent() - lastTime) * 1000.;
        lastTime = CFAbsoluteTimeGetCurrent();
        
        [_scene updateWithTimeSinceLast:dt];
        [_scene draw];
        
    }
    else {
        glClearColor(1.0f, 0.0f, 0.0f, 1.0f);
    }
    
}

// Stop animating and release resources when they are no longer needed.


-(P2t)uiPointToNodePoint:(CGPoint)p {
    P2t size = self.scene.size;
    return P2Make(p.x*2, size.height - (p.y*2));
}

#pragma mark -
#pragma mark - IOS
#pragma mark - 

#if TARGET_OS_IPHONE

+ (Class) layerClass
{
	return [CAEAGLLayer class];
}

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
        [context setMultiThreaded:true];
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
                defaultShader = [[NKShaderProgram alloc]initWithVertexSource:nkDefaultTextureVertexShader fragmentSource:nkDefaultTextureFragmentShader];
                [defaultShader load];
            }

        }
        
        [NKTextureManager sharedInstance];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(stopAnimation)
                                                     name:UIApplicationWillTerminateNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(stopAnimation)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(stopAnimation)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
        
//        [[NSNotificationCenter defaultCenter] addObserver:self
//                                                 selector:@selector(startAnimation)
//                                                     name:UIApplicationWillEnterForegroundNotification
//                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(startAnimation)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
        
    }
    
    return self;
}

-(void)layoutSubviews
{
	[EAGLContext setCurrentContext:context];
	[self destroyFramebuffer];
    NSLog(@"rebuilding framebuffer");
	[self createFramebuffer];
	[self drawView];
}

- (void)startAnimation

{
    NSLog(@"Start animating");
    if (!animating) {
        displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(drawView)];
        [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
        
        lastTime = CFAbsoluteTimeGetCurrent();
        animating = true;
    }
    
    
}

- (void)stopAnimation
{
    NSLog(@"Stop animating");
    if (animating) {
        
        [displayLink invalidate];
        animating = false;
    }
    
}

- (void)drawView
{
   	[EAGLContext setCurrentContext:context];
    
    [self drawScene];

    glBindRenderbufferOES(GL_RENDERBUFFER, frameBuffer.frameBuffer);
	[context presentRenderbuffer:GL_RENDERBUFFER];
    
    
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
        [_scene touchDown:[self uiPointToNodePoint:[t locationInView:self]] id:0];
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    for (UITouch *t in touches) {
        [_scene touchMoved:[self uiPointToNodePoint:[t locationInView:self]] id:0];
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    for (UITouch *t in touches) {
        [_scene touchUp:[self uiPointToNodePoint:[t locationInView:self]] id:0];
    }
    
}

#pragma mark - 
#pragma mark - OS X
#pragma mark -

#else
// OS X

+(void) load_
{
	NSLog(@"%@ loaded", self);
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        self = [self initWithFrame:self.frame shareContext:nil];
    }
    
    return self;
    
}

- (id) initWithFrame:(NSRect)frameRect
{
	self = [self initWithFrame:frameRect shareContext:nil];
	return self;
}

- (id) initWithFrame:(NSRect)frameRect shareContext:(NSOpenGLContext*)context
{
    NSOpenGLPixelFormatAttribute attribs[] =
    {
		NSOpenGLPFADoubleBuffer,
		NSOpenGLPFADepthSize, 24,
    };
    
	NSOpenGLPixelFormat *pixelFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes:attribs];
    
	if (!pixelFormat)
		NSLog(@"No OpenGL pixel format");
    
	if( (self = [super initWithFrame:frameRect pixelFormat:pixelFormat]) ) {
        
		if( context ){
			[self setOpenGLContext:context];
        }
        
        NSLog(@"NK GLView init %1.0f %1.0f", frameRect.size.width, frameRect.size.height);
        
	}
    
	return self;
}

- (void) update
{
	// XXX: Should I do something here ?
	[super update];
}

- (void) awakeFromNib
{
    NSOpenGLPixelFormatAttribute attrs[] =
	{
		NSOpenGLPFADoubleBuffer,
		NSOpenGLPFADepthSize, 24,
		// Must specify the 3.2 Core Profile to use OpenGL 3.2
#if ESSENTIAL_GL_PRACTICES_SUPPORT_GL3
		NSOpenGLPFAOpenGLProfile,
		NSOpenGLProfileVersion3_2Core,
#endif
		0
	};
	
	NSOpenGLPixelFormat *pf = [[NSOpenGLPixelFormat alloc] initWithAttributes:attrs];
	
	if (!pf)
	{
		NSLog(@"No OpenGL pixel format");
	}
    
    NSOpenGLContext* context = [[NSOpenGLContext alloc] initWithFormat:pf shareContext:nil];
    
#if ESSENTIAL_GL_PRACTICES_SUPPORT_GL3 && defined(DEBUG)
	// When we're using a CoreProfile context, crash if we call a legacy OpenGL function
	// This will make it much more obvious where and when such a function call is made so
	// that we can remove such calls.
	// Without this we'd simply get GL_INVALID_OPERATION error for calling legacy functions
	// but it would be more difficult to see where that function was called.
	CGLEnable([context CGLContextObj], kCGLCECrashOnRemovedFunctions);
#endif
	
    [self setPixelFormat:pf];
    
    [self setOpenGLContext:context];
    
#if SUPPORT_RETINA_RESOLUTION
    // Opt-In to Retina resolution
    [self setWantsBestResolutionOpenGLSurface:YES];
#endif // SUPPORT_RETINA_RESOLUTION
}

- (void) prepareOpenGL
{
	[super prepareOpenGL];
	
	// Make all the OpenGL calls to setup rendering
	//  and build the necessary rendering objects
	[self initGL];
	
	// Create a display link capable of being used with all active displays
	CVDisplayLinkCreateWithActiveCGDisplays(&displayLink);
	
	// Set the renderer output callback function
	CVDisplayLinkSetOutputCallback(displayLink, &MyDisplayLinkCallback, (__bridge void *)(self));
	
	// Set the display link for the current renderer
	CGLContextObj cglContext = [[self openGLContext] CGLContextObj];
	CGLPixelFormatObj cglPixelFormat = [[self pixelFormat] CGLPixelFormatObj];
	CVDisplayLinkSetCurrentCGDisplayFromOpenGLContext(displayLink, cglContext, cglPixelFormat);
	
	// Activate the display link
	CVDisplayLinkStart(displayLink);
	
	// Register to be notified when the window closes so we can stop the displaylink
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(windowWillClose:)
												 name:NSWindowWillCloseNotification
											   object:[self window]];
}

- (void) initGL
{
	// The reshape function may have changed the thread to which our OpenGL
	// context is attached before prepareOpenGL and initGL are called.  So call
	// makeCurrentContext to ensure that our OpenGL context current to this
	// thread (i.e. makeCurrentContext directs all OpenGL calls on this thread
	// to [self openGLContext])
	[[self openGLContext] makeCurrentContext];
	
	// Synchronize buffer swaps with vertical refresh rate
	GLint swapInt = 1;
	[[self openGLContext] setValues:&swapInt forParameter:NSOpenGLCPSwapInterval];
	
	// Init our renderer.  Use 0 for the defaultFBO which is appropriate for
	// OSX (but not iOS since iOS apps must create their own FBO)
	//m_renderer = [[OpenGLRenderer alloc] initWithDefaultFBO:0];
    
    frameBuffer = [[NKFrameBuffer alloc ]initWithWidth:self.frame.size.width height:self.frame.size.height];
}

- (void) reshape
{
	[super reshape];
	
	// We draw on a secondary thread through the display link. However, when
	// resizing the view, -drawRect is called on the main thread.
	// Add a mutex around to avoid the threads accessing the context
	// simultaneously when resizing.
	CGLLockContext([[self openGLContext] CGLContextObj]);
    
	// Get the view size in Points
	NSRect viewRectPoints = [self bounds];
    
#if SUPPORT_RETINA_RESOLUTION
    
    // Rendering at retina resolutions will reduce aliasing, but at the potential
    // cost of framerate and battery life due to the GPU needing to render more
    // pixels.
    
    // Any calculations the renderer does which use pixel dimentions, must be
    // in "retina" space.  [NSView convertRectToBacking] converts point sizes
    // to pixel sizes.  Thus the renderer gets the size in pixels, not points,
    // so that it can set it's viewport and perform and other pixel based
    // calculations appropriately.
    // viewRectPixels will be larger (2x) than viewRectPoints for retina displays.
    // viewRectPixels will be the same as viewRectPoints for non-retina displays
    NSRect viewRectPixels = [self convertRectToBacking:viewRectPoints];
    
#else //if !SUPPORT_RETINA_RESOLUTION
    
    // App will typically render faster and use less power rendering at
    // non-retina resolutions since the GPU needs to render less pixels.  There
    // is the cost of more aliasing, but it will be no-worse than on a Mac
    // without a retina display.
    
    // Points:Pixels is always 1:1 when not supporting retina resolutions
    NSRect viewRectPixels = viewRectPoints;
    
#endif // !SUPPORT_RETINA_RESOLUTION
    
	// Set the new dimensions in our renderer
//	[m_renderer resizeWithWidth:viewRectPixels.size.width
//                      AndHeight:viewRectPixels.size.height];
	
	CGLUnlockContext([[self openGLContext] CGLContextObj]);
}

- (CVReturn) getFrameForTime:(const CVTimeStamp*)outputTime
{
	[self drawView];
    
    return kCVReturnSuccess;
}

// This is the renderer output callback function
static CVReturn MyDisplayLinkCallback(CVDisplayLinkRef displayLink, const CVTimeStamp* now, const CVTimeStamp* outputTime, CVOptionFlags flagsIn, CVOptionFlags* flagsOut, void* displayLinkContext)
{
    CVReturn result = [(__bridge NKView*)displayLinkContext getFrameForTime:outputTime];
    return result;
}

- (void) drawRect: (NSRect) theRect
{
	// Called during resize operations
	
	// Avoid flickering during resize by drawiing
	[self drawView];
}

- (void) drawView
{
	[[self openGLContext] makeCurrentContext];
    
	// We draw on a secondary thread through the display link
	// When resizing the view, -reshape is called automatically on the main
	// thread. Add a mutex around to avoid the threads accessing the context
	// simultaneously when resizing
	CGLLockContext([[self openGLContext] CGLContextObj]);
    
    glBindFramebufferEXT(GL_FRAMEBUFFER, 0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    [self drawScene];
	//[m_renderer render];
    
	CGLFlushDrawable([[self openGLContext] CGLContextObj]);
	CGLUnlockContext([[self openGLContext] CGLContextObj]);
}


-(void) dealloc
{
	if( displayLink ) {
		CVDisplayLinkStop(displayLink);
		CVDisplayLinkRelease(displayLink);
	}
}

////
//// Mac Director has its own thread
////
//-(void) mainLoop
//{
//	while( ![[NSThread currentThread] isCancelled] ) {
//		// There is no autorelease pool when this method is called because it will be called from a background thread
//		// It's important to create one or you will leak objects
//		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
//        
//		[[NSRunLoop currentRunLoop] run];
//        
//		[pool release];
//	}
//}



//// set the event dispatcher
//-(void) setView:(NKView *)view
//{
//	[super setView:view];
//    
//	// Enable Touches. Default no.
//	// Only available on OS X 10.6+
//#if MAC_OS_X_VERSION_MIN_REQUIRED > MAC_OS_X_VERSION_10_5
//	[view setAcceptsTouchEvents:NO];
//    //		[view setAcceptsTouchEvents:YES];
//#endif
//    
//	// Synchronize buffer swaps with vertical refresh rate
//	[[view openGLContext] makeCurrentContext];
//	GLint swapInt = 1;
//	[[view openGLContext] setValues:&swapInt forParameter:NSOpenGLCPSwapInterval];
//}



- (void)mouseDown:(NSEvent *)theEvent
{
	[_scene touchDown:P2Make(theEvent.absoluteX, theEvent.absoluteY) id:0];
}

- (void)mouseMoved:(NSEvent *)theEvent
{
	[_scene touchMoved:P2Make(theEvent.absoluteX, theEvent.absoluteY) id:0];
}

- (void)mouseDragged:(NSEvent *)theEvent
{
	[_scene touchMoved:P2Make(theEvent.absoluteX, theEvent.absoluteY) id:0];
}

- (void)mouseUp:(NSEvent *)theEvent
{
	[_scene touchUp:P2Make(theEvent.absoluteX, theEvent.absoluteY) id:0];
}

#endif


@end


