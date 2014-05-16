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

@property (nonatomic, strong) Deck* players;
@property (nonatomic, strong) NSString *name;

@property (nonatomic,strong) NSMutableDictionary *effects;

// Game Engine

@property (nonatomic) bool myTurn;
@property (nonatomic) bool isAI;
@property (nonatomic) int teamSide;
@property (nonatomic) int energy;

// Hand

@property (nonatomic, strong) Deck *kickDeck;
@property (nonatomic, strong) Deck *challengeDeck;
@property (nonatomic, strong) Deck *moveDeck;
@property (nonatomic, strong) Deck *specialDeck;

// Meta Data

//@property (nonatomic) NSMutableArray *cardsInGame;
@property (nonatomic, strong) NKColor *color;

@property (nonatomic) int energyEarned;
@property (nonatomic) int energySpent;
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
-(BoardLocation*)goal;
-(Manager*)opponent;

#pragma mark - DECK

-(Card*)cardInHandOfCategory:(int) category;
-(NSArray*)cardsInHandOfCategory:(int) thisCategory;
-(NSArray*)allCardsInHand;
-(NSArray*)allCardsInDeck;
-(Card*)drawCard; // TO:DO probability based on Faction

#pragma mark - FIELD

-(NSArray*)playersClosestToBall;
-(NSArray*)playersClosestToGoal;
-(NSArray*)playersInShootingRange;
-(Player*)playerWithBall;
-(Player*)bestChoiceForDisable;

@end