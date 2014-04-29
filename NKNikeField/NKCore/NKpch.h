//
//  NKpch.h
//  NodeKittenExample
//
//  Created by Chroma Developer on 2/28/14.
//  Copyright (c) 2014 Chroma. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#else
#ifdef TARGET_OS_MAC
#import <AppKit/AppKit.h>
#endif
#endif

#ifdef __cplusplus
#define NK_EXPORT extern "C" __attribute__((visibility ("default")))
#else
#define NK_EXPORT extern __attribute__((visibility ("default")))
#endif
#define NK_AVAILABLE __OSX_AVAILABLE_STARTING

#if TARGET_OS_IPHONE
#define NK_NONATOMIC_IOSONLY nonatomic
#else
#define NK_NONATOMIC_IOSONLY atomic
#endif

#if TARGET_OS_IPHONE
#define NKColor UIColor
#define NKImage UIImage
#else
#define NKColor NSColor
#define NKImage NSImage
#endif

#define NKCLEAR [NKColor colorWithRed:0. green:0. blue:0. alpha:0.]
#define NKWHITE [NKColor colorWithRed:1. green:1. blue:1. alpha:1.]
#define NKBLACK [NKColor colorWithRed:0. green:0. blue:0. alpha:1.]

#define debugUI 0

#import "NKVectorTypes.h"
#import "NKMeshTypes.h"

