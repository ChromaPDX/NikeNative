//
//  BallSprite.m
//  nike3dField
//
//  Created by Chroma Developer on 3/18/14.
//
//

#import "NikeNodeHeaders.h"

@implementation BallSprite


-(void)updateWithTimeSinceLast:(F1t)dt {
    [super updateWithTimeSinceLast:dt];
    
    if (_player) {
        [self setPosition3d:[_player.ballTarget positionInNode3d:self.parent]];
       // [self setPosition3d:_player.ballTarget.position3d];
    }
}

@end
