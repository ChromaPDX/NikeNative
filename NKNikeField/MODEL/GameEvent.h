//
//  Actions.h
//  ChromaNSFW
//
//  Created by Robby Kraft on 9/30/13.
//  Copyright (c) 2013 Chroma. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CardTypes.h"

@class Manager;
@class GameEvent;
@class Card;
@class BoardLocation;

@interface GameSequence : NSObject <NSCoding>

+(instancetype) sequence;

-(Manager*)manager;

-(void)addEvent:(GameEvent*)event;

@property (nonatomic, strong) NSMutableArray *GameEvents;
@property (nonatomic, copy) void (^completionBlock)(void);

@property (nonatomic) int boost;
@property (nonatomic) int index;

@property (nonatomic) float roll;

@end

@interface GameEvent : NSObject <NSCoding>

// NON-PERSISTENT

@property (nonatomic, weak) Manager *manager;
@property (nonatomic, weak) Player *playerPerforming;
@property (nonatomic, weak) Player *playerReceiving;
@property (nonatomic, weak) Deck *deck;
@property (nonatomic, weak) Card *card;

@property (nonatomic, weak) GameSequence *parent;
@property (nonatomic) float totalModifier;
@property (nonatomic) float success;

//PERSISTENT
@property (nonatomic) bool wasSuccessful;
@property (nonatomic) EventType type;
@property (nonatomic) int teamSide;
@property (nonatomic) int index;
@property (nonatomic) int cost;
@property (nonatomic, strong) BoardLocation *location;
@property (nonatomic, strong) BoardLocation *startingLocation;
@property (nonatomic, strong) BoardLocation *scatter;
@property (nonatomic) NSInteger seed;
//@property (nonatomic) BOOL wasSuccessful;

+(instancetype) event;
+(instancetype) eventWithType:(EventType)type manager:(Manager*)manager;

-(NSString*)name;
-(BOOL)isRunningEvent;

@end
