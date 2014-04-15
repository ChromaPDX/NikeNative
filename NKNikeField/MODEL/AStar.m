//
//  AStar.cpp
//  Squares
//
//  Created by Robby Kraft on 2/21/14.
//  Copyright (c) 2014 Robby Kraft. All rights reserved.
//

#define ROOK_MOVE_COST 5
#define BISHOP_MOVE_COST 7
// costs based on the unit square and its diagonal, 1:sqrt(2) =~ 1:1.4 == 10:14 == 5:7

// NEIGHBORHOOD_TYPE 1  // 0:Von Neumann  1:Moore

#define MAX_ITERATIONS 10000 // just incase. prevent infinite loop

#import "AStar.h"

@interface AStar (){
    int columns;
    int rows;
    bool *obstacleCells;
    int obstacleCellArrayLength;
    
    int *hValues;  // (heuristic) manhattan distance to end point
    int *gValues;  // move cost from start point
    int *fValues;  // g + h values
    
    bool *openList;
    bool *closedList;
    
    int *parentIndex;
}

@end

@implementation AStar

-(void) updateObstacleCells:(NSArray*)obstacles{
    for(int i = 0; i < columns*rows; i++)
        obstacleCells[i] = false;
    
    for(BoardLocation *obstacle in obstacles)
        obstacleCells[ obstacle.x + obstacle.y*columns ] = true;
}

-(BoardLocation*)LocationFromIndex:(int)index{
    return [BoardLocation pX:index%columns Y:(int)index/columns];
}

-(id) initWithColumns:(int)c Rows:(int)r ObstaclesCells:(NSArray*)obstacles{
    self = [super init];
    if(self){
        columns = c;
        rows = r;
        obstacleCells = (bool*)malloc(sizeof(bool)*columns*rows);
        hValues = (int*)malloc(sizeof(int)*columns*rows);
        gValues = (int*)malloc(sizeof(int)*columns*rows);
        fValues = (int*)malloc(sizeof(int)*columns*rows);
        openList = (bool*)malloc(sizeof(bool)*columns*rows);
        closedList = (bool*)malloc(sizeof(bool)*columns*rows);
        parentIndex = (int*)malloc(sizeof(int)*columns*rows);
        
        [self updateObstacleCells:obstacles];
    }
    return self;
}

-(void) dealloc{
    free(obstacleCells);
    free(hValues);
    free(gValues);
    free(fValues);
    free(openList);
    free(closedList);
    free(parentIndex);
}

-(NSArray*) pathFromAtoB:(BoardLocation*)start B:(BoardLocation*)finish NeighborhoodType:(NeighborhoodType)NEIGHBORHOOD_TYPE
{
    NSMutableArray *pathArray = [NSMutableArray array];
    
    int A = start.x + start.y*columns;
    int B = finish.x + finish.y*columns;
    bool found;
    if(A == B){
        found = true;
        [pathArray addObject:[self LocationFromIndex:A]];
        return pathArray;
    }
    
    found = false;
    
    for(int i = 0; i < columns*rows; i++){
        openList[i] = false;
        closedList[i] = false;
    }
    //    int start[2] = {A%columns, (int)A/columns};
    int end[2] = {B%columns, (int)B/columns};
    for(int c = 0; c < columns; c++){
        for(int r = 0; r < rows; r++){
            hValues[c+r*columns] = abs(end[0]-c) + abs(end[1]-r);
        }
    }
    //    printf("\n");
    //    for(int c = 0; c < columns; c++){
    //        for(int r = 0; r < rows; r++){
    //            printf("%d ",hValues[c+r*columns]);
    //        }
    //        printf("\n");
    //    }
    
    // check neighbors, add children to cell, when finished, close this cell
    int step, stepRow, stepColumn, neighborIndex[8];
    gValues[A] = 0;
    openList[A] = true;
    
    step = A;
    int iterations = 0;
    while(!found && iterations < MAX_ITERATIONS){
        // check if neighbors exist, or are out of bounds.
        BoardLocation *stepLocation = [self LocationFromIndex:step];
        stepColumn = stepLocation.x;
        stepRow = stepLocation.y;
        neighborIndex[0] = -1;
        neighborIndex[1] = -1;
        neighborIndex[2] = -1;
        neighborIndex[3] = -1;
        neighborIndex[4] = -1;
        neighborIndex[5] = -1;
        neighborIndex[6] = -1;
        neighborIndex[7] = -1;
        if(stepColumn > 0) neighborIndex[0] = step - 1;
        if(stepColumn < columns-1) neighborIndex[1] = step + 1;
        if(stepRow > 0) neighborIndex[2] = step - columns;
        if(stepRow < rows-1) neighborIndex[3] = step + columns;
        if(stepColumn > 0 && stepRow > 0) neighborIndex[4] = step - columns - 1;
        if(stepColumn > 0 && stepRow < rows-1) neighborIndex[5] = step + columns - 1;
        if(stepColumn < columns-1 && stepRow > 0) neighborIndex[6] = step - columns + 1;
        if(stepColumn < columns-1 && stepRow < rows-1) neighborIndex[7] = step + columns + 1;
        // if neighbors exist, and are on the open list, calculate cost and set their parent
        for(int i = 0; i < 4+NEIGHBORHOOD_TYPE*4; i++){
            if(neighborIndex[i] != -1 && !openList[neighborIndex[i]] && !closedList[neighborIndex[i]] && !obstacleCells[neighborIndex[i]] ){
                if(i < 4)
                    gValues[neighborIndex[i]] = gValues[step] + ROOK_MOVE_COST;
                else
                    gValues[neighborIndex[i]] = gValues[step] + BISHOP_MOVE_COST;
                fValues[neighborIndex[i]] = gValues[neighborIndex[i]] + hValues[neighborIndex[i]];
                parentIndex[neighborIndex[i]] = step;
                openList[neighborIndex[i]] = true;
            }
        }
        openList[step] = false;
        closedList[step] = true;
        int smallestFValue = INT_MAX;
        int smallestIndex = -1;
        for(int i = 0; i < columns*rows; i++){
            if(openList[i] && fValues[i] < smallestFValue){
                smallestFValue = fValues[i];
                smallestIndex = i;
            }
        }
        // repeat with step = smallestIndex;
        if(smallestIndex == -1) {
            printf("fail: cannot reach target cell\n");
            return nil;
        }
        step = smallestIndex;
        if(smallestIndex == B){
            //            printf("\n*******\n FOUND\n*******\n");
            // trace parents back to point A, build a list along the way
            int i = 0;
            int pathIndex = B;
            do {
                [pathArray addObject:[self LocationFromIndex:pathIndex]];
                //                pathArray[i] = pathIndex;
                pathIndex = parentIndex[pathIndex];
                i++;
            } while (pathIndex != A && i < MAX_ITERATIONS);
            //            *sizeOfArray = i;
            return pathArray;
        }
        iterations++;
    }
    
    printf("returning cause iterations got to %d\n",iterations);
    return nil;
}

