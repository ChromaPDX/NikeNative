//
//  BoardLocation.m
//  CardDeck
//
//  Created by Robby Kraft on 9/20/13.
//  Copyright (c) 2013 Robby Kraft. All rights reserved.
//

#import "BoardLocation.h"
#import "Manager.h"
#import "AStar.h"

@implementation BoardLocation

-(id)initWithX:(NSInteger)x Y:(NSInteger)y{
    self = [super init];
    if(self){
        [self setX:x];
        [self setY:y];
    }
    return self;
}

+(instancetype)pointWithCGPoint:(CGPoint)point {
    return [[BoardLocation alloc] initWithX:point.x Y:point.y];
}

+(instancetype)pX:(int)x Y:(int)y{
    return [[BoardLocation alloc] initWithX:x Y:y];
}

-(CGPoint)CGPoint {
    return CGPointMake(_x, _y);
}

-(BOOL)isEqual:(id)other {
    if (_x == [(BoardLocation*)other x] && _y == [(BoardLocation*)other y]) {
        return 1;
    }
    return 0;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"BoardLocation: X:%d Y:%d",_x,_y];
}

-(NSUInteger) hash;{
    return 1;
}

-(instancetype)copy {
    return [BoardLocation pX:self.x Y:self.y];
}

- (id)copyWithZone:(NSZone *)zone{
    id copy = [[[self class] allocWithZone:zone] init];
    [copy setX:[self x]];
    [copy setY:[self y]];
    return copy;
}

- (id)initWithCoder:(NSCoder *)decoder {
    
    self = [super init];
    
    if (!self) {
        return nil;
    }
    
    _x = [decoder decodeIntegerForKey:@"_x"];
    _y = [decoder decodeIntegerForKey:@"_y"];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    
    [encoder encodeInteger:_x forKey:@"_x"];
    [encoder encodeInteger:_y forKey:@"_y"];
    
}

-(void) setBorderShapeInContext:(NSArray *)arrayOfLocations{
    
    bool left =  ![arrayOfLocations containsObject:[BoardLocation pX:_x-1 Y:_y]];
    bool right = ![arrayOfLocations containsObject:[BoardLocation pX:_x+1 Y:_y]];
    bool above = ![arrayOfLocations containsObject:[BoardLocation pX:_x Y:_y+1]];
    bool below = ![arrayOfLocations containsObject:[BoardLocation pX:_x Y:_y-1]];
    
    if(!above && !right && !below && !left) _borderShape = BorderMaskNone;
    if( above && !right && !below && !left) _borderShape = BorderMaskTop;
    if(!above &&  right && !below && !left) _borderShape = BorderMaskRight;
    if( above &&  right && !below && !left) _borderShape = BorderMaskTopRight;
    if(!above && !right &&  below && !left) _borderShape = BorderMaskBottom;
    if( above && !right &&  below && !left) _borderShape = BorderMaskHorizontal;
    if(!above &&  right &&  below && !left) _borderShape = BorderMaskBottomRight;
    if( above &&  right &&  below && !left) _borderShape = BorderMask3Right;
    if(!above && !right && !below &&  left) _borderShape = BorderMaskLeft;
    if( above && !right && !below &&  left) _borderShape = BorderMaskTopLeft;
    if(!above &&  right && !below &&  left) _borderShape = BorderMaskVertical;
    if( above &&  right && !below &&  left) _borderShape = BorderMask3Top;
    if(!above && !right &&  below &&  left) _borderShape = BorderMaskBottomLeft;
    if( above && !right &&  below &&  left) _borderShape = BorderMask3Left;
    if(!above &&  right &&  below &&  left) _borderShape = BorderMask3Bottom;
    if( above &&  right &&  below &&  left) _borderShape = BorderMaskAll;
    
    
}

-(int)distanceToGoalForManager:(Manager*)m neighborhoodType:(int)type{
    AStar *aStar = [[AStar alloc]initWithColumns:7 Rows:10 ObstaclesCells:nil];
    
    return [aStar pathFromAtoB:self B:m.goal NeighborhoodType:type].count;
    
}

-(int)isAdjacentTo:(BoardLocation*)b {
    if ([self isEqual:b]) {
        return -1;
    }
    else if (_x == b.x) { // SAME ROW
        if (abs(_y - b.y) == 1) { // Column neighbor
            return 1;
        }
    }
    else if (_y == b.y) { // SAME COLUMN
        if (abs(_x - b.x) == 1) { // ROW NEIGHBOR
            return 1;
        }
    }
    return 0;
}

+(NSArray*)tileSetIntersect:(NSArray*)tileSetA withTileSet:(NSArray*)tileSetB{
    NSMutableArray *retPath;
    for(BoardLocation *locA in tileSetA){
        for(BoardLocation *locB in tileSetB){
            if([locA isEqual:locB]){
                [retPath addObject:locA];
            }
        }
    }
    return retPath;
}






@end
