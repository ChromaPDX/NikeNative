//
//  Game.h
//  CardDeck
//
//  Created by Robby Kraft on 9/17/13.
//  Copyright (c) 2013 Robby Kraft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import "CardTypes.h"
#import "GlobalTypes.h"

//#define CHEAT
#define NEWPLAYER @"New Player"

@class NKGameScene;
@class BoardNode;
@class BoardTile;
@class PlayerSprite;
@class InfoHUD;
@class EventSprite;
@class CardSprite;
@class BallSprite;
@class FuelBar;
@class UXWindow;
@class GameEvent;
@class GameSequence;
@class Manager;
@class Card;
@class BoardLocation;
@class ScoreBoard;
@class Abilities;
@class Player;

typedef enum RTMessageType {
    RTMessageNone,
    RTMessagePlayer,
    RTMessageShowSequence,
    RTMessageCancelSequence,
    RTMessageSortCards,
    RTMessagePerformSequence,
    RTMessageCheckTurn,
    RTMessageBeginCardTouch,
    RTMessageMoveCardTouch
} RTMessageType;


@protocol GameSceneProtocol <NSObject>

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

-(void)opponentBeganCardTouch:(Card*)card atPoint:(CGPoint)point;
-(void)opponentMovedCardTouch:(Card*)card atPoint:(CGPoint)point;

// CARDS

-(void)setSelectedCard:(Card*)card;
-(void)setSelectedPlayer:(Card*)player;

-(void)showCardPath:(NSArray*)path;

-(void)sortHandForManager:(Manager *)manager animated:(BOOL)animated;

-(void)addCardToBoardScene:(Card *)card;
-(void)addCardToBoardScene:(Card *)card animated:(BOOL)animated withCompletionBlock:(void (^)())block;
-(void)removePlayerFromBoard:(PlayerSprite *)person animated:(BOOL)animated withCompletionBlock:(void (^)())block;

-(void)addCardToHand:(Card *)card;
-(void)removeCardFromHand:(Card *)card;

-(void)applyBlurWithCompletionBlock:(void (^)())block;
-(void)removeBlurWithCompletionBlock:(void (^)())block;

// AI SELECTION
-(void)AISelectedPlayer:(Player *)selectedPlayer;
-(void)AISelectedCard:(Card *)selectedCard;
-(void)AISelectedLocation:(BoardLocation*)selectedLocation;

// ANIMATION
-(void)finishSequenceWithCompletionBlock:(void (^)())block;
-(void)animateEvent:(GameEvent*)event withCompletionBlock:(void (^)())block;
-(void)animateBigText:(NSString*)theText withCompletionBlock:(void (^)())block;
-(void)rollEvent:(GameEvent*)event withCompletionBlock:(void (^)())block;
-(void)refreshUXWindowForPlayer:(Player*)p withCompletionBlock:(void (^)())block;
-(void)refreshSequencePoints;
-(void)presentTrophyWithCompletionBlock:(void (^)())block;
-(void)fadeOutHUD;



@end

@protocol GameCenterProtocol <NSObject>

-(void)initRealTimeConnection;

@end

@interface Game : NSObject <GKLocalPlayerListener, UIAlertViewDelegate>{
    int review;
    BOOL shouldWin;
    BOOL shouldLose;
    BOOL resumed;
    BOOL rtIsActive;
    BOOL singlePlayer;
    int sequenceIndex;
    BOOL readingMatchData;
    dispatch_queue_t eventQueue;
}


@property (nonatomic, strong) id <GameCenterProtocol> gcController;
@property (nonatomic) NSUInteger rtmatchid;
@property (nonatomic, strong) id <GameSceneProtocol> gameScene;
@property (nonatomic, strong) GameSequence *currentEventSequence;

// MAIN UX INTERACTION
@property (nonatomic, weak) Player *selectedPlayer;
@property (nonatomic, weak) Card *selectedCard;
@property (nonatomic, weak) BoardLocation *selectedLocation;

@property (nonatomic, strong) NSMutableArray *players;

