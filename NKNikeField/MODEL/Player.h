//
//  Player.h
//  nike3dField
//
//  Created by Chroma Developer on 3/25/14.
//
//

#import "Card.h"
@class Deck;

typedef NS_ENUM(int32_t, FactionType) {
    FactionNone,
    FactionKinforce,
    FactionPsyke,
    FactionSention,
    FactionGenmod
};

@interface Player : Card

-(id)initWithManager:(Manager*)m;
-(void)generateDefaultCards;

// PERSISTENT (IN ADDITION TO PERSISTENT INHERITED CARD PROPERTIES)

@property (nonatomic, strong) Deck *kickDeck;
@property (nonatomic, strong) Deck *challengeDeck;
@property (nonatomic, strong) Deck *moveDeck;
@property (nonatomic, strong) Deck *specialDeck;

@property (nonatomic) FactionType faction;
@property (nonatomic) int cardSlots;
@property (nonatomic) BOOL female;

// NON-PERSISTENT - ADDED IN REALTIME

@property (nonatomic, weak) Manager *manager;
@property (nonatomic) bool used;

//@Eric, let's turn these into a NSDictionary so we can keep clean as card #'s grow

@property (nonatomic,strong) NSMutableDictionary *effects;

//@property (nonatomic) bool deRez;
//@property (nonatomic) bool newDeal;
//@property (nonatomic) bool frozen;
//@property (nonatomic) bool noLegs;

@property (nonatomic, weak) Card *ball;  // if I'm a player, do i have the ball? (or, NIL)
@property (nonatomic, strong) NSArray *enchantments; // array of (Card*) types, cards currently modifying a player card. only used ifTypePlayer

// Enchantment Methods

-(void)addEnchantment:(Card*)enchantment;
-(void)removeEnchantment:(Card*)enchantment;
-(void)removeLastEnchantment;

//-(NSArray*)allCardsInHand;
//-(NSArray*)allCardsInDeck;
//
//-(Card*)cardInHandAtlocation:(BoardLocation*)location;
//-(Card*)cardInDeckAtLocation:(BoardLocation*)location;

// Convenience functions for AI, etc.
-(NSArray*)pathToBoardLocation:(BoardLocation*)location;
-(NSArray*)pathFromBoardLocationToBoardLocation:(BoardLocation*)fromLocation toLocation:(BoardLocation *)toLocation;
-(NSArray*)pathFromBoardLocationToBoardLocationNoObstacles:(BoardLocation*)fromLocation toLocation:(BoardLocation *)toLocation;
-(NSArray*)pathToClosestAdjacentBoardLocation:(BoardLocation*)location;
-(NSArray*)pathToBall;
-(NSArray*)pathToGoal;
-(NSArray*)pathToKickRange:(Player*)player;
-(NSArray*)pathToChallenge:(Player*)player;
-(NSArray*)pathToOpenFieldClosestToLocationInPassRange:(BoardLocation *)location;
-(NSArray*)pathToOpenFieldClosestToLocation:(BoardLocation*)location;
-(BoardLocation*)closestLocationInTileSet:(NSArray*)tileSet;
-(BOOL)isInShootingRange;
-(NSArray*)playersInPassRange;
-(Player*)passToAvailablePlayerInShootingRange;
-(NSArray*)playersAvailableCloserToGoal;
-(NSArray*)playersAvailableInKickRangeCloserToGoal;
-(BOOL)canMoveToChallenge;
-(NSDictionary*)playersDistanceAfterMove:(BoardLocation*)location;
-(int)distanceAfterMoveToClosestPlayer:(BoardLocation *)location;
-(int)distanceAfterMoveToClosestOpponent:(BoardLocation *)location;
-(int)distanceAfterMoveToClosestTeammate:(BoardLocation *)location;




@end
