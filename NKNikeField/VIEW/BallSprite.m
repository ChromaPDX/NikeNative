//
//  BallSprite.m
//  nike3dField
//
//  Created by Chroma Developer on 3/18/14.
//
//

#import "NikeNodeHeaders.h"

@implementation BallSprite

-(instancetype) init {
    
    ofSpherePrimitive *sphere = new ofSpherePrimitive(50,12);
    
    self = [super initWith3dPrimitive:sphere fillColor:nil];
    
    self.wireFrameColor = NKWHITE;
    
    if (self){
        
    }
    
    return self;
    
}

-(void)updateWithTimeSinceLast:(NSTimeInterval)dt {
    [super updateWithTimeSinceLast:dt];
    
    if (_player) {
        [self setPosition3d:[_player.ballTarget positionInNode3d:self.parent]];
    }
}

@end
