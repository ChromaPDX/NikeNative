//
//  Actions.m
//  ChromaNSFW
//
//  Created by Robby Kraft on 9/30/13.
//  Copyright (c) 2013 Chroma. All rights reserved.
//

#import "ModelHeaders.h"


@implementation GameSequence

+(instancetype) sequence {
    
    GameSequence *newAction = [[GameSequence alloc]init];
    newAction.GameEvents = [NSMutableArray arrayWithCapacity:12];
    
    return newAction;
}

- (id)initWithCoder:(NSCoder *)decoder {
    
    self = [super init];
    
    if (!self) {
        return nil;
    }
    
    _boost = [decoder decodeIntForKey:@"boost"];
    _index = [decoder decodeIntForKey:@"index"];
    _GameEvents = [[decoder decodeObjectForKey:@"events"] mutableCopy];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    
    [encoder encodeInt:_index forKey:@"index"];
    [encoder encodeInt:_boost forKey:@"boost"];
    [encoder encodeObject:_GameEvents forKey:@"events"];
    
}

-(void)addEvent:(GameEvent*)event {
    [_GameEvents addObject:event];
    event.parent = self;
}

-(Manager*)manager{
    return [_GameEvents.lastObject manager];
}

@end

@implementation GameEvent

+(instancetype) event {
    GameEvent *newEvent = [[GameEvent alloc]init];
    newEvent.seed = [newEvent newSeed];
    
    return newEvent;
}

+(instancetype)eventWithType:(EventType)type manager:(Manager *)manager {
    GameEvent *newEvent = [[GameEvent alloc]init];
    newEvent.seed = [newEvent newSeed];
    newEvent.type = type;
    newEvent.manager = manager;
    return newEvent;
}

-(BOOL)isRunningEvent {
    
    if (_type == kEventMove || _type == kEventChallenge ) {
        return 1;
    }
    
    else return 0;
}

-(BoardLocation*)scatter {
    
    NSLog(@"calculate failed pass!");
    
    BoardLocation *random = [_location copy];
    
    while ([random isEqual:_location]) {
        random.x = _location.x + ([_deck randomForIndex:_seed]%3 - 1);
        random.y = _location.y + ([_deck randomForIndex:_seed+1]%3 - 1);
        
        random.x = MIN(MAX(0, random.x), BOARD_WIDTH-1);
        random.y = MIN(MAX(0, random.y), BOARD_LENGTH-1);
    }
    
    return random;
    
}


-(NSString*)name{

    switch (_type) {
            case kNullAction: return @"NULL";
            // Player Actions
            case kEventAddPlayer: return @"ADD PLAYER";
            case kEventRemovePlayer: return @"REMOVE PLAYER";

            // Field Actions
            case kEventSetBallLocation: return @"MOVE BALL";
            case kEventResetPlayers: return @"RESET PLAYERS";
            case kEventGoalKick: return @"GOALIE KICK";
            
            // Cards / Card Actions
            case kEventDraw: return @"DRAW A CARD";
            case kEventPlayCard: return @"PLAY A CARD";
            case kEventKickPass: return @"PASSES !";
            case kEventKickGoal: return @"SHOOTS !!";
            case kEventChallenge: return @"CHALLENGING !";
            case kEventMove: return @"MOVING";
            case kEventAddSpecial: return @"SPECIAL CARD";
            case kEventRemoveSpecial: return @"REMOVE SPECIAL";
            
            // Deck
            case kEventShuffleDeck: return [NSString stringWithFormat:@"SHUFFLING %@", self.deck.name];
            case kEventReShuffleDeck: return [NSString stringWithFormat:@"RE-SHUFFLING %@", self.deck.name];
            
            // Turn State
            case kEventStartTurn: return @"START TURN";
            case kEventStartTurnDraw: return @"START DRAW CARDS";

            case kEventEndTurn: return @"END TURN";
            
            // Camera
            case kEventMoveCamera: return @"MOVING CAMERA";
            case kEventMoveBoard: return @"MOVING CAMERA";
            
            // Sequence
        case kEventSequence: return @"EVENT SEQUENCE";
         
    }
    
    return @"FAIL!";
    
}

