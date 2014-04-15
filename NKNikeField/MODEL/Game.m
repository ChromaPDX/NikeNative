//
// Game.m
// CardDeck
//
// Created by Robby Kraft on 9/17/13.
// Copyright (c) 2013 Robby Kraft. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

#import "ModelHeaders.h"


#define LOAD_TIME 1.0
#define NKColor UIColor

@interface Game (){
    SystemSoundID touchSound;
    SystemSoundID menuLoop;
}
@end

@implementation Game

-(id) init{
    self = [super init];
    if(self){
        NSString *path = [[NSBundle mainBundle] pathForResource:@"touch" ofType:@"wav"];
        NSURL *pathURL = [NSURL fileURLWithPath : path];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef) pathURL, &touchSound);
    }
    return self;
}

-(void)playTouchSound{
    AudioServicesPlaySystemSound(touchSound);
}

#pragma mark - INITIAL SETUP of THE GAME

//-(void)startMultiPlayerGame {
//
// _me = [[Manager alloc] init];
// _opponent = [[Manager alloc] init];
//
// _score = [BoardLocation pX:0 Y:0];
//
// [_me setColor:[UIColor colorWithRed:0.0 green:80/255. blue:249/255. alpha:1.0]];
// [_opponent setColor:[UIColor colorWithRed:1.0 green:40/255. blue:0 alpha:1.0]];
// [_me setTeamSide:1];
// [_opponent setTeamSide:0];
//
//
// _rtmatchid = arc4random();
// NSNumber *uid = [NSNumber numberWithUnsignedInteger:_rtmatchid];
//
//
// _matchInfo = [NSMutableDictionary dictionaryWithDictionary:@{@"turns":@0,
// @"current player":_match.currentParticipant.playerID,
// @"rtmatchid":uid,
// @"boardLength": [NSNumber numberWithInt:BOARD_LENGTH]
// }];
//
//
//
//
// _me.name = @"CHROMA";
// _opponent.name = @"NIKE";
//
// self.myTurn = YES;
//
// [_gameScene setupGameBoard];
//
// _history = [NSMutableArray array];
// _thisTurnSequences = [NSMutableArray array];
// players = [NSMutableDictionary dictionary];
//
// [self setupNewPlayers];
//
// [self addStartTurnEventsToSequence:_currentEventSequence];
//
// [self refreshGameBoard];
//
// [self performSequence:_currentEventSequence record:YES animate:YES];
//
//
//}

-(void)initGameShared {
    
    _me = [[Manager alloc] initWithGame:self];
    _opponent = [[Manager alloc] initWithGame:self];

    _score = [BoardLocation pX:0 Y:0];
    
    [_me setColor:V2BLUE];
    [_opponent setColor:V2RED];
    
    [_me setTeamSide:1];
    [_opponent setTeamSide:0];
    
    _rtmatchid = arc4random();
    NSNumber *uid = [NSNumber numberWithUnsignedInteger:_rtmatchid];
    
    
    singlePlayer = 1;
    
    
    _matchInfo = [NSMutableDictionary dictionaryWithDictionary:@{@"turns":@0,
                                                                 @"current player":@"single player game",
                                                                 @"rtmatchid":uid,
                                                                 @"boardLength": [NSNumber numberWithInt:BOARD_LENGTH],
                                                                 @"singlePlayerMode": [NSNumber numberWithBool:YES]
                                                                 }];
    
}

-(void)launchGame {
    
    self.myTurn = YES;
    
    [_gameScene setupGameBoard];
    
    NSLog(@"gameboard setup");
    
    _history = [NSMutableArray array];
    _thisTurnSequences = [NSMutableArray array];
    _players = [NSMutableArray array];
    
    [self setupNewPlayers];
    
    NSLog(@"added new players");
    
    [self addStartTurnEventsToSequence:_currentEventSequence forManager:_me];
    [_currentEventSequence addEvent:[GameEvent eventWithType:kEventKickoff manager:_me]];
    
    [self refreshGameBoard];
    
    NSLog(@"running new game action");
    
    [self performSequence:_currentEventSequence record:YES animate:YES];

    
}

-(void)startSinglePlayerGame {
    
    [self initGameShared];
    
    _me.name = @"HUMAN";
    _opponent.name = @"COMPUTER";
    
    _opponent.isAI = true;
    
    [self launchGame];
}


-(void)startAIGame {
    
    [self initGameShared];
    
    _me.name = @"AI - DEEP BLUE";
    _opponent.name = @"AI - DEEP RED";
    
    _me.isAI = true;
    _opponent.isAI = true;
    
    [self launchGame];
    
}


-(void)startGameWithExistingMatch:(GKTurnBasedMatch*)match {
    
    
    
    if (resumed) {
        NSLog(@"2nd Resume: Bailing!!");
        return;
    }
    else {
        NSLog(@"Game.m : resumeExistingGameWithMatch : unarchiving match");
        resumed = 1;
    }
    
    [_gameScene setWaiting:YES];
    
    _match = match;
    
    [self getSortedPlayerNames];
    
    
    
    [_match loadMatchDataWithCompletionHandler:^(NSData *matchData, NSError *error){
        
        
        [self restoreGameWithData:matchData];
        
        singlePlayer = [[_matchInfo objectForKey:@"singlePlayerMode"] boolValue];
        [_gameScene setupGameBoard];
        
        if (!singlePlayer) {
            [_gcController initRealTimeConnection];
        }
        
        [self replayLastTurn];
        
    }];
    
}


#pragma mark - CREATING EVENTS

// MOVING PLAYER ON FIELD
-(BOOL)canUsePlayer:(Player*)player {
    
    if (_myTurn) {
        
        if (!_animating) {
            
            if ([player.manager isEqual:_me]) {
                
                if (_currentEventSequence) {
                    [_gameScene cleanUpUIForSequence:_currentEventSequence];
                }
                
                if (!player.used) {
                    
                    [_gameScene refreshUXWindowForPlayer:player withCompletionBlock:^{
                        
                    }];
                    
                    self.selectedPlayer = player;
                    
                    return 1;
                    
                }
                
            }
            
            else {
                
                if (_currentEventSequence) {
                    [_gameScene cleanUpUIForSequence:_currentEventSequence];
                }
                
                
            }
            
            
            
        }
        
        _currentEventSequence = nil;
        
    }
    
    return 0;
}


-(void)setSelectedCard:(Card *)selectedCard {
    
    if (_myTurn) {
        
        if (!_animating) {
            
            _selectedCard = selectedCard;
            
            [_gameScene showCardPath:[selectedCard validatedSelectionSet]];
        }
    }
    
    
    
}

-(void)setSelectedLocation:(BoardLocation *)selectedLocation {
    
    if (_selectedPlayer) {
        if (_selectedCard) {
            _currentEventSequence = [GameSequence sequence];
            
            // ADD MAIN ACTION
            
            if (_selectedCard.category == CardCategoryMove) {
                [self addEventToSequence:_currentEventSequence fromCardOrPlayer:_selectedCard toLocation:selectedLocation withType:kEventMove];
            }
            
            else if (_selectedCard.category == CardCategoryKick){
                if ([selectedLocation isEqual:_selectedPlayer.manager.goal]) {
                    [self addEventToSequence:_currentEventSequence fromCardOrPlayer:_selectedCard toLocation:selectedLocation withType:kEventKickGoal];
                    GameEvent* resetPlayers = [GameEvent event];
                    resetPlayers.type = kEventResetPlayers;
                    resetPlayers.manager = _selectedPlayer.manager;
                    [_currentEventSequence.GameEvents addObject:resetPlayers];
              

                }
                else {
                    [self addEventToSequence:_currentEventSequence fromCardOrPlayer:_selectedCard toLocation:selectedLocation withType:kEventKickPass];
                }
            }
            
            else if (_selectedCard.category == CardCategoryChallenge){
                [self addEventToSequence:_currentEventSequence fromCardOrPlayer:_selectedCard toLocation:selectedLocation withType:kEventChallenge];
            }
            
            
            // ADD DISCARD EVENT
            [self addEventToSequence:_currentEventSequence fromCardOrPlayer:_selectedCard toLocation:selectedLocation withType:kEventPlayCard];
            
            [self performSequence:_currentEventSequence record:YES animate:YES];
        }
    }
    
}


-(void)getPlayerPointersForEvent:(GameEvent*)event {
    
    if (event.type == kEventSequence) {
        event.playerPerforming = [self playerAtLocation:event.location];
    }
    
    else if (event.type == kEventMove || event.type == kEventChallenge) {
        
        if (event.type == kEventChallenge) {
            event.playerReceiving = [self playerAtLocation:event.location];
        }
        
    }
    
    else if (event.type == kEventPlayCard){
        
        //event.card = [event.playerPerforming cardInHandAtlocation:event.location];
        
        if (!event.card) {
            NSLog(@"play card with no card in hand");
        }
        
    }
    
    else if (event.type == kEventAddPlayer){
        
    }
    
    else if (event.type == kEventRemovePlayer) {
        
        event.playerPerforming = [self playerAtLocation:event.location];
        
    }
    
    else if (event.type == kEventAddSpecial) {
        
        if (!event.playerPerforming) {
            NSLog(@"no player for deploy or enchant");
        }
        
        
        if (event.type == kEventAddSpecial) {
            event.playerReceiving = [self playerAtLocation:event.location];
        }
        
    }
    
    else if (event.type == kEventKickPass) {
        
        event.playerPerforming = [self playerAtLocation:event.startingLocation];
        
        event.playerReceiving = [self playerAtLocation:event.location];
    }
    
}

-(GameEvent*)addEventToSequence:(GameSequence*)sequence fromCardOrPlayer:(Card*)card toLocation:(BoardLocation*)location withType:(EventType)type {
    
    
    
    GameEvent *event = [GameEvent event];
    
    if ([card isKindOfClass:[Player class]]) { // IS A PLAYER
        event.playerPerforming = (Player*)card;
        event.manager = event.playerPerforming.manager;
        event.deck = nil;
        event.type = kEventAddPlayer;
        event.startingLocation = [card.location copy];
        NSLog(@"adding deploy event");
    }
    
    else if (card){ // IS CARD
        event.card = card; // also sets other stuff
        event.startingLocation = [card.deck.player.location copy];
    }
    
    event.type = type;
    event.location = [location copy];
    
    [sequence.GameEvents addObject:event];
    
    event.cost = 0;
    
    return event;
    
}


