//
//  NKMacro.h
//  EMA Stage
//
//  Created by Leif Shackelford on 5/25/14.
//  Copyright (c) 2014 EMA. All rights reserved.
//

// USER MACROS

//** FOR GL RELATED LOGS
#define NK_GL_DEBUG 0
//**

//** LOG / PRINT TIME METRICS
#define NK_LOG_METRICS 1
//**

// SCENE DEBUG

#define DRAW_HIT_BUFFER 0

// SPRITES
#if NK_USE_GLES
#define NK_BATCH_SIZE 16
#else
#define NK_BATCH_SIZE 64
#endif

// SYSTEM MACROS

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

#define NK_USE_GL3

#define NKColor NSColor
#define NKImage NSImage
#define NKFont  NSFont
#define NKDisplayLink CVDisplayLinkRef

#define NK_NONATOMIC_IOSONLY atomic

#endif

#if NK_USE_GLES

#import <OpenGLES/EAGL.h>


#ifdef NK_USE_GL3
#import <OpenGLES/ES3/gl.h>
#import <OpenGLES/ES3/glext.h>
#else
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#endif

#else

#import <OpenGL/OpenGL.h>

#ifdef NK_USE_GL3
#import <OpenGl/gl3.h>
#import <OpenGl/gl3ext.h>
#else
#define NK_USE_ARB_EXT
#import <OpenGl/gl.h>
#import <OpenGL/glext.h>
#endif

#endif