-(void)setCard:(Card *)card {
    _card = card;
    _deck = card.deck;
    _playerPerforming = card.deck.player;
    self.manager = _playerPerforming.manager;
}

-(void)setPlayerPerforming:(Player *)playerPerforming {
    _playerPerforming = playerPerforming;
    self.manager = playerPerforming.manager;
}

-(void)setLocation:(BoardLocation *)location {
    _location = [location copy];
    
}

-(void)setManager:(Manager *)manager {
    _manager = manager;
    _teamSide = manager.teamSide;
}

-(int)actionSlot {
    return [_parent.GameEvents indexOfObject:self];
}

//
//-(void)setPlayerReceivingAction:(Card *)playerReceivingAction {
//    _playerReceivingAction = playerReceivingAction;
//    _receiverUID = playerReceivingAction.uid;
//}

- (id)initWithCoder:(NSCoder *)decoder {
    
    self = [super init];
    
    if (!self) {
        return nil;
    }
    
    _wasSuccessful = [decoder decodeBoolForKey:@"wasSuccessful"];
    _type = [decoder decodeIntForKey:@"type"];
    _teamSide = [decoder decodeIntForKey:@"teamSide"];
    _seed = [decoder decodeIntForKey:@"seed"];
    _cost = [decoder decodeIntForKey:@"cost"];
    
    int x = [decoder decodeIntForKey:@"x"];
    int y = [decoder decodeIntForKey:@"y"];
    int sx = [decoder decodeIntForKey:@"sx"];
    int sy = [decoder decodeIntForKey:@"sy"];
    
    _location = [BoardLocation pX:x Y:y];
    _startingLocation = [BoardLocation pX:sx Y:sy];
    
    // NON-PERSISTENT
    
    //_wasSuccessful = [decoder decodeBoolForKey:@"wasSuccessful"];
    //_actionSlot = [decoder decodeIntForKey:@"actionSlot"];
    //_parent = [decoder decodeObjectForKey:@"parent"];
    //_manager = [decoder decodeObjectForKey:@"manager"];
    //_playerReceivingAction = [decoder decodeObjectForKey:@"playerReceivingAction"];
    //_playerPerformingAction = [decoder decodeObjectForKey:@"playerPerformingAction"];
    
    
    return self;
}



- (void)encodeWithCoder:(NSCoder *)encoder {
    
    [encoder encodeBool:_wasSuccessful forKey:@"wasSuccessful"];
    [encoder encodeInt:_teamSide forKey:@"teamSide"];
    [encoder encodeInt:_type forKey:@"type"];
    [encoder encodeInt:_cost forKey:@"cost"];
    [encoder encodeInt:_seed forKey:@"seed"];
    
    [encoder encodeInt:_location.x forKey:@"x"];
    [encoder encodeInt:_location.y forKey:@"y"];
    [encoder encodeInt:_startingLocation.x forKey:@"sx"];
    [encoder encodeInt:_startingLocation.y forKey:@"sy"];
    
   // [encoder encodeObject:_location forKey:@"location"];
   // [encoder encodeObject:_startingLocation forKey:@"startingLocation"];

    
    // NON-PERSISTENT
        //[encoder encodeInt:_actionSlot forKey:@"actionSlot"];
    //[encoder encodeObject:_parent forKey:@"parent"];
    //[encoder encodeObject: _playerReceivingAction forKey:@"playerReceivingAction"];
    //[encoder encodeObject: _playerPerformingAction forKey:@"playerPerformingAction"];
    //[encoder encodeObject:_manager forKey:@"manager"];
    
    
}

-(NSInteger)newSeed{
    
    NSUInteger newSeed = arc4random() % 9600;
    //NSLog(@"new seed: %ld", newSeed);
    return newSeed;
    
}

@end