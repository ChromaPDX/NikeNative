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

@class GameScene;
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

@protocol GameCenterProtocol <NSObject>

-(void)initRealTimeConnection;

@end

@interface Game : NSObject <UIAlertViewDelegate>{ // GKLocalPlayerListener, 
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
@property (nonatomic, strong) GameScene* gameScene;
@property (nonatomic, strong) GameSequence *currentEventSequence;

// MAIN UX INTERACTION
@property (nonatomic, weak) Manager *selectedManager;
@property (nonatomic, weak) Player *selectedPlayer;
@property (nonatomic, weak) Card *selectedCard;
@property (nonatomic, weak) BoardLocation *selectedLocation;
@property (nonatomic, strong) NSMutableArray *blockedBoardLocations;

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
-(void)pressedEndTurn;

// RT PROTOCOL
-(void)fetchThisTurnSequences;
-(void)sendSequence:(GameSequence*)sequence perform:(BOOL)perform;
-(void)sendRTPacketWithCard:(Card*)c point:(P2t)touch began:(BOOL)began;
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

-(GameEvent*)addDeployEventToSequence:(GameSequence*)sequence forManager:(Manager*)m toLocation:(BoardLocation*)location withType:(EventType)type;
-(GameEvent*)addCardEventToSequence:(GameSequence*)sequence withCard:(Card*)card forPlayer:(Player*)player toLocation:(BoardLocation*)location withType:(EventType)type;

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

