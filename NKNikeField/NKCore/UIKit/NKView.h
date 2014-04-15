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

#define GLESVERSION 1

@class NKViewController;
@class NKSceneNode;

@interface NKView : UIView
{
	EAGLContext *context;
    
	GLuint frameBuffer, colorRenderbuffer,depthRenderbuffer;
    GLint bufferWidth, bufferHeight;

    GLuint _vertexArray;
    GLuint _vertexBuffer;
    
	NSTimer *animationTimer;
    NSTimeInterval lastTime;
	BOOL controllerSetup;
    
    
    // 2.0 stuff
    
    GLuint _positionSlot;
    GLuint _colorSlot;

}

@property (nonatomic, weak) NKViewController *controller;
@property (nonatomic, strong) NKSceneNode *scene;

@property (nonatomic) NSTimeInterval animationInterval;

-(void)startAnimation;
-(void)stopAnimation;
-(void)drawView;

- (id)initGLES;
- (BOOL)createFramebuffer;
- (void)destroyFramebuffer;

@end