-(GameEvent*)addDrawEventToSequence:(GameSequence*)sequence forManager:(Manager*)m {
    
    GameEvent *draw = [GameEvent event];
    draw.type = kEventDraw;
    draw.manager = m;
    [sequence.GameEvents addObject:draw];
    //draw.index = sequence.GameEvents.count;
    
    return draw;
    
}


-(GameEvent*)addShuffleEventToSequence:(GameSequence*)sequence forDeck:(Deck*)d {
    
    GameEvent *shuffle = [GameEvent event];
    shuffle.deck = d;
    shuffle.playerPerforming = d.player;
    shuffle.manager = d.player.manager;
    shuffle.type = kEventShuffleDeck;
    
    
    [sequence.GameEvents addObject:shuffle];
    
    //shuffle.index = sequence.GameEvents.count;
    
    return shuffle;
    
}


-(GameSequence*)endTurnSequenceForManager:(Manager*)m {
    
    GameSequence* endTurn = [GameSequence sequence];
    
    GameEvent *e3 = [GameEvent event];
    e3.type = kEventEndTurn;
    e3.manager = m;
    [endTurn.GameEvents addObject:e3];
    
    return endTurn;
    
}

-(void)fullFieldWipeForSequence:(GameSequence*)sequence {
    
    for (Player* p in _players) {
        GameEvent *e = [GameEvent event];
        e.location = [p.location copy];
        e.type = kEventRemovePlayer;
        e.playerPerforming = p;
        
        [sequence.GameEvents addObject:e];
        //e.index = sequence.GameEvents.count;
    }
    
    
}

-(void)addGoalResetToSequence:(GameSequence*)goal {
    
    
    [self fullFieldWipeForSequence:goal];
    
    [self setupCoinTossPositionsForSequence:goal];
    
    if (_me.teamSide) {
        [self addSetBallEventForSequence:goal location:[BoardLocation pX:BOARD_LENGTH/2-1 Y:1]];
    }
    else {
        [self addSetBallEventForSequence:goal location:[BoardLocation pX:BOARD_LENGTH/2 Y:1]];
    }
    
    GameEvent *e2 = [GameEvent event];
    e2.type = kEventRemoveSpecial;
    e2.manager = _me;
    [goal.GameEvents addObject:e2];
    
    
    GameEvent *e3 = [GameEvent event];
    e3.type = kEventEndTurn;
    e3.manager = _me;
    [goal.GameEvents addObject:e3];
    //e.index = endTurn.GameEvents.count;
    
    
}

-(GameEvent*)addSetBallEventForSequence:(GameSequence*)sequence location:(BoardLocation*)location {
    GameEvent *set = [GameEvent event];
    set.type = kEventSetBallLocation;
    set.manager = _me;
    set.location = [location copy];
    [sequence.GameEvents addObject:set];
    //set.index = sequence.GameEvents.count;
    return set;
}

-(void)addStartTurnEventsToSequence:(GameSequence*)sequence forManager:(Manager*)m{
    
    GameEvent* ap = [GameEvent event];
    ap.type = kEventStartTurn;
    ap.manager = m;
    ap.cost = 0;
    [sequence.GameEvents addObject:ap];
    
    GameEvent* draw = [self addDrawEventToSequence:sequence forManager:m];
    draw.type = kEventStartTurnDraw;
    draw.cost = 0;
    
    
}



#pragma mark - PERFORM SEQUENCE


-(void)recordSequence:(GameSequence*)sequence withCompletionBlock:(void (^)())block {
    
    if (block) {
        sequence.completionBlock = block;
    }
    
    [self performSequence:sequence record:true animate:true];
    
}

-(void)performSequence:(GameSequence*)sequence record:(BOOL)shouldRecordSequence animate:(BOOL)animate{
    
    [self clearSelection];
    
    //[_gameScene refreshUXWindowForPlayer:nil withCompletionBlock:nil];
    
    if (animate) {
        _animating = YES;
    }
    
    if (shouldRecordSequence){
        [self processMetaDataForSequence:sequence];
        
        [self sendSequence:sequence perform:YES];
        
    }
    
    else if (sequence.index <= sequenceIndex) {
        
        if (_sequenceHeap.count) {
            NSLog(@"bailing for already played sequence");
            [_sequenceHeap removeObject:sequence];
            [self performSequence:[_sequenceHeap lastObject] record:shouldRecordSequence animate:animate];
        }
        
        else {
            NSLog(@"bailed and no more sequences");
        }
        
        return;
    }
    
    NSLog(@"---- %d -- ACTION -- %d ----", sequence.index, sequence.GameEvents.count);
    
    sequenceIndex = sequence.index;
    
    // [_gameScene refreshScoreBoard];
    
    // MAKE EVENT HEAP- reverse order copy of event array
    
    _eventHeap = [[NSMutableArray alloc]initWithCapacity:5];
    
    for (int i = 0; i < sequence.GameEvents.count; i++){
        [_eventHeap addObject:sequence.GameEvents[sequence.GameEvents.count - (i + 1)]];
    }
    
    
    [self enumerateSequence:sequence record:shouldRecordSequence animate:animate];
    
    
}

//-(BOOL)shouldPerformCurrentSequence {
//
// if (_myTurn && [self canPerformCurrentSequence]) {
//
//
// _sequenceHeap = [[NSMutableArray alloc]initWithCapacity:5];
// [_sequenceHeap addObject:_currentEventSequence];
//
// [self performSequence:_currentEventSequence record:YES animate:YES];
//
//
// return 1;
//
// }
//
// return 0;
//
//}

-(void)enumerateSequence:(GameSequence*)sequence record:(BOOL)shouldRecordSequence animate:(BOOL)animate{
    
    if (_eventHeap.count) {
        
        GameEvent* event = [_eventHeap lastObject];
        
        
        [self performEvent:event];
        
        if (animate) {
            
            
            [_gameScene animateEvent:event withCompletionBlock:^{
                
                [_eventHeap removeLastObject];
                
                [self enumerateSequence:sequence record:shouldRecordSequence animate:animate];
                
                
            }];
            
            
        }
        
        else {
            
            [_eventHeap removeLastObject];
            
            [self enumerateSequence:sequence record:shouldRecordSequence animate:animate];
            
        }
        
    }
    
    else { // AT END OF ACTION
        
        [self endSequence:sequence record:shouldRecordSequence animate:animate];
        
    }
}

-(void)endSequence:(GameSequence*)sequence record:(BOOL)shouldRecordSequence animate:(BOOL)animate{
    
    if (shouldRecordSequence){
        
        [_gameScene cleanUpUIForSequence:sequence];
        
        if (shouldWin) {
            [_gameScene animateBigText:@"YOU WON !!" withCompletionBlock:^{
            }];
            
        }
        else if (shouldLose){
            [_gameScene animateBigText:@"YOU LOST !!" withCompletionBlock:^{
            }];
            
        }
        
        
        else { // END ACTION LOOK FOR MORE
            
            if (_sequenceHeap) {
                
                [_sequenceHeap removeObject:sequence];
                
                if (_sequenceHeap.count) {
                    
                    [self performSequence:[_sequenceHeap lastObject] record:shouldRecordSequence animate:animate];
                    
                    return;
                }
                
                
            }
            
            if (animate) { // ALL 'REAL-TIME' TURNS WILL ANSWER YES !
                
                if (sequence.completionBlock) {
                    sequence.completionBlock();
                }
                
                [_gameScene finishSequenceWithCompletionBlock:^{
                    
                    _animating = NO;
                    
                    if (sequence.manager.myTurn) {
                        
                        bool playersAvailable = false;
                        
                        for (Player *p in sequence.manager.players.inGame) {
                            if (!p.used) {
                                playersAvailable = true;
                            }
                        }
                        
                        if (!playersAvailable) {
                            [self recordSequence:[self endTurnSequenceForManager:sequence.manager] withCompletionBlock:^{
                                GameSequence* passTurn = [GameSequence sequence];
                                [self addStartTurnEventsToSequence:passTurn forManager:sequence.manager.opponent];
                                [self performSequence:passTurn record:true animate:true];
                            }];
                        }
                        
                        else {
                            if (sequence.manager.isAI) {
                                [self AIChoosePlayerForManager:sequence.manager];
                            }
                            
                            [self saveTurnWithCompletionBlock:^{
                                
                                
                                
                            }];
                        }
                        
                        
                    }
                    
                    
                    
                }];
            }
            
            else {
                _animating = NO;
                
                [self saveTurnWithCompletionBlock:^{
                    
                }];
                
            }
            
            
            
            
        }
        
        
        
    }
    
    else { // REPLAY
        
        if (_sequenceHeap) {
            
            [_sequenceHeap removeLastObject];
            
            if (_sequenceHeap.count) {
                [self performSequence:[_sequenceHeap lastObject] record:shouldRecordSequence animate:animate];
                return;
            }
            
        }
        
        if (shouldWin) {
            NSLog(@"game.m : endSequenceForMAnager : ending game !!!");
            [_gameScene animateBigText:@"YOU WON !!" withCompletionBlock:^{}];
            if (_match.status != GKTurnBasedMatchStatusEnded) {
                [self endGameWithWinner:YES];
            }
            
        }
        else if (shouldLose){
            [_gameScene animateBigText:@"YOU LOST !!" withCompletionBlock:^{}];
            if (_match.status != GKTurnBasedMatchStatusEnded) {
                [self endGameWithWinner:NO];
            }
        }
        
        else {
            NSLog(@"completed sequence sequence");
            
            [_turnHeap removeLastObject];
            
            // if (!_turnHeap.count) {
            // [self fetchThisTurnSequences];
            // }
            
            if (animate) {
                
                [_gameScene finishSequenceWithCompletionBlock:^{
                    [self enumerateTurnHeapAnimate:animate];
                }];
                
            }
            
            
            else {
                [self enumerateTurnHeapAnimate:animate];
            }
            
        }
        
        
    }
    
}

