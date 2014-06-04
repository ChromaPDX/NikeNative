//
//  GlobalTypes.h
//  NSFW-bench
//
//  Created by Chroma Developer on 1/14/14.
//  Copyright (c) 2014 Chroma Developer. All rights reserved.
//

//#define OF_BACKED

#import "NKpch.h"

#ifndef NSFW_bench_GlobalTypes_h
#define NSFW_bench_GlobalTypes_h

#ifndef SKColor
#define SKColor UIColor
#endif

#ifndef NKColor
#define NKColor UIColor
#endif

// BOARD + GEOMETRY


#define BOARD_WIDTH 7
#define BOARD_LENGTH 10

static int TILE_WIDTH = 96;
static int TILE_HEIGHT = 116;
//#define TILE_WIDTH 96
//#define TILE_HEIGHT 116


// ANIMATION

#define FAST_ANIM_DUR .2
#define CAM_SPEED 1.
#define CARD_ANIM_DUR .2

// UI COLORS - FROM V2 NON NORMALIZED

//#define V2RED [NKColor colorWithRed:224./255. green:82./255. blue:98./255. alpha:1.]
//#define V2BLUE [NKColor colorWithRed:13./255. green:107./255. blue:209./255. alpha:1.]
//#define V2GREEN [NKColor colorWithRed:0./255. green:168./255. blue:171./255. alpha:1.]
//#define V2YELLOW [NKColor colorWithRed:231./255. green:174./255. blue:31./255. alpha:1.]
//#define V2ORANGE [NKColor colorWithRed:247./255. green:138./255. blue:37./255. alpha:1.]
//#define V2PURPLE [NKColor colorWithRed:138./255. green:85./255. blue:255./255. alpha:1.]
//#define V2MAGENTA [NKColor colorWithRed:184./255. green:39./255. blue:244./255. alpha:1.]

// NORMALIZED

//#define V2RED [NKColor colorWithRed:255./255. green:95./255. blue:111./255. alpha:1.]
//#define V2BLUE [NKColor colorWithRed:15./255. green:128./255. blue:255./255. alpha:1.]
//#define V2GREEN [NKColor colorWithRed:0./255. green:247./255. blue:255./255. alpha:1.]
//#define V2YELLOW [NKColor colorWithRed:255./255. green:197./255. blue:33./255. alpha:1.]
//#define V2ORANGE [NKColor colorWithRed:255./255. green:144./255. blue:38./255. alpha:1.]
//#define V2PURPLE [NKColor colorWithRed:138./255. green:85./255. blue:255./255. alpha:1.]
//#define V2MAGENTA [NKColor colorWithRed:191./255. green:41./255. blue:244./255. alpha:1.]

// BYTES

#define V2RED [NKByteColor colorWithRed:255 green:95 blue:111 alpha:255]
#define V2BLUE [NKByteColor colorWithRed:15 green:128 blue:255 alpha:255]
#define V2GREEN [NKByteColor colorWithRed:0 green:247 blue:255 alpha:255]
#define V2YELLOW [NKByteColor colorWithRed:255 green:197 blue:33 alpha:255]
#define V2ORANGE [NKByteColor colorWithRed:255 green:144 blue:38 alpha:255]
#define V2PURPLE [NKByteColor colorWithRed:138 green:85 blue:255 alpha:255]
#define V2MAGENTA [NKByteColor colorWithRed:191 green:41 blue:244 alpha:255]

#define MOVE_CAMERA 1
#define BALL_SCALE_BIG .5
#define BALL_SCALE_SMALL .25

#define DEFAULT_START_ENERGY 1000
#define SUCCUBUS_SELF_ENERGY 150
#define SUCCUBUS_OPPONENT_ENERGY 100


//#define debugUI 1

#ifdef debugUI
#define UILog NSLog
#else
#define UILog //
#endif



#endif
