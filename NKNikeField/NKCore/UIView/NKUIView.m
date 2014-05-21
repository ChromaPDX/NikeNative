//
//  NKUIView.m
//  EMA Stage
//
//  Created by Leif Shackelford on 5/21/14.
//  Copyright (c) 2014 EMA. All rights reserved.
//

#import "NodeKitten.h"

#if NK_USE_GLES

@implementation NKUIView

#pragma mark -
#pragma mark - IOS
#pragma mark -


-(void)setScene:(NKSceneNode *)scene {
    _scene = scene;
    scene.nkView = self;
    
    w = self.bounds.size.width;
    h = self.bounds.size.height;
    wMult = w / self.bounds.size.width;
    hMult = h / self.bounds.size.height;
    
    lastTime = CFAbsoluteTimeGetCurrent();
}

-(void)drawScene {
    
    if (_scene.hitQueue.count) {
        [_scene drawToHitBuffer];
    }

    [frameBuffer bind];
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glViewport(0, 0, _scene.size.width, _scene.size.height);

    if (_scene) {
        glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
        
        //NSLog(@"draw scene");
        F1t dt = (CFAbsoluteTimeGetCurrent() - lastTime) * 1000.;
        lastTime = CFAbsoluteTimeGetCurrent();
        
        [_scene updateWithTimeSinceLast:dt];
        //[_scene drawHitBuffer];
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

+ (Class) layerClass
{
	return [CAEAGLLayer class];
}

-(instancetype)initWithFrame:(CGRect)frame {
    
    if ((self = [super initWithFrame:frame]))
    {
        [self sharedInit];
    }
    return self;
    
}

- (id) initWithCoder:(NSCoder*)coder
{
    
    if ((self = [super initWithCoder:coder]))
    {
        [self sharedInit];
    }
    
    return self;
}

-(void)sharedInit {
    // Get the layer
    CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
    
    _mscale = 1.;
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
        //[context setMultiThreaded:true];
    }
    else {
        context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
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
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(startAnimation)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
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
    NSLog(@"failed to create main ES framebuffer");
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



#endif

@end
