//
//  BoardLocation.h
//  CardDeck
//
//  Created by Robby Kraft on 9/20/13.
//  Copyright (c) 2013 Robby Kraft. All rights reserved.
//

#import <Foundation/Foundation.h>

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

@interface BoardLocation : NSObject <NSCopying, NSCoding>
{

}
@property NSInteger x;
@property NSInteger y;
@property BorderMask borderShape;

+(instancetype)pX:(int)x Y:(int)y;
+(instancetype)pointWithCGPoint:(CGPoint)point;
-(id)initWithX:(NSInteger)x Y:(NSInteger)y;
-(CGPoint)CGPoint;
-(BOOL)isEqual:(BoardLocation*)point;
-(int)isAdjacentTo:(BoardLocation*)b;
-(void)setBorderShapeInContext:(NSArray*)arrayOfLocations;
+(NSArray*)tileSetIntersect:(NSArray*)tileSetA withTileSet:(NSArray*)tileSetB;

-(int)distanceToGoalForManager:(Manager*)m neighborhoodType:(int)type;
@end
