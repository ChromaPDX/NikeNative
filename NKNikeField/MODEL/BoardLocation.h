//
//  BoardLocation.h
//  CardDeck
//
//  Created by Robby Kraft on 9/20/13.
//  Copyright (c) 2013 Robby Kraft. All rights reserved.
//

#import "NKPch.h"

@class Manager;

typedef NS_OPTIONS(UInt16, BorderMask) {
    
    BorderMaskNone = 0,
    
    BorderMaskLeft = 1 << 0,
    BorderMaskRight = 1 << 1,
    BorderMaskTop = 1 << 2,
    BorderMaskBottom = 1 << 3,
    
    BorderMaskTopRight = BorderMaskTop | BorderMaskRight,
    BorderMaskTopLeft = BorderMaskTop | BorderMaskLeft,
    BorderMaskBottomRight = BorderMaskBottom | BorderMaskRight,
    BorderMaskBottomLeft = BorderMaskBottom | BorderMaskLeft,
    
    BorderMaskVertical = BorderMaskLeft | BorderMaskRight,
    BorderMaskHorizontal = BorderMaskTop | BorderMaskBottom,
    
    BorderMask3Top = BorderMaskLeft | BorderMaskTop | BorderMaskRight,
    BorderMask3Bottom = BorderMaskLeft | BorderMaskBottom | BorderMaskRight,
    BorderMask3Left = BorderMaskLeft | BorderMaskBottom | BorderMaskTop,
    BorderMask3Right = BorderMaskRight | BorderMaskBottom | BorderMaskTop,

    BorderMaskAll = BorderMaskLeft | BorderMaskRight | BorderMaskBottom | BorderMaskTop,
    
};

typedef NS_ENUM(int32_t, Direction) {
    NORTH = 0,
    NORTHEAST = 1,
    EAST = 2,
    SOUTHEAST = 3,
    SOUTH = 4,
    SOUTHWEST = 5,
    WEST = 6,
    NORTHWEST = 7
};


@interface BoardLocation : NSObject <NSCopying, NSCoding>
{

}

@property float x;
@property float y;
@property BorderMask borderShape;

+(instancetype)pX:(float)x Y:(float)y;
+(instancetype)pointWithP2:(P2t)point;
-(id)initWithX:(float)x Y:(float)y;
-(BOOL)isEqual:(BoardLocation*)point;
-(int)isAdjacentTo:(BoardLocation*)b;
-(void)setBorderShapeInContext:(NSArray*)arrayOfLocations;
+(NSArray*)tileSetIntersect:(NSArray*)tileSetA withTileSet:(NSArray*)tileSetB;
//-(BoardLocation*)stepInDirection:(Direction)direction;

-(int)distanceToGoalForManager:(Manager*)m neighborhoodType:(int)type;
-(float)distanceBetweenLocations:(BoardLocation*)l;
-(BoardLocation*)transformOriginFromLowerLeftToCenter;

@end
