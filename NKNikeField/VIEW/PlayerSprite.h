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
//    NKNode *rotate;
//    NKSpriteNode *halo;
    NKSpriteNode *effectSprite;
    NKSpriteNode *moveRadiusSprite;
}

@property (nonatomic, strong) NKSpriteNode *ballTarget;

@property (nonatomic, strong) BallSprite *ball;
@property (nonatomic, strong) GameScene *delegate;
@property (nonatomic, strong) Player* model;

@property (nonatomic, strong) NKSpriteNode *halo;
@property (nonatomic, strong) NKNode *rotate;



//@property (nonatomic, weak) UITouch *touch;

@property (nonatomic) bool highlighted;
@property (nonatomic) bool inTopBar;

-(void)stealPossesionFromPlayer:(PlayerSprite*)player;

-(void)getReadyForPosession:(void (^)())block;
-(void)stopPosession:(void (^)())block;
-(void)startPossession;
-(void)showEffects;
-(void)showKickMode;
-(void)setHighlighted:(bool)highlighted;

// FOR UX WINDOW

-(void)setStateForBar;

@end
