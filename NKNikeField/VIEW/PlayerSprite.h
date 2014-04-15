//
//  PlayerNode.h
//  nike3dField
//
//  Created by Chroma Developer on 3/4/14.
//
//

#import "NKSpriteNode.h"

@class GameScene;
@class Card;

@interface PlayerSprite : NKSpriteNode
{
    CGPoint touchOffset;
    CGPoint origin;
    NKLabelNode *cardName;
}

@property (nonatomic, strong) NKSpriteNode *posession;
@property (nonatomic, strong) NKSpriteNode *ballTarget;

@property (nonatomic, weak) BallSprite *ball;
@property (nonatomic, weak) GameScene *delegate;
@property (nonatomic, weak) Player* model;

@property (nonatomic, weak) UITouch *touch;

@property (nonatomic) bool highlighted;

-(void)stealPossesionFromPlayer:(PlayerSprite*)player;

-(void)getReadyForPosession:(void (^)())block;
-(void)stopPosession:(void (^)())block;
-(void)startPossession;

@end