// GK TURN BASED MATCH
@property (nonatomic, strong) GKTurnBasedMatch *match;
@property (nonatomic, strong) GKMatch *rtmatch;
// PERSISTENTa
@property (nonatomic, strong) Manager *me;
@property (nonatomic, strong) Manager *opponent;
@property (nonatomic, strong) NSMutableArray *history;
@property (nonatomic, strong) NSMutableArray *thisTurnSequences;
@property (nonatomic, strong) NSMutableDictionary *matchInfo;
// END PERSISTENT
@property (nonatomic, strong) BoardLocation *score;
@property (nonatomic, strong) Card *ball;
@property (nonatomic, weak)   Manager *scoreBoardManager;

@property (nonatomic, strong) NSMutableArray *turnHeap;
@property (nonatomic, strong) NSMutableArray *sequenceHeap;
@property (nonatomic, strong) NSMutableArray *eventHeap;

@property (nonatomic, strong) NSArray *playerNames;


// ACTIVE ZONE
@property (nonatomic, strong) BoardLocation *activeZone;
@property (nonatomic) BOOL zoneActive;

@property (nonatomic) BOOL myTurn;
@property (nonatomic) BOOL animating;

-(void)startMultiPlayerGame;
-(void)startSinglePlayerGame;
-(void)startAIGame;
-(void)startGameWithExistingMatch:(GKTurnBasedMatch*)match;
-(BOOL)shouldEndTurn;
-(void)endTurn;
-(void)endGame;
-(void)endGameWithWinner:(BOOL)victory;
-(BOOL)canDraw;

// RT PROTOCOL
-(void)fetchThisTurnSequences;
-(void)sendSequence:(GameSequence*)sequence perform:(BOOL)perform;
-(void)sendRTPacketWithCard:(Card*)c point:(CGPoint)touch began:(BOOL)began;
-(void)sendRTPacketWithType:(RTMessageType)type point:(BoardLocation*)location;
-(void)receiveRTPacket:(NSData*)packet;

// SOUNDS
-(void) playTouchSound;

// META DATA
-(void)showMetaData;
-(NSDictionary*)metaDataForManager:(Manager*)m;


// AI UX INTERACTION
-(void)AIChoosePlayerForManager:(Manager*)m;
-(void)AIChooseCardForPlayer:(Player*) p;
-(void)AIChooseLocationForCard:(Card*) c;

// REQUESTS FROM VIEW

-(void)setCurrentManagerFromMatch;
-(BOOL)canUsePlayer:(Player*)player;
-(NSSet*)temporaryEnchantments;

-(GameEvent*)canPlayCard:(Card*)card atLocation:(BoardLocation*)location;
-(GameEvent*)requestPlayerSequenceAtLocation:(BoardLocation*)location;
-(GameEvent*)addPlayerEventToSequence:(GameSequence*)sequence from:(BoardLocation *)startLocation to:(BoardLocation*)location withType:(EventType)type;
-(GameEvent*)addGeneralEventToSequence:(GameSequence*)sequence forManager:(Manager*)m withType:(EventType)type;
-(GameEvent*)addEventToSequence:(GameSequence*)sequence fromCardOrPlayer:(Card*)card toLocation:(BoardLocation*)location withType:(EventType)type;

-(Player*)playerAtLocation:(BoardLocation*)location;

-(BOOL)requestDrawSequence;

-(Manager*)opponentForManager:(Manager*)m;
-(Manager*)managerForTeamSide:(int)teamSide;

-(NSArray*)allBoardLocations;
-(NSArray*)allPlayerLocations;
-(NSArray*)boundingBoxForLocationSet:(NSArray*)set;

-(BOOL)validatePlayerMove:(Card*)player;
-(BOOL)canPerformCurrentSequence;
-(BOOL)shouldPerformCurrentSequence;
-(BOOL)boostSequence;

-(Abilities*)playerAbilitiesWithMod:(Card*)player;

-(void)cheatGetPoints;

@end