#pragma mark - PERFORM EVENT

-(BOOL)performEvent:(GameEvent*)event {
    
    
    if (event.type == kEventChallenge || event.type == kEventKickPass || event.type == kEventKickGoal) {
        event.wasSuccessful = rand() % 100 > 50 ? true : false;
    }
    else {
        event.wasSuccessful = true;
    }
    
    // FIRST INHERIT WHO IS INVOLVED FROM PERSISTENT LOCATIONS
    
    [self getPlayerPointersForEvent:event];
    
    [self logEvent:event];
    
    //event.manager.SequencePoints -= event.cost;
    
    
    if (event.type == kEventStartTurn){
        event.manager.myTurn = true;
        for (Player* p in event.manager.players.inGame) {
            p.used = false;
        }
        
        [self assignBallIfPossible];
        
    }
    
    else if (event.type == kEventDraw || event.type == kEventStartTurnDraw) {
        
        for (Player* p in event.manager.players.inGame) {
            [p.moveDeck turnOverNextCardForEvent:event];
            [p.kickDeck turnOverNextCardForEvent:event];
            [p.challengeDeck turnOverNextCardForEvent:event];
            [p.specialDeck turnOverNextCardForEvent:event];
            [p.specialDeck turnOverNextCardForEvent:event];
        }
        
        //NSLog(@"Game.m : drawing card %@ for:%@", newCard.name, event.manager.name);
        
    }
    
    else if (event.type == kEventSetBallLocation) {
        
        if (_ball.enchantee) {
            [_ball.enchantee setBall:nil];
        }
        
        _ball.location = event.location;
        
        //NSLog(@"Game.m : performEvent : setting inital ball carrier");
        
        [[self playerAtLocation:event.location] setBall:_ball];
        
    }
    
    else if (event.type == kEventAddPlayer){
        
        Player *newPlayer = [event.manager.players.theDeck lastObject];
        
        [_players addObject:newPlayer];
        
        if ([event.manager.players playCardFromDeck:newPlayer]){
            NSLog (@"putting player on field, shufflingcards");
            [newPlayer.moveDeck shuffleWithSeed:event.seed fromDeck:newPlayer.moveDeck.allCards];
            [newPlayer.kickDeck shuffleWithSeed:event.seed fromDeck:newPlayer.kickDeck.allCards];
            [newPlayer.challengeDeck shuffleWithSeed:event.seed fromDeck:newPlayer.challengeDeck.allCards];
            [newPlayer.specialDeck shuffleWithSeed:event.seed fromDeck:newPlayer.specialDeck.allCards];
        }
        
        event.playerPerforming = newPlayer;
        
        event.playerPerforming.location = [event.location copy];
        
        
    }
    
    else if (event.type == kEventRemovePlayer) {
        
        //NSLog(@"**should discard player**");
        
        event.playerPerforming = [self playerAtLocation:event.location];
        
        Player *p = event.playerPerforming;
        
        //NSLog(@">> %d discarding player: %@", event.index, p.name);
        
        for (Card *e in p.enchantments) {
            [e discard];
        }
        
        p.enchantments = nil;
        
        [_players removeObject:p];
        
        
    }
    
    else if (event.type == kEventPlayCard) {
        
        if (event.card) {
            if (event.card.deck.player) {
                event.card.deck.player.used = true;
            }
            
            [event.card discard];
        }
        
    }
    
    else if (event.type == kEventAddSpecial) {
        
        Player *enchantee = event.playerReceiving;
        
        if (!enchantee) {
            NSLog(@"somehow player dissapeared! enchant fail");
        }
        
        //NSLog(@"Game.m : enchant player: %@", enchantee.name);
        [enchantee addEnchantment:event.card]; // PlayerPerforming is the enchantment, not the enchantee
        
    }
    
    
    else if (event.type == kEventEndTurn){
        
        for (Player *p in event.manager.players.inGame) {
            for (Card* c in [p allCardsInHand]) {
                [c discard];
            }
            
        }
        
        [self purgeTemporaryEnchantments];
        
        event.manager.myTurn = false;
        
    }
    
    else if (event.type == kEventResetPlayers){
        
        for (Player *p in event.manager.players.inGame) {
            p.used = true;
        }
        // NSLog(@"resetting coin toss position");
        for (int i = 0; i<3; i++) {
            
            Player*p = [self managerForTeamSide:0].players.inGame[i];
            [p setLocation:[BoardLocation pX:i*2+1 Y:(BOARD_LENGTH/2)+!i]];
            
            Player*p2 = [self managerForTeamSide:1].players.inGame[i];
            [p2 setLocation:[BoardLocation pX:i*2+1 Y:(BOARD_LENGTH/2)-1]];
            
            if (i == 1) {
                if (event.manager.teamSide) {
                    p.ball = _ball;
                }
                else {
                    p2.ball = _ball;
                }
            }
            
        }
        
    }
    
    
    
    else if (event.type == kEventShuffleDeck) {
        
        // NSLog(@"shuffling %@'s deck", event.manager);
        
        [event.deck shuffleWithSeed:event.seed fromDeck:event.deck.allCards];
        
        // START TEST
        
        // event.manager.deck.theDeck = event.manager.deck.allCards;
        //
        // int seeds[7] = {2342, 234235, 123124, 6456, 12314, 5435435, 456456};
        //
        // for (int i = 0; i < 7; i++) {
        // [event.manager.deck shuffleWithSeed:seeds[i] fromDeck:event.manager.deck.theDeck];
        //
        // }
        //
        // for (int i = 6; i >= 0; i--) {
        // [event.manager.deck revertToSeed:seeds[i] fromDeck:event.manager.deck.theDeck];
        //
        // }
        //
        
        // END TEST
        
        
    }
    
#pragma mark card successful
    
    if (event.wasSuccessful) {
        
       if (event.isRunningEvent) {
            
            event.playerPerforming.location = [event.location copy];
            
            // DRIBBLE
            
            if (event.playerPerforming.ball) { // HAVE BALL, BRING IT WITH ME
                _ball.location = [event.location copy];
            }
            
            // CHALLENGE
            
            if (event.type == kEventChallenge) {
                
                //NSLog(@">> %d Game.m : challengeSequence : SUCCEEDED", event.index);
                
                event.playerReceiving.location = [event.startingLocation copy];
                
                event.playerPerforming.ball = _ball;
                
                // MOVE OPPONENT TO MY SQUARE
                
            }
            
            // RUN
            
            if (!_ball.enchantee) { // NO ONE HAS BALL, PICK UP IF THERE
                
                if ([_ball.location isEqual:event.location]) {
                    //NSLog(@"Game.m : performEvent : picking up ball");
                    [event.playerPerforming setBall:_ball];
                }
                
            }

            
        }
        
        else if (event.type == kEventKickPass){ // PASS
            //NSLog(@"pass!");
            [event.playerPerforming setBall:Nil];
            
            event.playerReceiving = [self playerAtLocation:event.location];
            
            Player *p = event.playerReceiving;
            [p setBall:_ball];
        }
        
        else if (event.type == kEventKickGoal){ // SHOOT
            
            if (!_score) {
                _score = [BoardLocation pX:0 Y:0];
            }
            
            if (event.manager.teamSide) _score.y += 1;
            else _score.x += 1;
            
        }
        
        
        
        return 1;
    }
#pragma mark card failed
    
    else { // NOT SUCCESSFUL
        
        if (event.isRunningEvent) {
            
            if (event.playerPerforming.ball) {
                [event.playerPerforming setBall:Nil];
                _ball.enchantee = Nil;
            }
            
            if (event.type != kEventChallenge) {
                event.playerPerforming.location = [event.location copy];
            }
            else {
                NSLog(@"challenge fail !!");
            }

        }
        
        else if (event.type == kEventKickGoal || event.type == kEventKickPass){ // FAILED SHOT OR PASS
            [event.playerPerforming setBall:Nil];
            _ball.enchantee = Nil;
            _ball.location = [event scatter];
        }
        
        return 0;
        
    }
    
    
}


-(void)logEvent:(GameEvent*)event{

    if (event.playerPerforming) {
        NSLog(@">>%d %@ is %@ >> %d,%d to %d,%d", event.index, event.playerPerforming.name, event.name, event.startingLocation.x, event.startingLocation.y, event.location.x, event.location.y);
        if (!event.wasSuccessful) {
            NSLog(@"BUT THEY FAILED TO DO SO !!");
        }
    }
    else if (event.startingLocation) {
        NSLog(@">>%d %@ for %@ from %d %d", event.index, event.name, event.manager.name, event.startingLocation.x, event.startingLocation.y);
    }
    else {
        NSLog(@">>%d %@ for %@", event.index, event.name, event.manager.name);
    }
    

    
}

-(id)previousObjectInArray:(NSArray*)array thisObject:(id)object {
    
    int index = [array indexOfObject:object];
    
    if (index == 0) {
        return nil;
    }
    
    return array[index-1];
    
}

#pragma mark - AI DECISION TREE

-(void)AIChoosePlayerForManager:(Manager*)m { // called from end sequence, if we have unused player
    NSLog(@"AI: %@ : is choosing a player", m.name);
    
    if (m.hasPossesion) { // OFFENSE
        
        // player with ball
        for (Player *p in m.players.inGame ) {
            if (p.ball && !p.used) {
                [_gameScene AISelectedPlayer:p];
                return;
            }
        }
        
        // do something else wise ??
        for (Player *p in [m playersClosestToGoal]) {
            if (!p.used) {
                [_gameScene AISelectedPlayer:p];
                return;
            }
        }
        
        // last call find somebody available
        for (Player *p in m.players.inGame ) {
            if (!p.used) {
                [_gameScene AISelectedPlayer:p];
                return;
            }
        }
        
    }
    
    else { // DEFENSE
        
        // nearest to ball first ??
        
        for (Player *p in [m playersClosestToBall]) {
            if (!p.used) {
                [_gameScene AISelectedPlayer:p];
                return;
            }
        }
        
        // last call find somebody available
        for (Player *p in m.players.inGame ) {
            if (!p.used) {
                [_gameScene AISelectedPlayer:p];
                return;
            }
        }
        
    }
    
}

