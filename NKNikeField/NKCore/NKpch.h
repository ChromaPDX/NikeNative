//
//  NKpch.h
//  NodeKittenExample
//
//  Created by Chroma Developer on 2/28/14.
//  Copyright (c) 2014 Chroma. All rights reserved.
//

#ifdef __cplusplus
#define NK_EXPORT extern "C" __attribute__((visibility ("default")))
#else
#define NK_EXPORT extern __attribute__((visibility ("default")))
#endif
#define NK_AVAILABLE __OSX_AVAILABLE_STARTING

#import "NKVectorTypes.h"
#import "NKMath.h"
#import "NKMeshTypes.h"

#define NKWHITE [NKByteColor colorWithRed:255 green:255 blue:255 alpha:255]
#define NKRED [NKByteColor colorWithRed:255 green:0 blue:0. alpha:255]
#define NKGREEN [NKByteColor colorWithRed:0 green:255 blue:0 alpha:255]
#define NKBLUE [NKByteColor colorWithRed:0 green:0. blue:255 alpha:255]
#define NKBLACK [NKByteColor colorWithRed:0 green:0 blue:0 alpha:255]
#define NKCLEAR [NKByteColor colorWithRed:0 green:0 blue:0 alpha:0]

#define debugUI 0
#define NK_GL_VERSION 2