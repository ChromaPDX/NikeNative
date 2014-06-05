//
//  NKGameScene.h
//  nike3dField
//
//  Created by Chroma Developer on 2/27/14.
//
//

#import "NikeBaseScene.h"

@class GameBoardNode;
@class BoardTile;
@class MiniGameNode;
@class UXWindow;
@class UXTopBar;

@class BallSprite;

@class Card;
@class Player;
@class Manager;
@class Game;
@class PlayerSprite;
@class BoardLocation;
@class GameEvent;
@class GameSequence;

#define AI_SPEED .5

@interface GameScene : NikeBaseScene

{

}
// SHARE GAME / UI PROPS

@property (nonatomic, strong) Game* game;
@property (nonatomic, weak) Card* selectedCard;
@property (nonatomic, weak) Player* selectedPlayer;
@property (nonatomic, weak) BoardTile *selectedBoardTile;

@property (nonatomic, strong) NSMutableDictionary *gameTiles;  //objects:game tiles, key:location
@property (nonatomic, strong) NSDictionary *soundFiles;
@property (nonatomic, strong) NSDictionary *soundVolumes;
// UI NODES / SPRITES

@property (nonatomic,strong) NKNode* pivot;
@property (nonatomic,strong) NKNode* fieldBackground;
@property (nonatomic, strong) GameBoardNode *fieldBackgroundNode;
@property (nonatomic, strong) GameBoardNode *gameBoardNode;
@property (nonatomic,strong) NKScrollNode* boardScroll;

@property (nonatomic, strong) UXWindow *uxWindow;
@property (nonatomic, strong) UXTopBar *uxTopBar;

@property (nonatomic, weak) NKNode *followNode;
@property (nonatomic, strong) NKSpriteNode *RTSprite;
@property (nonatomic, strong) BallSprite *ballSprite;

@property (nonatomic, strong) NKSpriteNode *infoHUD;

@property (nonatomic, strong) MiniGameNode *miniGameNode;

@property (nonatomic) int gameBoardNodeScrollOffset;

-(void)setOrientation:(Q4t)orientation;
-(void)gameDidFinishWithLose;
-(void)gameDidFinishWithWin;

// SETUP BOARD

-(void)cleanupGameBoard;
-(void)setRotationForManager:(Manager*)m;
-(void)setupGameBoard;
-(void)incrementGameBoardPosition:(NSInteger)xOffset;
-(void)refreshScoreBoard;
-(void)moveBallToLocation:(BoardLocation*)location;

-(float)rotationForManager:(Manager*)m;

// GAME CENTER

-(void)setMyTurn:(BOOL)myTurn;
-(void)setWaiting:(BOOL)waiting;
-(void)rtIsActive:(BOOL)active;
-(void)receiveRTPacket;

-(void)addNetworkUIForEvent:(GameEvent*)event;
-(void)cleanUpUIForSequence:(GameSequence*)sequence;

-(void)opponentBeganCardTouch:(Card*)card atPoint:(P2t)point;
-(void)opponentMovedCardTouch:(Card*)card atPoint:(P2t)point;

// CARDS

-(void)setSelectedCard:(Card*)card;
-(void)setSelectedPlayer:(Card*)player;

-(void)showPossibleKickForManager:(Manager*)manger;
-(void)showCardPath:(NSArray*)path forPlayer:(Player*)player;

-(void)sortHandForManager:(Manager *)manager animated:(BOOL)animated;

-(void)addCardToBoardScene:(Card *)card;
-(void)addCardToBoardScene:(Card *)card animated:(BOOL)animated withCompletionBlock:(void (^)())block;
-(void)removePlayerFromBoard:(PlayerSprite *)person animated:(BOOL)animated withCompletionBlock:(void (^)())block;

-(void)addCardToHand:(Card *)card;
-(void)removeCardFromHand:(Card *)card;

-(void)applyBlurWithCompletionBlock:(void (^)())block;
-(void)removeBlurWithCompletionBlock:(void (^)())block;

-(void)refreshUXWindowForPlayer:(Player*)p withCompletionBlock:(void (^)())block ;
// AI SELECTION
-(void)AISelectedPlayer:(Player *)selectedPlayer;
-(void)AISelectedCard:(Card *)selectedCard;
-(void)AISelectedLocation:(BoardLocation*)selectedLocation;

// ANIMATION
-(void)animateEvent:(GameEvent*)event withCompletionBlock:(void (^)())block;
-(void)animateBigText:(NSString*)theText withCompletionBlock:(void (^)())block;
-(void)rollEvent:(GameEvent*)event withCompletionBlock:(void (^)())block;
-(void)refreshSequencePoints;
-(void)presentTrophyWithCompletionBlock:(void (^)())block;
-(void)fadeOutHUD;

// INTER NODE / DELEGATE

-(void)playSoundWithKey:(NSString*)key;
-(void)playMusicWithKey:(NSString*)key;

-(void)shouldPerformCurrentAction;
-(BOOL)requestActionWithPlayer:(PlayerSprite*)player;
-(void)resetFingerLocation;
-(BoardLocation*)canPlayCard:(Card*)card atPosition:(P2t)pos;

-(void)playerSpriteDidSelectPlayer:(Player*)player;

-(void)pressedEndTurn;

@end