-(void)AIChooseCardForPlayer:(Player*) p{ // called from UI after player has been selected
    NSLog(@"AI is choosing card for Player: %@", p.name);
    
    
    if (p.manager.hasPossesion) {
        // OFFENSE
        if (p.ball) {
            // HAS BALL
            Card* kickCard = p.kickDeck.inHand[0];
            Card* moveCard = p.moveDeck.inHand[0];
            if ([[kickCard validatedSelectionSet] containsObject:kickCard.deck.player.manager.goal]){
                // CAN SHOOT ON GOAL
                kickCard.aiActionType = SHOOT_ON_GOAL;
                //[_gameScene AISelectedLocation:kickCard.deck.player.manager.goal];
                [_gameScene AISelectedCard:kickCard];
                return;
            }
            else{
                //CAN NOT SHOOT ON GOAL
                NSArray *pathToGoal = [p pathToGoal];
                if([pathToGoal count] <= kickCard.range + moveCard.range){
                    // CAN MOVE IN SHOOTING RANGE
                    moveCard.aiActionType = MOVE_TO_GOAL;
                    [_gameScene AISelectedCard:moveCard];
                    return;
                }
                else{
                    //CAN NOT MOVE IN SHOOTING RANGE
                    Player *passToPlayer = [p passToPlayerInShootingRange];
                    if(passToPlayer){
                        // CAN PASS TO PLAYER IN SHOOTING RANGE
                        kickCard.aiActionType = PASS_TO_PLAYER_IN_SHOOTING_RANGE;
                        [_gameScene AISelectedCard:kickCard];
                        return;
                    }
                    else{
                        // CAN NOT PASS TO PLAYER IN SHOOTING RANGE
                        NSArray *playersCloserToGoal = [p playersCloserToGoal];
                        if(playersCloserToGoal){
                            // CAN PASS TO PLAYER CLOSER TO GOAL
                            kickCard.aiActionType = PASS_TO_GOAL;
                            [_gameScene AISelectedCard:kickCard];
                            return;
                        }
                        else{
                            // CAN NOT PASS TO GOAL
                            moveCard.aiActionType = MOVE_TO_GOAL;
                            [_gameScene AISelectedCard:moveCard];
                            return;
                        }
                    }
                }
            }
        }
        else {
            // DOES NOT HAVE BALL
            Card* moveCard = p.moveDeck.inHand[0];
            moveCard.aiActionType = MOVE_TO_GOAL;
            [_gameScene AISelectedCard:moveCard];
            return;
            
        }
    }
    else {
        // DEFENSE
        Card* challengeCard = p.challengeDeck.inHand[0];
        Card* moveCard = p.moveDeck.inHand[0];

        
        if ([[challengeCard validatedSelectionSet] count]) {
            // CAN CHALLENGE
            challengeCard.aiActionType = CHALLENGE;
            [_gameScene AISelectedCard:challengeCard];
            return;
        }
        else{
            // CAN NOT CHALLENGE
            if([p canMoveToChallenge]){
                // CAN MOVE TO CHALLENGE
                moveCard.aiActionType = MOVE_TO_CHALLENGE;
                [_gameScene AISelectedCard:moveCard];
                return;
            }
            else{
                // CAN NOT MOVE TO CHALLENGE
                NSArray *pathToGoal = [p pathToGoal];
                NSArray *pathToBall = [p pathToBall];
                if([pathToGoal count] > [pathToBall count]){
                    // IS CLOSER TO BALL THAN GOAL
                    moveCard.aiActionType = MOVE_TO_BALL;
                    [_gameScene AISelectedCard:moveCard];
                    return;
                }
                else{
                    // IS CLOSER TO GOAL THAN BALL
                    moveCard.aiActionType = MOVE_TO_GOAL;
                    [_gameScene AISelectedCard:moveCard];
                    return;
                }
            }
        }
        
    }
}

-(void)AIChooseLocationForCard:(Card*) c { // called from UI after card has been selected
    NSArray *pathToGoal;
    NSArray *pathToBall;
    Player *passToPlayer;
    NSArray *playersCloserToGoal;
    Player *p = c.deck.player;
   // NSLog(@"in AIChooseLocationForCard, aiActionType = %d", c.aiActionType);
    switch (c.aiActionType){
        case NONE:
            NSLog(@"*********************************************AI: NONE!!!");
            break;
        case MOVE_TO_DEFENDGOAL:  // for now this is the same as move_to_goal
            NSLog(@"*********************************************AI: DEVEND GOAL");
        case MOVE_TO_GOAL:
            NSLog(@"*********************************************AI: MOVE TO GOAL");
            pathToGoal = [c.deck.player pathToGoal];
            if(pathToGoal){
                BoardLocation *newLoc;
                
                int maxDist = [pathToGoal count] - 1;
                
                int travelDistance = MAX(0,MIN(maxDist, c.range));
                // NSLog(@"travelDistance = %d", travelDistance);
                // NSLog(@"path count = %d", [path count]);
                
                if(pathToGoal && travelDistance > 0){
                    newLoc = [pathToGoal objectAtIndex:[pathToGoal count]-travelDistance];
                    [_gameScene AISelectedLocation:newLoc];
                    return;
                }
                else {
                    NSLog(@"AI HAS NO VALID MOVE: STAY");
                    [_gameScene AISelectedLocation:c.deck.player.location];
                    return;
                }
            }
            else {
                NSLog(@"AI HAS NO VALID MOVE: STAY");
                [_gameScene AISelectedLocation:c.deck.player.location];
                return;
            }
            break;
        case SHOOT_ON_GOAL:
            NSLog(@"*********************************************AI: SHOOT ON GOAL");
            [_gameScene AISelectedLocation:c.deck.player.manager.goal];
            return;
            
        case PASS_TO_PLAYER_IN_SHOOTING_RANGE:
            NSLog(@"*********************************************AI: PASS TO PLAYER IN SHOOTING RANGE");
            passToPlayer = [c.deck.player passToPlayerInShootingRange];
            if(passToPlayer){
                if ([c.validatedSelectionSet containsObject:passToPlayer.location]) {
                    [_gameScene AISelectedLocation:passToPlayer.location];
                }
                return;
            }
            
            NSLog(@"AI HAS NO VALID PASS: TRY A MOVE CARD");
            [_gameScene AISelectedCard:c.deck.player.moveDeck.inHand[0]];
            return;
            
        case PASS_TO_GOAL:
            playersCloserToGoal = [c.deck.player playersCloserToGoal];
            if(playersCloserToGoal){
                Player *p = playersCloserToGoal[0];
                if ([c.validatedSelectionSet containsObject:p.location]) {
                    NSLog(@"*********************************************AI: PASS TOWARDS GOAL");
                    [_gameScene AISelectedLocation:p.location];
                    return;
                }
            }

            NSLog(@"AI HAS NO VALID PASS: TRY A MOVE CARD");
            [_gameScene AISelectedCard:c.deck.player.moveDeck.inHand[0]];
            return;
            
            break;
        case CHALLENGE:
            [_gameScene AISelectedLocation: _ball.location];
            return;
            break;
        case MOVE_TO_CHALLENGE:
            NSLog(@"*********************************************AI: MOVE TO CHALLENGE");

            pathToBall = [p pathToBall];
            if(pathToBall){
                [_gameScene AISelectedLocation:pathToBall[[pathToBall count]-1]];
                return;
            }
            else {
                NSLog(@"AI HAS NO VALID MOVE: STAY");
                [_gameScene AISelectedLocation:c.deck.player.location];
                return;
            }
            break;
        case MOVE_TO_BALL:
            NSLog(@"*********************************************AI: MOVE TO BALL");
            pathToBall = [c.deck.player pathToClosestBoardLocation:_ball.location];
            if(pathToBall){
                BoardLocation *newLoc;
                NSLog(@"pathToBall.count = %d", [pathToBall count]);
                int maxDist = [pathToBall count] - 1;
                
                int travelDistance = MAX(0,MIN(maxDist, c.range));
                // NSLog(@"travelDistance = %d", travelDistance);
                // NSLog(@"path count = %d", [path count]);
                NSLog(@"travelDistance = %d", travelDistance);

                if(travelDistance > 0){
                    newLoc = [pathToBall objectAtIndex:[pathToBall count]-travelDistance];
                    [_gameScene AISelectedLocation:newLoc];
                    return;
                }
                else {
                    NSLog(@"AI HAS NO VALID MOVE: STAY");
                    [_gameScene AISelectedLocation:c.deck.player.location];
                    return;
                }
            }
            else {
                NSLog(@"pathToBall = NULL, AI HAS NO VALID MOVE: STAY");
                [_gameScene AISelectedLocation:c.deck.player.location];
                return;
            }
            break;
    }
    NSLog(@"AI HAS NO VALID MOVE: STAY");
    [_gameScene AISelectedLocation:c.deck.player.location];
    return;
}


