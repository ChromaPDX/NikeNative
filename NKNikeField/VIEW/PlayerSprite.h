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
    P2t touchOffset;
    P2t origin;
    //NKLabelNode *cardName;
    NKSpriteNode *cardImg;
    NKNode *rotate;
    NKSpriteNode *halo;
}

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

// FOR UX WINDOW

-(void)setStateForBar;

@end
