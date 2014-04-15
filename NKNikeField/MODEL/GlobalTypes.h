//
//  GlobalTypes.h
//  NSFW-bench
//
//  Created by Chroma Developer on 1/14/14.
//  Copyright (c) 2014 Chroma Developer. All rights reserved.
//

//#define OF_BACKED

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

#define TILE_WIDTH 96
#define TILE_HEIGHT 116


// ANIMATION

#define FAST_ANIM_DUR .2
#define CAM_SPEED 1.
#define CARD_ANIM_DUR .3

// UI COLORS - FROM V2 NON NORMALIZED

//#define V2RED [NKColor colorWithRed:224./255. green:82./255. blue:98./255. alpha:1.]
//#define V2BLUE [NKColor colorWithRed:13./255. green:107./255. blue:209./255. alpha:1.]
//#define V2GREEN [NKColor colorWithRed:0./255. green:168./255. blue:171./255. alpha:1.]
//#define V2YELLOW [NKColor colorWithRed:231./255. green:174./255. blue:31./255. alpha:1.]
//#define V2ORANGE [NKColor colorWithRed:247./255. green:138./255. blue:37./255. alpha:1.]
//#define V2PURPLE [NKColor colorWithRed:138./255. green:85./255. blue:255./255. alpha:1.]
//#define V2MAGENTA [NKColor colorWithRed:184./255. green:39./255. blue:244./255. alpha:1.]

// NORMALIZED

#define V2RED [NKColor colorWithRed:255./255. green:95./255. blue:111./255. alpha:1.]
#define V2BLUE [NKColor colorWithRed:15./255. green:128./255. blue:255./255. alpha:1.]
#define V2GREEN [NKColor colorWithRed:0./255. green:247./255. blue:255./255. alpha:1.]
#define V2YELLOW [NKColor colorWithRed:255./255. green:197./255. blue:33./255. alpha:1.]
#define V2ORANGE [NKColor colorWithRed:255./255. green:144./255. blue:38./255. alpha:1.]
#define V2PURPLE [NKColor colorWithRed:138./255. green:85./255. blue:255./255. alpha:1.]
#define V2MAGENTA [NKColor colorWithRed:191./255. green:41./255. blue:244./255. alpha:1.]

#define MOVE_CAMERA 1
#define BALL_SCALE_BIG .5
#define BALL_SCALE_SMALL .25

#define debugUI 1

#ifdef debugUI
#define UILog NSLog
#else
#define UILog //
#endif



#endif