/*
-(void)AIChooseLocationForCard:(Card*) c { // called from UI after card has been selected
    
    NSLog(@"AI is choosing a location for card: %@", c.name);
    
    if (c.category == CardCategoryMove) { // CALCULATE MOVE CARD
        
        NSArray *path;
        if (c.deck.player.manager.hasPossesion) { // OFFENSE
            path = [c.deck.player pathToGoal];
        }
        else {
            path = [c.deck.player pathToBall]; // DEFENSE
        }
        
        BoardLocation *newLoc;
        
        int maxDist = [path count] - 1;
        
        int travelDistance = MAX(0,MIN(maxDist, c.range));
        // NSLog(@"travelDistance = %d", travelDistance);
        // NSLog(@"path count = %d", [path count]);
        
        if(path && travelDistance > 0){
            newLoc = [path objectAtIndex:[path count]-travelDistance];
            [_gameScene AISelectedLocation:newLoc];
        }
        else {
            NSLog(@"AI HAS NO VALID MOVE: STAY");
            [_gameScene AISelectedLocation:c.deck.player.location];
        }
        
    }
    
    else if (c.category == CardCategoryChallenge){
        [_gameScene AISelectedLocation:_ball.location];
    }
    
    else if (c.category == CardCategoryKick){ // we only got here if kick has a valid set
        if ([[c validatedSelectionSet] containsObject:c.deck.player.manager.goal]){ // stay on target, stay on target
            [_gameScene AISelectedLocation:c.deck.player.manager.goal];
        }
        else { // pick pass that is closest to goal
            BoardLocation *closestToGoal = [BoardLocation pX:3 Y:5]; // choose middle of field
            
            for (BoardLocation *loc in [c validatedSelectionSet]) {
                if ([loc distanceToGoalForManager:c.deck.player.manager neighborhoodType:NeighborhoodTypeRook] < [closestToGoal distanceToGoalForManager:c.deck.player.manager neighborhoodType:NeighborhoodTypeRook]) {
                    closestToGoal = [loc copy];
                }
            }
            
            [_gameScene AISelectedLocation:closestToGoal];
            
        }
    }
    
}
*/


#pragma mark - REPLAY / TURN

-(void)enumerateTurnHeapAnimate:(BOOL)animate {
    
    if (_turnHeap.count) {
        
        [self performTurn:[_turnHeap lastObject] animate:animate];
        
    }
    
    else {
        [self didFinishAllReplays:animate];
    }
    
}



-(void)startMyTurn {
    
    NSLog(@"------------ START MY TURN ------------");
    
    NSLog(@"starting turn %d", _history.count);
    
    _currentEventSequence = [GameSequence sequence];
    
    [self addStartTurnEventsToSequence:_currentEventSequence forManager:_me];
    
    if ([self shouldPerformCurrentSequence]) {
        NSLog(@"start turn success");
    }
    else {
        NSLog(@"failed turn start sequences");
    }
    
}

-(void)didFinishAllReplays:(BOOL)animate {
    
    NSLog(@"------------ COMPLETE REPLAY ------------");
    
    _animating = NO;
    
    [self fetchThisTurnSequences];
    
    
    
}


-(void)performTurn:(NSArray*)turn animate:(BOOL)animate { // ONLY PLAYBACK
    
    
    
    if (turn) {
        
        _sequenceHeap = [[NSMutableArray alloc]initWithCapacity:5];
        
        NSLog(@"Game.m : performSequenceSequence : starting sequence sequence");
        
        for (int i = 0; i < turn.count; i++){
            [_sequenceHeap addObject:turn[turn.count - (i + 1)]];
        }
        
        [self performSequence:[_sequenceHeap lastObject] record:NO animate:animate];
        
        
    }
    
    else {
        NSLog(@"###error### trying to perform nil turn");
    }
    
    // GET MANAGER FOR TURN
    
    
    
    
}

#pragma mark - META DATA


-(void)processMetaDataForSequence:(GameSequence*)sequence {
    
    for (GameEvent *e in sequence.GameEvents) {
        
        Manager* m = e.manager;
        
        [self getPlayerPointersForEvent:e];
        
        // FIRST GENERAL
        
        
        switch (e.type) {
                
            case kEventStartTurn:
                break;
                
            case kEventPlayCard:
                m.cardsPlayed++;
                break;
                
            case kEventKickGoal:
                m.attemptedGoals++;
                break;
                
            case kEventChallenge:
                m.attemptedSteals++;
                break;
                
            case kEventKickPass:
                m.attemptedPasses++;
                break;
                
            case kEventDraw:
                m.cardsDrawn++;
                break;
                
            case kEventAddPlayer:
                m.playersDeployed++;
                break;
                
            default:
                break;
        }
        
        // NOW SUCCESSFUL
        
        if (e.wasSuccessful) {
            
            switch (e.type) {
                    
                case kEventKickGoal:
                    m.successfulGoals++;
                    break;
                    
                case kEventChallenge:
                    m.successfulSteals++;
                    break;
                    
                case kEventKickPass:
                    m.successfulPasses++;
                    break;
                    
                default:
                    break;
            }
            
        }
        
        // NOW FAILED
        
        
    }
    
    
    //NSLog(@"META FOR %@", [self metaDataForManager:sequence.manager]);
    
    
}


-(NSDictionary*)metaDataForManager:(Manager*)m{
    
    NSDictionary *meta = @{@"Team Name": m.name,
                           @"Cards Drawn": [NSNumber numberWithInt:m.cardsDrawn],
                           @"Cards Played": [NSNumber numberWithInt:m.cardsPlayed],
                           @"Players Deployed": [NSNumber numberWithInt:m.playersDeployed],
                           @"Attempted Goals": [NSNumber numberWithInt:m.attemptedGoals],
                           @"Successful Goals": [NSNumber numberWithInt:m.successfulGoals],
                           @"Attempted Passes": [NSNumber numberWithInt:m.attemptedPasses],
                           @"Successful Passes": [NSNumber numberWithInt:m.successfulPasses],
                           @"Attempted Steals": [NSNumber numberWithInt:m.attemptedSteals],
                           @"Successful Steals": [NSNumber numberWithInt:m.successfulSteals],
                           };
    
    return meta;
    
}

//-(void)showMetaData {
// [_gcController showMetaDataForMatch:_match];
//}


#pragma mark - GLOBAL ADD / REMOVE FROM BOARD
#pragma mark -

-(Player*)playerAtLocation:(BoardLocation*)location {
    for (Player* inPlay in _players) {
        if ([inPlay.location isEqual:location]) {
            return inPlay;
        }
    }
    NSLog(@"ERROR: no player found at this location");
    return Nil;
}

-(void) buildBoardFromCurrentState{
    
    NSLog(@"---***---*** UI RESTORE ---***---***");
    
    
    NSLog(@"I have %d players on the board", [_me players].inGame.count);
    
    for (Player *p in [_me players].inGame) {
        
        if ([p.location isEqual:_ball.location]) {
            [p setBall:_ball];
        }
        [self addCardToBoard:p];
        
        
    }
    
    
    NSLog(@"They have %d players on the board", [_me players].inGame.count);
    
    for (Player *p in [_opponent players].inGame) {
        
        if ([p.location isEqual:_ball.location]) {
            [p setBall:_ball];
        }
        [self addCardToBoard:p];
        
        
    }
    
    NSLog(@"-------- FINISH UI RESTORE --------");
    
    [self refreshGameBoard];
    
}

-(void)refreshGameBoard {
    
    // [_gameScene setRotationForManager:_me];
    
    [_gameScene moveBallToLocation:_ball.location];
    
    [_gameScene refreshScoreBoard];
    
}

-(void) setupNewPlayers{
    
    _ball = [[Card alloc] init];
    _ball.specialCategory = CardCategoryBall;
    
    _currentEventSequence = [GameSequence sequence];
    
    [self addShuffleEventToSequence:_currentEventSequence forDeck:_me.players];
    
    [self addShuffleEventToSequence:_currentEventSequence forDeck:_opponent.players];
    
    [self setupCoinTossPositionsForSequence:_currentEventSequence];
    
    [self addSetBallEventForSequence:_currentEventSequence location:[BoardLocation pX:3 Y:BOARD_LENGTH/2-1]];
    
    
}

-(void) addCardToBoard:(Card*)c {
    [_players addObject:c];
    [_gameScene addCardToBoardScene:c];
}


-(void) setupCoinTossPositionsForSequence:(GameSequence*)sequence {
    
    // automated loop, finds your first 3 player cards
    
    // CHECK WE HAVE PLAYERS
    
    for (int i = 0; i<3; i++) {
        
        GameEvent* spawn = [self addEventToSequence:sequence fromCardOrPlayer:nil toLocation:[BoardLocation pX:i*2+1 Y:(BOARD_LENGTH/2)+!i] withType:kEventAddPlayer];
        spawn.manager = [self managerForTeamSide:0];
        
        GameEvent* spawn2 = [self addEventToSequence:sequence fromCardOrPlayer:nil toLocation:[BoardLocation pX:i*2+1 Y:(BOARD_LENGTH/2)-1] withType:kEventAddPlayer];
        spawn2.manager = [self managerForTeamSide:1];
        
    }
    
}

-(void)wipeBoard {
    _ball = [[Card alloc] init];
    _ball.specialCategory = CardCategoryBall;
    
    _players = [NSMutableArray array];
    [_gameScene cleanupGameBoard];
}


-(NSSet*)temporaryEnchantments {
    NSMutableSet *temp = [NSMutableSet set];
    
    for (Player* player in _players) {
        
        for (Card* e in player.enchantments) {
            if (e.isTemporary) {
                [temp addObject:e];
            }
        }
        
        
    }
    
    return temp;
    
}

-(void)purgeTemporaryEnchantments {
    
    for (Player* player in _players) {
        
        NSMutableSet *rem;
        
        for (Card* e in player.enchantments) {
            if (e.isTemporary) {
                if (!rem ) {
                    rem = [NSMutableSet set];
                }
                [rem addObject:e];
                [e discard];
            }
        }
        
        for (Card *c in rem) {
            [player removeEnchantment:c];
        }
        
    }
    
}

-(void)assignBallIfPossible {
    
    for (Player *p in _players){
        if ([p.location isEqual:_ball.location]) {
            [p setBall:_ball];
        }
    }
    
}

-(NSArray*)allBoardLocations {
    NSMutableArray *boardLocations = [NSMutableArray array];
    
    for (int x = 0; x < BOARD_WIDTH; x++) {
        for (int y = 0; y < BOARD_LENGTH; y++) {
            [boardLocations addObject:[BoardLocation pX:x Y:y]];
        }
    }
    
    return boardLocations;
}

-(NSArray*)allPlayerLocations {
    NSMutableArray *locs = [NSMutableArray array];
    for (Player*p in _players) {
        [locs addObject:[p.location copy]];
    }
    return locs;
}

