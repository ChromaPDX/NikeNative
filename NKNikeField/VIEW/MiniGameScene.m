//
//  MiniGameScene.m
//  nike3dField
//
//  Created by Chroma Developer on 3/25/14.
//
//

#import "MiniGameScene.h"

@implementation MiniGameScene


-(instancetype)initWithSize:(CGSize)size {
    
    self = [super initWithSize:size];
    
    if (self) {
        _miniGameNode = [[MiniGameNode alloc] initWithSize:self.size];
        [self addChild:_miniGameNode];
        [_miniGameNode startMiniGame];
    }
    return self;
}

-(void) gameDidFinishWithWin{
    [self removeChild:_miniGameNode];
    _miniGameNode = nil;
    _miniGameNode = [[MiniGameNode alloc] initWithSize:self.size];
    [self addChild:_miniGameNode];
    [_miniGameNode startMiniGame];
}
-(void) gameDidFinishWithLose{
    [self removeChild:_miniGameNode];
    _miniGameNode = nil;
    _miniGameNode = [[MiniGameNode alloc] initWithSize:self.size];
    [self addChild:_miniGameNode];
    [_miniGameNode startMiniGame];
}

@end