-(NSArray*) cellsAccesibleFrom:(BoardLocation*)location NeighborhoodType:(NeighborhoodType)NEIGHBORHOOD_TYPE{
    
    int A = location.x + location.y*columns;
    bool found;
    found = false;
    for(int i = 0; i < columns*rows; i++){
        openList[i] = false;
        closedList[i] = false;
    }
    // check neighbors, add children to cell, when finished, close this cell
    int step, stepRow, stepColumn, neighborIndex[8];
    gValues[A] = 0;
    openList[A] = true;
    
    step = A;
    int iterations = 0;
    while(!found && iterations < MAX_ITERATIONS){
        // check if neighbors exist, or are out of bounds.
        BoardLocation *stepLocation = [self LocationFromIndex:step];
        stepColumn = stepLocation.x;
        stepRow = stepLocation.y;
        neighborIndex[0] = -1;
        neighborIndex[1] = -1;
        neighborIndex[2] = -1;
        neighborIndex[3] = -1;
        neighborIndex[4] = -1;
        neighborIndex[5] = -1;
        neighborIndex[6] = -1;
        neighborIndex[7] = -1;
        if(stepColumn > 0) neighborIndex[0] = step - 1;
        if(stepColumn < columns-1) neighborIndex[1] = step + 1;
        if(stepRow > 0) neighborIndex[2] = step - columns;
        if(stepRow < rows-1) neighborIndex[3] = step + columns;
        if(stepColumn > 0 && stepRow > 0) neighborIndex[4] = step - columns - 1;
        if(stepColumn > 0 && stepRow < rows-1) neighborIndex[5] = step + columns - 1;
        if(stepColumn < columns-1 && stepRow > 0) neighborIndex[6] = step - columns + 1;
        if(stepColumn < columns-1 && stepRow < rows-1) neighborIndex[7] = step + columns + 1;
        // if neighbors exist, and are on the open list, calculate cost and set their parent
        for(int i = 0; i < 4+NEIGHBORHOOD_TYPE*4; i++){
            if(neighborIndex[i] != -1 && !openList[neighborIndex[i]] && !closedList[neighborIndex[i]] && !obstacleCells[neighborIndex[i]] ){
                parentIndex[neighborIndex[i]] = step;
                openList[neighborIndex[i]] = true;
            }
        }
        openList[step] = false;
        closedList[step] = true;
        int nextAvailableIndex = -1;
        int i = 0;
        do {
            if(openList[i] ){
                nextAvailableIndex = i;
            }
            i++;
        } while (nextAvailableIndex == -1 && i < columns*rows);
        
        if(nextAvailableIndex == -1) {
            //            printf("\ncompleted. all reachable cells have been checked.\n");
            NSMutableArray *checked = [NSMutableArray array];
            for(int i = 0; i < columns*rows; i++)
                if(closedList[i])
                    [checked addObject:[self LocationFromIndex:i]];
            return checked;
        }
        step = nextAvailableIndex;
        iterations++;
    }
    printf("returning to prevent infinite loop, iterations got to %d\n",iterations);
    printf("if this failed too soon, get rid of the safety switch 'iterations'\n");
    return nil;
}

-(NSArray*)cellsAccesibleFrom:(BoardLocation *)location NeighborhoodType:(NeighborhoodType)NEIGHBORHOOD_TYPE walkDistance:(int)distance {
    NSArray* accesibleCells = [self cellsAccesibleFrom:location NeighborhoodType:NEIGHBORHOOD_TYPE];
    
    NSMutableArray* inRange = [NSMutableArray array];
    
    for (BoardLocation* loc in accesibleCells) {
        NSArray *path = [self pathFromAtoB:location B:loc NeighborhoodType:NEIGHBORHOOD_TYPE];
        if (path.count <= distance) {
            [inRange addObject:loc];
        }
    }
    
    return inRange;
}

@end