-(NSArray*)boundingBoxForLocationSet:(NSArray*)set {
    
    BoardLocation *ur = [BoardLocation pX:0 Y:0];
    BoardLocation *ll = [BoardLocation pX:BOARD_WIDTH-1 Y:BOARD_LENGTH-1];
    
    for (BoardLocation* loc in set) {
        if (loc.x <= ll.x) {
            ll.x = loc.x;
        }
        if (loc.y <= ll.y) {
            ll.y = loc.y;
        }
        
        if (loc.x >= ur.x) {
            ur.x = loc.x;
        }
        
        if (loc.y >= ur.y) {
            ur.y = loc.y;
        }
    }
    
    NSLog(@"BOUNDING BOX: LL %d,%d UR %d,%d", ll.x, ll.y, ur.x, ur.y);
    
    return @[ll,ur];
    
}

#pragma mark - GAME KIT CONVENIENCE

-(void)clearSelection {
    _selectedCard = nil;
    _selectedLocation = nil;
    _selectedPlayer = nil;
    _currentEventSequence = nil;
}

-(void)setCurrentManagerFromMatch {
    
    NSString *player = _match.currentParticipant.playerID;
    
    if ([[GKLocalPlayer localPlayer].playerID isEqualToString:player]) {
        
        NSLog(@"Game.m : current Manager is : %@", _me.name);
        _scoreBoardManager = _me;
    }
    else {
        
        NSLog(@"Game.m : current Manager is : %@", _opponent.name);
        _scoreBoardManager = _opponent;
    }
    
    
}

-(Manager*)managerForTeamSide:(int)teamSide{
    
    if (_me.teamSide == teamSide) {
        return _me;
    }
    return _opponent;
    
}

-(NSString*)myId {
    return [GKLocalPlayer localPlayer].playerID;
}

-(NSString*)opponentID {
    
    for (GKPlayer *p in _match.participants) {
        if (![p.playerID isEqualToString:[self myId]]) {
            if (p.playerID) {
                return p.playerID;
            }
            else return NEWPLAYER;
        }
    }
    
    return NEWPLAYER;
    
}

-(int)sequenceCountForArray:(NSArray*)array {
    int sequences = 0;
    for (NSArray* turn in array) {
        sequences += turn.count;
    }
    return sequences;
}

-(int)totalGameSequences {
    int sequences = [self sequenceCountForArray:_history];
    sequences += _thisTurnSequences.count;
    return sequences;
}

-(NSArray*)allButLastTurn {
    NSMutableArray* all = [_history mutableCopy];
    [all removeLastObject];
    return all;
}


-(void)fetchThisTurnSequences {
    
    
    [_match loadMatchDataWithCompletionHandler:^(NSData *matchData, NSError *error){
        
        if (!_animating) {
            NSKeyedUnarchiver* unarchiver = [[NSKeyedUnarchiver alloc]initForReadingWithData:[matchData gzipInflate]];
            //NSKeyedUnarchiver* unarchiver = [[NSKeyedUnarchiver alloc]initForReadingWithData:matchData];
            
            [self loadSequencesFromUnarchiver:unarchiver];
            
            [self checkMyTurn];
            [self checkRTConnection];
            
            if ([self catchUpOnSequences]){
                
                
                
            }
            
        }
        
        else {
            NSLog(@"animating, wait . . .");
            // double delayInSeconds = 2.0;
            // dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            // dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            // [self fetchThisTurnSequences];
            // });
        }
        
        
        
    }];
    
    
    
}

-(BOOL)catchUpOnSequences {
    
    
    
    if (sequenceIndex == 0) {
        [self replayLastTurn];
        return 0;
    }
    
    NSLog(@"--- LOADED CURRENT ACTIONS ---");
    
    NSArray *allSequences = [self allSequencesLinear];
    
    NSLog(@"%d TOTAL, %d ALREADY PERFORMED", allSequences.count, sequenceIndex);
    
    int difference = allSequences.count - sequenceIndex;
    
    if (allSequences.count == sequenceIndex) {
        NSLog(@"FETCH IS CURRENT");
        
        if (!_thisTurnSequences) {
            _thisTurnSequences = [NSMutableArray array];
        }
        
        if (!_thisTurnSequences.count) {
            NSLog(@"NO ACTIONS FOR THIS TURN");
            if ([self checkMyTurn]) {
                // BEGINNING OF MY TURN
                [self startMyTurn];
            }
            
        }
        
        return 1;
    }
    
    else if (allSequences.count < sequenceIndex){
        NSLog(@"FETCH IS OLDER THAN RT, CHECK BACK SHORTLY");
        
        double delayInSeconds = 5.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self fetchThisTurnSequences];
        });
        
        return 0;
    }
    
    // SOMETHING FOR CATCH UP
    else { // sequences > index
        
        NSLog(@"FETCH IS NEW by %d new sequences", difference);
        
        _sequenceHeap = [NSMutableArray array];
        
        NSMutableArray *allSequences = [self allSequencesLinear];
        
        for (int i = 0; i < difference; i ++){
            
            [_sequenceHeap addObject:[allSequences lastObject]];
            [allSequences removeLastObject];
            
        }
        
        [self performSequence:[_sequenceHeap lastObject] record:NO animate:YES];
        
        
    }
    
    // else {
    // NSLog(@"FETCH IS REALLY NEW");
    // [self logCurrentGameData];
    // [self wipeBoard];
    // [self refreshGameBoard];
    // [self restoreGameWithData:_match];
    // [self replayLastTurn];
    // }
    
    
    
    return 0;
    
}


-(void)replayGame:(BOOL)animate {
    
    [_gameScene setWaiting:NO];
    
    self.myTurn = NO;
    
    NSLog(@"Game.m : performSequenceSequence : starting sequence sequence");
    
    NSLog(@"Game has %d total sequences", [self totalGameSequences]);
    
    _turnHeap = [[NSMutableArray alloc]initWithCapacity:25];
    
    if (_thisTurnSequences) {
        [_turnHeap addObject:_thisTurnSequences];
    }
    
    if (_history) {
        
        for (int i = 0; i < _history.count; i++)
            [_turnHeap addObject:_history[_history.count - (i + 1)]];
    }
    
    // GET MANAGER FOR TURN
    
    [self wipeBoard];
    
    if (animate) {
        
        [self refreshGameBoard];
        [self enumerateTurnHeapAnimate:YES];
        
    }
    
    else {
        
        [self enumerateTurnHeapAnimate:NO];
        
    }
    
    
}

-(void)replayLastTurn {
    
    [_gameScene setWaiting:NO];
    
    self.myTurn = NO;
    
    NSLog(@"------------ REPLAY HISTORY ------------");
    
    sequenceIndex = 0;
    
    [self wipeBoard];
    [self refreshGameBoard];
    
    _turnHeap = [[NSMutableArray alloc]initWithCapacity:25];
    
    if (_history) {
        
        NSArray* allButLast = [self allButLastTurn];
        
        if (allButLast.count) {
            for (int i = 0; i < allButLast.count; i++){
                [_turnHeap addObject:allButLast[allButLast.count - (i + 1)]];
            }
        }
        
        NSLog(@"Game has %d total sequences", [self totalGameSequences]);
        NSLog(@"non-animate sequences %d", [self sequenceCountForArray:allButLast]);
        NSLog(@"animate sequences %d", [[_history lastObject] count] + _thisTurnSequences.count);
        
    }
    else {
        NSLog(@"------------ NO HISTORY YET ------------");
    }
    
    
    if (_turnHeap.count) {
        NSLog(@"------------ NON-ANIMATE RESTORE ------------");
        [self enumerateTurnHeapAnimate:NO];
        NSLog(@"------------ REBUILD VISUALS ------------");
        [self buildBoardFromCurrentState];
    }
    
    
    // THEN
    
    
    _turnHeap = [[NSMutableArray alloc]initWithCapacity:25];
    
    NSLog(@"------------ ANIMATE REPLAY ------------");
    NSLog(@"Game has %d total sequences", [self totalGameSequences]);
    NSLog(@"already restored %d sequences", [self sequenceCountForArray:[self allButLastTurn]]);
    NSLog(@"animate %d from last turn", [[_history lastObject] count]);
    NSLog(@"animate %d from this turn", [_thisTurnSequences count]);
    
    
    
    if (_thisTurnSequences.count) {
        [_turnHeap addObject:_thisTurnSequences];
    }
    
    
    //NSArray* allButLast = [self allButLastTurn]; // CHECK THAT WE DID HAVE ONE THAT DIDN'T GET PLAYED
    
    if (_history.count) {
        [_turnHeap addObject:[_history lastObject]];
    }
    
    if (_turnHeap.count) { // BETTER BE YES
        NSLog(@"------------ BEGIN ANIMATING ------------");
        [self enumerateTurnHeapAnimate:YES];
    }
    
    else {
        NSLog(@"------------ SOMETHING WENT HORRIBLY WRONG ------------");
        
    }
    
    
}

-(void)replayLastSequence {
    
    [_gameScene setWaiting:NO];
    
    self.myTurn = NO;
    
    NSLog(@"------------ REPLAY HISTORY ------------");
    
    sequenceIndex = 0;
    
    [self wipeBoard];
    [self refreshGameBoard];
    
    NSMutableArray* allSequences = [self allSequencesLinear];
    
    GameSequence *last = [allSequences lastObject];
    
    [allSequences removeLastObject];
    
    _sequenceHeap = [NSMutableArray array];
    
    for (int i = 0; i < allSequences.count; i++){
        [_sequenceHeap addObject:allSequences[allSequences.count - (i + 1)]];
    }
    
    [self performSequence:[_sequenceHeap lastObject] record:NO animate:NO];
    
    [self buildBoardFromCurrentState];
    
    [self performSequence:last record:NO animate:YES];
    
    
}

-(NSMutableArray*)allSequencesLinear {
    
    NSMutableArray *allSequences = [NSMutableArray array];
    
    for (int i = 0; i < _history.count; i++){
        NSArray* turn = _history[i];
        for (int i = 0; i < turn.count; i++){
            [allSequences addObject:turn[i]];
        }
        
    }
    
    for (int i = 0; i < _thisTurnSequences.count; i++){
        [allSequences addObject:_thisTurnSequences[i]];
    }
    
    //NSLog(@"BUILD ACTION ARRAY %d items", allSequences.count);
    
    return allSequences;
    
}

