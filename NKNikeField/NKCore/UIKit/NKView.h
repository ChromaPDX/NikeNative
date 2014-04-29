//
//  GLView.h
//  Wavefront OBJ Loader
//
//  Created by Jeff LaMarche on 12/14/08.
//  Copyright Jeff LaMarche 2008. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

#define NK_GL_VERSION 2

@class NKViewController;
@class NKSceneNode;

// Uniform index.
enum
{
    UNIFORM_MODELVIEWPROJECTION_MATRIX,
    UNIFORM_NORMAL_MATRIX,
    NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];

// Attribute index.
enum
{
    ATTRIB_POSITION,
    ATTRIB_NORMAL,
    ATTRIB_COLOR,
    ATTRIB_TEX_COORD_0,
    ATTRIB_TEX_COORD_1,
    NUM_ATTRIBUTES
};

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

@interface NKView : UIView
{
	EAGLContext *context;
    
	GLuint frameBuffer, colorRenderbuffer,depthRenderbuffer;
    GLint bufferWidth, bufferHeight;


    
	NSTimer *animationTimer;
    NSTimeInterval lastTime;
	BOOL controllerSetup;
    
    
    // 2.0 stuff
    GLuint _program;
    
    M16t _modelViewProjectionMatrix;
    M16t _normalMatrix;
    float _rotation;
    
    GLuint _vertexArray;
    GLuint _vertexBuffer;
    
    GLuint _positionSlot;
    GLuint _normalSlot;
    GLuint _colorSlot;

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


