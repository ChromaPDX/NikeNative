//
//  GameBoardNode.m
//  nike3dField
//
//  Created by Chroma Developer on 2/27/14.
//
//

#import "NikeNodeHeaders.h"

@implementation GameBoardNode
//
//-(instancetype)initWithColor:(UIColor *)color size:(S2t)size {
//    self = [super initWithColor:color size:size];
//    
//    if(self){
//        
//    }
//    
//    return self;
//    
//}

-(void)handleEvent:(NKEvent *)event {
    
    if (NKEventPhaseEnd == event.phase) {
        ((GameScene*)_scene).selectedBoardTile = self;
        BoardLocation *bl = [[BoardLocation alloc] initWithX:event.screenLocation.x Y:event.screenLocation.y];
        NSLog(@"touchUP in boardTile, location = %f,%f, bl = %@", event.screenLocation.x, event.screenLocation.y, bl);
        [((GameScene*)_scene) setSelectedBoardLocation:bl];
    }
}




@end