-(int)totalEvents {
    
    int total = 0;
    for (GameSequence *g in [self allSequencesLinear]) {
        total += g.GameEvents.count;
    }
    
    return total;
    
}


#pragma mark - TB NETWORK EVENTS

-(BOOL)checkMyTurn{
    
    if (!_animating) {
        
        if ([_match.currentParticipant.playerID
             isEqualToString:[GKLocalPlayer localPlayer].playerID]) {
            // It's your turn!
            
            self.myTurn = YES;
            
            return NO;
            
        } else {
            // It's not your turn, just display the game state.
            
            self.myTurn = NO;
            
            
            
        }
        
    }
    
    return NO;
    
}


#pragma mark - RT NETWORK EVENTS

-(void)rtIsActive:(BOOL)active {
    
    rtIsActive = active;
    
    if (active) {
        
    }
    
    
    
}

-(void)setRtmatch:(GKMatch *)rtmatch {
    
    if (!_rtmatch && rtmatch) {
        [self fetchThisTurnSequences];
    }
    
    _rtmatch = rtmatch;
    
    
}

-(BOOL)checkRTConnection {
    
    if (_rtmatch) {
        
        if (_rtmatch.playerIDs.count) {
            NSLog(@"RT IS INACTIVE");
            [_gameScene rtIsActive:YES];
            return 1;
        }
        
    }
    
    NSLog(@"RT IS INACTIVE, FIRING UP");
    
    [_gcController initRealTimeConnection];
    
    [_gameScene rtIsActive:NO];
    return 0;
    
}

-(void)receiveRTPacket:(NSData*)packet {
    
    
    if (!_animating) {
        
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc]initForReadingWithData:packet];
        
        RTMessageType type = [unarchiver decodeIntForKey:@"type"];
        
        //NSLog(@"receiving packet of type: %@ size %d", [self stringForMessageType:type], packet.length);
        
        [_gameScene receiveRTPacket];
        
        if (type == RTMessageNone) {
            return;
        }
        
        else if (type == RTMessagePerformSequence) {
            
            GameSequence *sequence = [unarchiver decodeObjectForKey:@"sequence"];
            
            if (sequence.index == sequenceIndex+1) { // WE ARE CURRENT
                
                [self setUpPointersForSequenceArray:sequence];
                
                
                
                [self performSequence:sequence record:NO animate:YES];
                
            }
            
            else {
                NSLog(@"NOT IN SYNC - CATCHING UP IF POSSIBLE LATEST ACTION");
                [self fetchThisTurnSequences];
                
            }
            
            
        }
        else if (type == RTMessageShowSequence) {
            
            
            GameSequence *sequence = [unarchiver decodeObjectForKey:@"sequence"];
            
            [self setUpPointersForSequenceArray:sequence];
            
            for (GameEvent* e in sequence.GameEvents) {
                [self getPlayerPointersForEvent:e];
            }
            
            _currentEventSequence = sequence;
            
            [_gameScene addNetworkUIForEvent:[_currentEventSequence.GameEvents lastObject]];
            
            
        }
        
        else if (type == RTMessageCancelSequence){
            
            [self clearSelection];
            
        }
        
        else if (type == RTMessageCheckTurn){
            
            
            [self fetchThisTurnSequences];
            
            
        }
        
        else if (type == RTMessageSortCards){
            
            
            [_gameScene sortHandForManager:_opponent animated:YES];
            
            
        }
        
        else if (type == RTMessageBeginCardTouch || type == RTMessageMoveCardTouch){
            
            // BoardLocation *location = [unarchiver decodeObjectForKey:@"location"];
            // //Card *c = [self cardInHandForManager:_opponent location:location];
            //
            // CGPoint touch = [unarchiver decodeCGPointForKey:@"touch"];
            // CGSize inSize = [unarchiver decodeCGSizeForKey:@"bounds"];
            // CGSize outSize = [[UIScreen mainScreen] bounds].size;
            //
            // float xScale = outSize.width / inSize.width;
            // float yScale = outSize.height / inSize.height;
            //
            // CGPoint pos = CGPointMake(touch.x * xScale, touch.y * yScale);
            //
            // if (type == RTMessageBeginCardTouch) {
            //
            // [_gameScene opponentBeganCardTouch:c atPoint:pos];
            //
            // }
            //
            // else if (type == RTMessageMoveCardTouch) {
            //
            // [_gameScene opponentMovedCardTouch:c atPoint:pos];
            //
            // }
            
        }
        
        else if (type == RTMessagePlayer) {
            
        }
        
    }
    
    else {
        
        NSLog(@"already animating, check back later . . .");
    }
    
    
}


-(void)sendSequence:(GameSequence*)sequence perform:(BOOL)perform {
    
    if (_myTurn || perform) {
        
        
        if (_rtmatch) {
            
            NSMutableData* packet = [[NSMutableData alloc]init];
            
            NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc]initForWritingWithMutableData:packet];
            
            int type;
            
            if (perform) {
                type = RTMessagePerformSequence;
            }
            else {
                type = RTMessageShowSequence;
            }
            
            [archiver encodeInt:type forKey:@"type"];
            [archiver encodeObject:sequence forKey:@"sequence"];
            
            [archiver finishEncoding];
            
            NSLog(@"sending packet of type: %@ size %d", [self stringForMessageType:type], packet.length);
            
            [_rtmatch sendDataToAllPlayers:packet withDataMode:GKMatchSendDataReliable error:nil];
            
        }
        
        
    }
    
}


-(void)sendRTPacketWithType:(RTMessageType)type point:(BoardLocation*)location {
    
    if (_myTurn) {
        if (_rtmatch) {
            
            NSMutableData* packet = [[NSMutableData alloc]init];
            
            NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc]initForWritingWithMutableData:packet];
            
            [archiver encodeInt:type forKey:@"type"];
            [archiver encodeObject:location forKey:@"location"];
            
            [archiver finishEncoding];
            NSLog(@"sending packet of type: %@ size %d", [self stringForMessageType:type], packet.length);
            
            [_rtmatch sendDataToAllPlayers:packet withDataMode:GKMatchSendDataReliable error:nil];
            
            
        }
    }
    
}

-(void)sendRTPacketWithCard:(Card*)c point:(CGPoint)touch began:(BOOL)began{
    
    if (_myTurn) {
        
        if (_rtmatch) {
            
            RTMessageType type;
            if (began) {
                type = RTMessageBeginCardTouch;
            }
            else{
                type = RTMessageMoveCardTouch;
            }
            
            NSMutableData* packet = [[NSMutableData alloc]init];
            
            NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc]initForWritingWithMutableData:packet];
            
            [archiver encodeInt:type forKey:@"type"];
            [archiver encodeObject:c.location forKey:@"location"];
            [archiver encodeCGPoint:touch forKey:@"touch"];
            [archiver encodeCGSize:[[UIScreen mainScreen] bounds].size forKey:@"bounds"];
            
            [archiver finishEncoding];
            NSLog(@"sending packet of type: %@ size %d", [self stringForMessageType:type], packet.length);
            
            [_rtmatch sendDataToAllPlayers:packet withDataMode:GKMatchSendDataReliable error:nil];
            
        }
    }
    
}

-(NSString*)stringForMessageType:(RTMessageType)type {
    NSString *stype;
    
    if (type == RTMessagePlayer) {
        stype = @"RTMessagePlayer";
    }
    else if (type == RTMessageBeginCardTouch) {
        stype = @"RTMessageBeginCardTouch";
    }
    else if (type == RTMessageMoveCardTouch) {
        stype = @"RTMessageMoveCardTouch";
    }
    else if (type == RTMessagePerformSequence) {
        stype = @"RTMessagePerformSequence";
    }
    else if (type == RTMessageShowSequence) {
        stype = @"RTMessageShowSequence";
    }
    else if (type == RTMessageCancelSequence) {
        stype = @"RTMessageCancelSequence";
    }
    else if (type == RTMessageCheckTurn) {
        stype = @"RTMessageCheckTurn";
    }
    
    else {
        stype = @"RT-TYPE-UNKNOWN";
    }
    return stype;
    
}

#pragma mark - ARCHIVING

- (void)restoreGameWithData:(NSData*)comp {
    
    NSLog(@"compressed size: %d", comp.length);
    NSData *data = [comp gzipInflate];
    
    //NSData *data = comp;
    NSLog(@"uncompressed size: %d", data.length);
    
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc]initForReadingWithData:data];
    
    _matchInfo = [[unarchiver decodeObjectForKey:@"matchInfo"] mutableCopy];
    
    [_matchInfo setObject:[NSNumber numberWithInt:_history.count] forKey:@"turns"];
    
    _rtmatchid = [[_matchInfo objectForKey:@"rtmatchid"]unsignedIntegerValue];
    //BOARD_LENGTH = [[_matchInfo objectForKey:@"boardLength"]intValue];
    
    NSLog(@"(* (* (* unpack rt id %lu *) *) *)", (unsigned long)_rtmatchid);
    
    [self checkRTConnection];
    
    for (GKTurnBasedParticipant *p in _match.participants) {
        if (p.playerID) {
            
            if ([p.playerID isEqualToString:[GKLocalPlayer localPlayer].playerID]) {
                _me = [unarchiver decodeObjectForKey:[GKLocalPlayer localPlayer].playerID];
            }
            
            else {
                _opponent = [unarchiver decodeObjectForKey:p.playerID];
            }
        }
        
    }
    
    if (!_opponent) {
        _opponent = [unarchiver decodeObjectForKey:NEWPLAYER];
        
    }
    
    else if (!_me) {
        _me = [unarchiver decodeObjectForKey:NEWPLAYER];
    }
    
    
    [self loadSequencesFromUnarchiver:unarchiver];
    
    
    
}

