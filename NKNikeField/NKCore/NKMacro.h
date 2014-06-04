//
//  NKMacro.h
//  EMA Stage
//
//  Created by Leif Shackelford on 5/25/14.
//  Copyright (c) 2014 EMA. All rights reserved.
//

#if defined(__ARM_NEON__)
#import <arm_neon.h>
#endif


#if TARGET_OS_IPHONE

#import <UIKit/UIKit.h>

#define NKColor UIColor
#define NKImage UIImage
#define NKFont  UIFont
#define NKDisplayLink CADisplayLink *
#define NK_NONATOMIC_IOSONLY nonatomic

#else // TARGET DESKTOP

#import <AppKit/AppKit.h>

#define NKColor NSColor
#define NKImage NSImage
#define NKFont  NSFont
#define NKDisplayLink CVDisplayLinkRef

#define NK_NONATOMIC_IOSONLY atomic

#endif

#if NK_USE_GLES

#import <OpenGLES/EAGL.h>

#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

//#import <OpenGLES/ES3/gl.h>
//#import <OpenGLES/ES3/glext.h>

#else

#import <OpenGL/OpenGL.h>

#import <OpenGl/gl.h>
#import <OpenGL/glext.h>

//#import <OpenGl/gl3.h>
//#import <OpenGl/gl3ext.h>

//#import <OpenGl/gl3.h>
//#import <OpenGl/gl3ext.h>

#endif

#define NK_GL_DEBUG

// SCENE DEBUG
//#define DRAW_HIT_BUFFER

// SPRITES
#if NK_USE_GLES
#define NK_BATCH_SIZE 16
#else
#define NK_BATCH_SIZE 64
#endif
