//
//  NKGameScene.h
//  nike3dField
//
//  Created by Chroma Developer on 2/27/14.
//
//

#import "NKSceneNode.h"
#import "MiniMaze.h"
#import "Game.h"

@class GameBoardNode;
@class BoardTile;
@class MiniGameNode;
@class UXWindow;
@class Card;
@class Game;

#define AI_SPEED .75


@interface GameScene : NKSceneNode <GameSceneProtocol>

{

}
// SHARE GAME / UI PROPS

@property (nonatomic, strong) Game* game;
@property (nonatomic, weak) Card* selectedCard;
@property (nonatomic, weak) Player* selectedPlayer;
@property (nonatomic, weak) BoardTile *selectedBoardTile;

@property (nonatomic, strong) NSMutableDictionary *gameTiles;  //objects:game tiles, key:location

// UI NODES / SPRITES

@property (nonatomic,strong) NKNode* pivot;
@property (nonatomic,strong) NKScrollNode* boardScroll;
@property (nonatomic, strong) GameBoardNode *gameBoardNode;

@property (nonatomic, strong) UXWindow *uxWindow;

@property (nonatomic, weak) NKNode *followNode;
@property (nonatomic, strong) NKSpriteNode *RTSprite;
@property (nonatomic, strong) BallSprite *ballSprite;

@property (nonatomic, strong) NKSpriteNode *infoHUD;

@property (nonatomic, strong) MiniGameNode *miniGameNode;

@property (nonatomic) int gameBoardNodeScrollOffset;

-(void)setOrientation:(ofQuaternion)orientation;
-(void)gameDidFinishWithLose;
-(void)gameDidFinishWithWin;

// INTER NODE / DELEGATE


-(void)shouldPerformCurrentAction;
-(BOOL)requestActionWithPlayer:(PlayerSprite*)player;
-(void)resetFingerLocation;
-(BoardLocation*)canPlayCard:(Card*)card atPosition:(CGPoint)pos;


@end
