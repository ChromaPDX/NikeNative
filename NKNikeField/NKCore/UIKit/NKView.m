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
    0.5f, 0.5f, -0.5f,          1.0f, 0.0f, 0.0f,
    0.5f, 0.5f, 0.5f,         1.0f, 0.0f, 0.0f,
    
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
////        self.scene = [[DevMenu alloc]initWithSize:CGSizeMake(self.frame.size.width*2., self.frame.size.height*2.)];
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
        
        if(!context || ![EAGLContext setCurrentContext:context] || ![self createFramebuffer] || ![self attachDepthBuffer]){
            
        }
        else {
            NSLog(@"GLES Context && Frame Buffer loaded!");
          
            
            if (NK_GL_VERSION == 2) {
                [self setupVBOs];
                [self loadShaders];
     
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
	[self createFramebuffer];
	[self drawView];
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

- (BOOL)createFramebuffer
{
    
    // 1 // Create the framebuffer and bind it.
    
    glGenFramebuffers(1, &frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);
    
    // 2 // Create a color renderbuffer, allocate storage for it, and attach it to the framebuffer’s color attachment point.
    
    glGenRenderbuffers(1, &colorRenderbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
    //glRenderbufferStorage(GL_RENDERBUFFER, GL_RGBA8, bufferWidth, bufferHeight);
    [context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(id<EAGLDrawable>)self.layer];
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &bufferWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &bufferHeight);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, colorRenderbuffer);
    
    // 3 // Create a depth or depth/stencil renderbuffer, allocate storage for it, and attach it to the framebuffer’s depth attachment point.
    
    glGenRenderbuffers(1, &depthRenderbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, depthRenderbuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, bufferWidth, bufferHeight);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthRenderbuffer);
    
    // 4 // Test the framebuffer for completeness. This test only needs to be performed when the framebuffer’s configuration changes.
    
    GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER) ;
    if(status != GL_FRAMEBUFFER_COMPLETE) {
        NSLog(@"failed to make complete framebuffer object %x", status);
        return false;
    }
    return true;
}

-(BOOL)attachDepthBuffer {
    return true;
}

typedef struct {
    float Position[3];
    float Color[4];
} Vertex;

static const Vertex Vertices[] = {
    {{1, -1, 0}, {1, 0, 0, 1}},
    {{1, 1, 0}, {0, 1, 0, 1}},
    {{-1, 1, 0}, {0, 0, 1, 1}},
    {{-1, -1, 0}, {0, 0, 0, 1}}
};

static const GLubyte Indices[] = {
    0, 1, 2,
    2, 3, 0
};

- (void)setupVBOs {
    
    GLuint vertexBuffer;
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(Vertices), Vertices, GL_STATIC_DRAW);
    
    GLuint indexBuffer;
    glGenBuffers(1, &indexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(Indices), Indices, GL_STATIC_DRAW);
    
//    glGenVertexArraysOES(1, &_vertexArray);
//    glBindVertexArrayOES(_vertexArray);
//    
//    glGenBuffers(1, &_vertexBuffer);
//    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
//    glBufferData(GL_ARRAY_BUFFER, sizeof(gCubeVertexData), gCubeVertexData, GL_STATIC_DRAW);
    
//    glEnableVertexAttribArray(_positionSlot);
//    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(0));
//    glEnableVertexAttribArray(_normalSlot);
//    glVertexAttribPointer(_normalSlot, 3, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(12));
//    
//    glBindVertexArrayOES(0);
    
}

// Clean up any buffers we have allocated.
- (void)destroyFramebuffer
{
	glDeleteFramebuffersOES(1, &frameBuffer);
	//viewFramebuffer = 0;
	glDeleteRenderbuffersOES(1, &colorRenderbuffer);
	//viewRenderbuffer = 0;
	
	if(depthRenderbuffer)
	{
		glDeleteRenderbuffersOES(1, &depthRenderbuffer);
		depthRenderbuffer = 0;
	}
}

- (void)startAnimation

{
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(drawView)];
    [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    
//	animationTimer = [NSTimer scheduledTimerWithTimeInterval:_animationInterval target:self selector:@selector(drawView) userInfo:nil repeats:YES];
//    NSLog(@"start draw, %1.0f fps", 1. / _animationInterval);
    lastTime = CFAbsoluteTimeGetCurrent();
}

- (void)stopAnimation
{
//	[animationTimer invalidate];
//	animationTimer = nil;
}

