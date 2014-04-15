//
//  AStar.h
//  Squares
//
//  Created by Robby Kraft on 2/21/14.
//  Copyright (c) 2014 Robby Kraft. All rights reserved.
//

typedef NS_ENUM(int, NeighborhoodType){
    NeighborhoodTypeVonNeumann = 0,
    NeighborhoodTypeRook = 0,
    NeighborhoodTypeMoore = 1,
    NeighborhoodTypeQueen = 1,
};

#import "BoardLocation.h"

@interface AStar : NSObject

-(id) initWithColumns:(int)columns Rows:(int)rows ObstaclesCells:(NSArray*)obstacleCells;
-(void) updateObstacleCells:(NSArray*)obstacleCells;

-(NSArray*) pathFromAtoB:(BoardLocation*)start B:(BoardLocation*)finish NeighborhoodType:(NeighborhoodType)NEIGHBORHOOD_TYPE;

-(NSArray*) cellsAccesibleFrom:(BoardLocation*)location NeighborhoodType:(NeighborhoodType)NEIGHBORHOOD_TYPE;

-(NSArray*)cellsAccesibleFrom:(BoardLocation *)location NeighborhoodType:(NeighborhoodType)NEIGHBORHOOD_TYPE walkDistance:(int)distance;

@end