-(void)loadSequencesFromUnarchiver:(NSKeyedUnarchiver*)unarchiver {
    
    _history = [[unarchiver decodeObjectForKey:@"history"] mutableCopy];
    _thisTurnSequences = [[unarchiver decodeObjectForKey:@"thisTurnSequences"] mutableCopy];
    
    for (NSArray* turn in _history) {
        for (GameSequence *sequence in turn) {
            [self setUpPointersForSequenceArray:sequence];
        }
    }
    for (GameSequence *sequence in _thisTurnSequences) {
        [self setUpPointersForSequenceArray:sequence];
    }
    
    if (!_thisTurnSequences) {
        _thisTurnSequences = [NSMutableArray array];
    }
    
}

-(void)setUpPointersForSequenceArray:(GameSequence*)sequence{
    
    for (int i =0; i<sequence.GameEvents.count; i++) {
        GameEvent *e = sequence.GameEvents[i];
        e.parent = sequence;
        e.manager = [self managerForTeamSide:e.teamSide];
    }
    
    
}

-(void)saveTurnWithCompletionBlock:(void (^)())block {
    
    // [_match saveCurrentTurnWithMatchData:[self saveGameToData] completionHandler:^(NSError *error){
    // if (error) {
    // NSLog(@"%@", error);
    // }
    //
    // NSLog(@"**** FINISH SAVING GAME STATE ****");
    // [self logCurrentGameData];
    //
    // [self sendRTPacketWithType:RTMessageCheckTurn point:nil];
    //
    // block();
    //
    // }];
    
}

- (NSData*)saveGameToData {
    
    NSMutableData* data = [[NSMutableData alloc] init];
    
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    
    for (GKTurnBasedParticipant *p in _match.participants) {
        
        
        if ([p.playerID isEqualToString:[GKLocalPlayer localPlayer].playerID]) {
            [archiver encodeObject:_me forKey:[GKLocalPlayer localPlayer].playerID];
            [_matchInfo setObject:[self metaDataForManager:_me] forKey:[GKLocalPlayer localPlayer].playerID];
            //NSLog(@"archiving %@ me to: %@", key, [NSString stringWithFormat:@"%@%@",key,[GKLocalPlayer localPlayer].playerID]);
        }
        
        else {
            if (p.playerID) {
                [_matchInfo setObject:[self metaDataForManager:_opponent] forKey:p.playerID];
                [_matchInfo removeObjectForKey:NEWPLAYER];
                
                [archiver encodeObject:_opponent forKey:p.playerID];
                // NSLog(@"archiving %@ op to: %@", key, [NSString stringWithFormat:@"%@%@",key,p.playerID]);
            }
            else {
                [_matchInfo setObject:[self metaDataForManager:_opponent] forKey:NEWPLAYER];
                [archiver encodeObject:_opponent forKey:NEWPLAYER];
                //NSLog(@"archiving %@ op to: %@", key, [NSString stringWithFormat:@"%@%@",key,NEWPLAYER]);
            }
            
        }
        
    }
    
    NSLog(@"------ SAVING . . .");
    [self logCurrentGameData];
    
    
    [archiver encodeObject:_history forKey:@"history"];
    [archiver encodeObject:_thisTurnSequences forKey:@"thisTurnSequences"];
    
    
    
    // MATCH DATA
    
    [_matchInfo setObject:[NSNumber numberWithInt:_history.count] forKey:@"turns"];
    
    [archiver encodeObject:_matchInfo forKey:@"matchInfo"];
    
    
    
    [archiver finishEncoding];
    
    NSLog(@"match data size: %d", data.length);
    
    //return data;
    
    return [data gzipDeflate];
    
}

-(void)logCurrentGameData {
    NSLog(@"**--**-- CURRENT GAME DATA --**--**");
    NSLog(@"history is %d turns", _history.count);
    NSLog(@"this turn has %d sequences", _thisTurnSequences.count);
    NSLog(@"**** TOTAL ACTIONS: %d EVENTS:%d ****", [self totalGameSequences], [self totalEvents]);
    NSString *realtime = @"INACTIVE";
    
    if (rtIsActive) {
        realtime = @"** ACTIVE **";
    }
    //NSLog(@"REAL-TIME IS %@", realtime);
    
    
}


-(NSArray*)copySequencesFrom:(NSArray*)src {
    
    NSMutableArray *tmp = [[NSMutableArray alloc] initWithCapacity:10];
    
    for (GameSequence* a in src) {
        
        [tmp addObject:a];
        
    }
    
    return tmp;
    
}

-(void)prepEndTurn {
    
    [_matchInfo setObject:_opponent.name forKey:@"current player"];
    
    [_history addObject:[_thisTurnSequences copy]];
    
    _thisTurnSequences = Nil;
    
}

-(void)endTurn {
    
    _animating = NO;
    
    [self prepEndTurn];
    
    NSUInteger currentIndex = [_match.participants
                               indexOfObject:_match.currentParticipant];
    
    GKTurnBasedParticipant *nextParticipant;
    
    nextParticipant = [_match.participants objectAtIndex:
                       ((currentIndex + 1) % [_match.participants count ])];
    
    [_match endTurnWithNextParticipants:@[nextParticipant] turnTimeout:GKTurnTimeoutNone matchData:[self saveGameToData] completionHandler:^(NSError *error) {
        if (error) {
            NSLog(@"%@", error);
        }
        
        NSLog(@"Game.m : endTurn : ENDING TURN: NEXT IS: %@", nextParticipant.playerID);
        NSLog(@"**** ACTIONS: %d EVENTS:%d ****", [self totalGameSequences], [self totalEvents]);
        
        _myTurn = NO;
        [self setCurrentManagerFromMatch];
        
        [_gameScene refreshScoreBoard];
        
        
        double delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self sendRTPacketWithType:RTMessageCheckTurn point:nil];
        });
        
    }];
    
}




-(void)endGame{
    
    
    // CHECK VICTORY
    [self prepEndTurn];
    
    
    BOOL victory = NO;
    
    if (_me.teamSide) {
        if (_score.y > _score.x) {
            victory = YES;
        }
    }
    else {
        if (_score.x > _score.y) {
            victory = YES;
        }
    }
    
    
    [self endGameWithWinner:victory];
    
    
}

-(void)endGameWithWinner:(BOOL)victory {
    
    
    NSLog(@"game.m : endGame : victory %d", victory);
    
    // DO GAME CENTER SHIT
    
    NSString *opID;
    GKScore *opScore;
    
    for (GKTurnBasedParticipant *p in _match.participants) {
        if (![p.playerID isEqualToString:[GKLocalPlayer localPlayer].playerID ]) { // Opponent
            opID = p.playerID;
            
            opScore = [[GKScore alloc] initWithLeaderboardIdentifier:@"nsfwLeaders" forPlayer:opID];
            
            if (victory) {
                p.matchOutcome = GKTurnBasedMatchOutcomeLost;
            }
            else {
                p.matchOutcome = GKTurnBasedMatchOutcomeWon;
            }
            
        }
        else { // me
            if (victory) {
                p.matchOutcome = GKTurnBasedMatchOutcomeWon;
            }
            else {
                p.matchOutcome = GKTurnBasedMatchOutcomeLost;
            }
            
        }
    }
    
    GKScore *meScore = [[GKScore alloc] initWithLeaderboardIdentifier:@"nsfwLeaders"];
    
    
    if (_me.teamSide) {
        [meScore setValue:_score.y];
        [opScore setValue:_score.x];
    }
    else {
        [meScore setValue:_score.x];
        [opScore setValue:_score.y];
    }
    
    if (opID) {
        NSLog(@"game.m : endGame : ending without valid Opponent!");
        [_match endMatchInTurnWithMatchData:[self saveGameToData] scores:@[meScore, opScore] achievements:Nil completionHandler:^(NSError *error){
            [_match loadMatchDataWithCompletionHandler:^(NSData *matchData, NSError *error){
                _myTurn = NO;
            }];
            
        }];
    }
    
    else {
        NSLog(@"game.m : endGame : ending with valid Opponent!");
        [_match endMatchInTurnWithMatchData:[self saveGameToData] scores:@[meScore] achievements:Nil completionHandler:^(NSError *error){
            _myTurn = NO;
        }];
    }
    
    //#warning lame o work around for game center
    //UIWindow *window = [UIApplication sharedApplication].keyWindow;
    // SKViewController *rootViewController = (SKViewController*)window.rootViewController;
    // [rootViewController performSelector:@selector(showGK) withObject:Nil afterDelay:2.0];
    
}

-(void)setMyTurn:(BOOL)myTurn {
    _myTurn = myTurn;
    [_gameScene setMyTurn:myTurn];
}


-(void)getSortedPlayerNames {
    
    NSMutableArray *ids = [NSMutableArray array];
    
    for (GKPlayer *p in _match.participants) {
        if (p.playerID) {
            [ids addObject:p.playerID];
        }
    }
    
    [GKPlayer loadPlayersForIdentifiers:ids withCompletionHandler:^(NSArray *players, NSError *error) {
        if (error != nil)
        {
            NSLog(@"Error receiving player data");
            // Handle the error.
        }
        if (players != nil)
        {
            
            NSString *myName;
            NSString *opponentName;
            
            for (GKPlayer *p in players) {
                
                if ([p.playerID isEqualToString:[GKLocalPlayer localPlayer].playerID]) {
                    
                    myName = p.displayName;
                    
                }
            }
            
            for (GKPlayer *p in players) {
                
                if (![p.playerID isEqualToString:[GKLocalPlayer localPlayer].playerID]) {
                    
                    opponentName = p.displayName;
                    
                }
            }
            
            if (_me) {
                if (!opponentName) opponentName = NEWPLAYER;
                if (_me.teamSide == 0) {
                    _playerNames = @[myName, opponentName];
                }
                else {
                    _playerNames = @[opponentName, myName];
                }
                
            }
            
            NSLog(@"player names %@", _playerNames);
            
        }
    }];
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    [_gameScene setWaiting:NO];
    
    if (buttonIndex) {
        
        [self replayGame:YES];
        
    }
    
    else {
        
        [self replayGame:NO];
        
        
    }
    
}


@end