//- (void)setAnimationInterval:(NSTimeInterval)interval
//{
//	_animationInterval = interval;
//	
//	if(animationTimer)
//	{
//		[self stopAnimation];
//		[self startAnimation];
//	}
//}

#pragma mark -  OpenGL ES 2 shader compilation

- (BOOL)loadShaders
{
    GLuint vertShader, fragShader;

    // Create shader program.
    _program = glCreateProgram();
    
//    // Create and compile vertex shader.
//    vertShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"vsh"];
//    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname]) {
//        NSLog(@"Failed to compile vertex shader");
//        return NO;
//    }
//    
//    // Create and compile fragment shader.
//    fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"fsh"];
//    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname]) {
//        NSLog(@"Failed to compile fragment shader");
//        return NO;
//    }
    
    vertShader = [self compileShaderSource:nkDefaultTextureVertexShader withType:GL_VERTEX_SHADER];
    fragShader = [self compileShaderSource:nkDefaultTextureFragmentShader withType:GL_FRAGMENT_SHADER];
    
    // Attach vertex shader to program.
    glAttachShader(_program, vertShader);
    
    // Attach fragment shader to program.
    glAttachShader(_program, fragShader);
    
    // Bind attribute locations.
    
    // Get attribute
//    _positionSlot = glGetAttribLocation(_program, "position");
//    _normalSlot = glGetAttribLocation(_program, "normal");
    
    _positionSlot = ATTRIB_POSITION;
    _normalSlot = ATTRIB_NORMAL;
    _colorSlot = ATTRIB_COLOR;
    
    NSLog(@"position slot %d", _positionSlot);
    NSLog(@"normal slot %d", _normalSlot);
    NSLog(@"color slot %d", _colorSlot);
    
    glEnableVertexAttribArray(_positionSlot);
    glEnableVertexAttribArray(_colorSlot);

    // This needs to be done prior to linking.
    glBindAttribLocation(_program, _positionSlot, "position");
    glBindAttribLocation(_program, _normalSlot, "normal");
    glBindAttribLocation(_program, _colorSlot, "color");
    
    
    // Link program.
    if (![self linkProgram:_program]) {
        NSLog(@"Failed to link program: %d", _program);
        
        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (_program) {
            glDeleteProgram(_program);
            _program = 0;
        }
        
        return NO;
    }
    else {
        NSLog(@"Program Successfully linked");
    }
    

    
    // Get uniform locations.
    uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(_program, "modelViewProjectionMatrix");
    uniforms[UNIFORM_NORMAL_MATRIX] = glGetUniformLocation(_program, "normalMatrix");
    
    // Release vertex and fragment shaders.
    if (vertShader) {
        glDetachShader(_program, vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader) {
        glDetachShader(_program, fragShader);
        glDeleteShader(fragShader);
    }
    
    return YES;
}

- (BOOL)linkProgram:(GLuint)prog
{
    GLint status;
    glLinkProgram(prog);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

- (BOOL)validateProgram:(GLuint)prog
{
    GLint logLength, status;
    
    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}


-(GLuint)compileShaderSource:(NSString*)shaderSource withType:(GLenum)shaderType {
    
    // 2
    GLuint shaderHandle = glCreateShader(shaderType);
    
    // 3
    const char * shaderStringUTF8 = [shaderSource UTF8String];
    int shaderStringLength = [shaderSource length];
    glShaderSource(shaderHandle, 1, &shaderStringUTF8, &shaderStringLength);
    
    // 4
    glCompileShader(shaderHandle);
    
    // 5
    GLint compileSuccess;
    glGetShaderiv(shaderHandle, GL_COMPILE_STATUS, &compileSuccess);
    if (compileSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetShaderInfoLog(shaderHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        exit(1);
    }
    
    return shaderHandle;
    
}

-(GLuint)compileShader:(NSString*)shaderName withType:(GLenum)shaderType {
    
    // 1
    NSString* shaderPath = [[NSBundle mainBundle] pathForResource:shaderName
                                                           ofType:@"glsl"];
    NSError* error;
    NSString* shaderString = [NSString stringWithContentsOfFile:shaderPath
                                                       encoding:NSUTF8StringEncoding error:&error];
    if (!shaderString) {
        NSLog(@"Error loading shader: %@", error.localizedDescription);
        exit(1);
    }
    
    return [self compileShaderSource:shaderString withType:shaderType];
    
}

static const GLfloat XAxis[] = {-1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f};
static const GLfloat YAxis[] = {0.0f, -1.0f, 0.0f, 0.0f, 1.0f, 0.0f};
static const GLfloat ZAxis[] = {0.0f, 0.0f, -1.0f, 0.0f, 0.0f, 1.0f};

// Updates the OpenGL view when the timer fires
- (void)drawView
{
	// Make sure that you are drawing to the current context
	[EAGLContext setCurrentContext:context];
    
	glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    glClearColor(0.0f, 0.2f, 0.2f, 1.0f);
    
    if (NK_GL_VERSION == 2) {
        
        _modelViewProjectionMatrix = M16MakeRotate(Q4FromV3(V3Make(0, sinf(lastTime)*20., 0)));
        //M16SetV3Translation(&_modelViewProjectionMatrix, V3Make(.5, .5, .5));
        _normalMatrix = M16IdentityMake();
        
        glUseProgram(_program);
        
        glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, _modelViewProjectionMatrix.m);
        //glUniformMatrix3fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, _normalMatrix.m);
        
        // 1
        glViewport(0, 0, self.frame.size.width, self.frame.size.height);
        
        // 2
        
        glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE,
                              sizeof(Vertex), 0);
        glVertexAttribPointer(_colorSlot, 4, GL_FLOAT, GL_FALSE,
                              sizeof(Vertex), (GLvoid*) (sizeof(float) * 3));
        
        // 3
        
      //  glDrawArrays(GL_TRIANGLES, 0, 36);
        
        glDrawElements(GL_TRIANGLES, sizeof(Indices)/sizeof(Indices[0]),
                       GL_UNSIGNED_BYTE, 0);
        
    }
    
    if (_scene) {
        
        F1t dt = (CFAbsoluteTimeGetCurrent() - lastTime) * 1000.;
        lastTime = CFAbsoluteTimeGetCurrent();
       // NSLog(@"frame time: %f1.0",dt);
        [_scene updateWithTimeSinceLast:dt];
        [_scene draw];
        
        
    }
    
    else {
        
        glPushMatrix();
        
        //glViewport(0, 0, self.frame.size.width, self.frame.size.height);
        
        //NSLog(@"rot : %f", DEGREES_TO_RADIANS(rot));
        
        glColor4f(1.0, 1.0, 1.0, 1.0);
        
        glEnableClientState(GL_VERTEX_ARRAY);
        
        glLineWidth(2.0);
        glColor4f(1.0, 1.0, 1.0, 1.0);
        glVertexPointer(3, GL_FLOAT, 0, XAxis);
        glDrawArrays(GL_LINE_LOOP, 0, 2);
        glVertexPointer(3, GL_FLOAT, 0, YAxis);
        glDrawArrays(GL_LINE_LOOP, 0, 2);
        glVertexPointer(3, GL_FLOAT, 0, ZAxis);
        glDrawArrays(GL_LINE_LOOP, 0, 2);
        
        glDisableClientState(GL_VERTEX_ARRAY);
        
        glPopMatrix();
    }

	
	glBindRenderbufferOES(GL_RENDERBUFFER, colorRenderbuffer);
	[context presentRenderbuffer:GL_RENDERBUFFER];
	
	//GLenum err = glGetError();
    //	if(err)
    //		NSLog(@"%x error", err);
    
}

-(void)initViewPort{
    
    float fieldOfView = 25;
    float aspectRatio = (float)[[UIScreen mainScreen] bounds].size.width / (float)[[UIScreen mainScreen] bounds].size.height;
    if([UIApplication sharedApplication].statusBarOrientation > 2)
        aspectRatio = 1/aspectRatio;
    
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    float zNear = 0.01;
    float zFar = 1000;
    GLfloat frustum = zNear * tanf(DEGREES_TO_RADIANS(fieldOfView) / 2.0);
    glFrustumf(-frustum, frustum, -frustum/aspectRatio, frustum/aspectRatio, zNear, zFar);
    
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    glViewport(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
    
    glEnable(GL_CULL_FACE);
    glCullFace(GL_FRONT);
    glEnable(GL_DEPTH_TEST);
    
    NSLog(@"GL VIEWPORT INIT: %f %f",[[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);

    
}


-(void)setScene:(NKSceneNode *)scene {
    _scene = scene;
    scene.nkView = self;
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
        [_scene touchDown:[t locationInView:self] id:0];
    }
    
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *t in touches) {
        [_scene touchMoved:[t locationInView:self] id:0];
    }
    
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *t in touches) {
        [_scene touchUp:[t locationInView:self] id:0];
    }
    
}

@end


