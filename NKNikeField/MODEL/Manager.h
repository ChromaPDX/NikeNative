//
//  Manager.h
//  CardDeck
//
//  Created by Robby Kraft on 9/17/13.
//  Copyright (c) 2013 Robby Kraft. All rights reserved.
//

#import "GlobalTypes.h"

@class Deck;
@class Game;
@class BoardLocation;
@class Card;
@class Player;

@interface Manager : NSObject <NSCoding, NSCopying>

-(id)initWithGame:(Game*)game;

// PERSISTENT PROPERTIES

@property (nonatomic) Deck* players;
@property (nonatomic, strong) NSString *name;
// Game Engine

@property (nonatomic) bool myTurn;
@property (nonatomic) bool isAI;
@property (nonatomic) int teamSide;
@property (nonatomic) int ActionPoints;

// Meta Data

//@property (nonatomic) NSMutableArray *cardsInGame;
@property (nonatomic, strong) NKColor *color;

@property (nonatomic) int actionPointsEarned;
@property (nonatomic) int actionPointsSpent;
@property (nonatomic) int attemptedGoals;
@property (nonatomic) int successfulGoals;
@property (nonatomic) int attemptedPasses;
@property (nonatomic) int successfulPasses;
@property (nonatomic) int attemptedSteals;
@property (nonatomic) int successfulSteals;
@property (nonatomic) int playersDeployed;
@property (nonatomic) int cardsDrawn;
@property (nonatomic) int cardsPlayed;


// CONVENIENCE / NORMALIZATION

@property (nonatomic, weak) Game *game;

-(bool)hasPossesion;
-(Card*)cardInDeckAtLocation:(BoardLocation*)location;
-(Card*)cardInHandAtlocation:(BoardLocation*)location;

-(BoardLocation*)goal;
-(Manager*)opponent;

-(NSArray*)playersClosestToBall;
-(NSArray*)playersClosestToGoal;
-(NSArray*)playersInShootingRange;
-(Player*)playerWithBall;


@end