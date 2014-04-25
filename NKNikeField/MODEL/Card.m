//
//  Card.m
//  CardDeck
//
//  Created by Robby Kraft on 9/17/13.
//  Copyright (c) 2013 Robby Kraft. All rights reserved.
//

#import "ModelHeaders.h"


@interface Card (){
}
@end

@implementation Card

- (id)copyWithZone:(NSZone *)zone{
    return self;
}

-(id)initWithDeck:(Deck*)deck {
    self = [super init];
    if(self){
        _deck = deck;
        _abilities = [[Abilities alloc]init];
        _actionPointEarn = 0;
        _actionPointCost = 0;
        _aiActionType = NONE;
        switch (_deck.category) {
            case CardCategoryMove:
                _level = 2;
                _moveCategory = rand()%4 + 1;
                _kickCategory = CardKickCategoryNull;
                break;
            case CardCategoryKick:
                _kickCategory = rand()%3 + 1;
                //_kickCategory = 3;
                if(_kickCategory == CardKickCategoryStraight){
                    _level = 5;
                }
                if(_kickCategory == CardKickCategoryLob){
                    _level = 4;
                }
                else{
                    _level = 2;
                }
                _moveCategory = CardMoveCategoryNull;
#ifdef CHEAT
                _level = 10;
#endif
                break;
            
            case CardCategoryChallenge:
                _level = 1;
                break;
                
            default:
                break;
        }
        
        if (_deck.category == CardCategorySpecial){
            int special = rand() % 3;
            switch (special) {
                case 0:
                    self.specialCategory = CardCategoryMove;
                            _level = rand()%2 + 1;
                    break;
                case 1:
                    self.specialCategory = CardCategoryKick;
                            _level = rand()%3 + 2;
                    break;
                case 2:
                    self.specialCategory = CardCategoryChallenge;
                            _level = rand()%2 + 1;
                    break;
                default:
                    self.specialCategory = CardCategoryMove;
                            _level = rand()%3 + 1;
                    break;
            }
        }
        
        _range = _level;
        if (_level > 3) _level = 3;
        
    }
    return self;
}

-(CardCategory)category{
    if (_deck.category == CardCategorySpecial) {
        return self.specialCategory;
    }
    else {
        return _deck.category;
    }
}

-(void)setDeck:(Deck *)deck {
    _deck = deck;
}

-(void)setLocation:(BoardLocation *)location {
    _location = [location copy];
}


-(EventType)discardAfterEventType {

    return kNullAction;
}

-(BOOL)isTemporary {

    return NO;
}

-(NSString*)nameOrGeneric {
    if (_name) {
        return _name;
    }
    
    else {
        switch (self.category) {
            case CardCategoryKick:
                return @"KICK";
                break;
                
            case CardCategoryMove:
                return @"MOVE";
                break;
                
            case CardCategoryChallenge:
                return @"CHALLENGE";
                break;
                
            case CardCategorySpecial:
                switch (self.category) {
                    case CardCategoryKick:
                        return @"SPECIAL KICK";
                        break;
                        
                    case CardCategoryMove:
                        return @"SPECIAL MOVE";
                        break;
                        
                    case CardCategoryChallenge:
                        return @"SPECIAL CHALLENGE";
                        break;
                        
                    default:
                        return @"UNKNOWN SPECIAL";
                        break;
                }
                break;

            default:
                return @"ERROR, fix name or generic";
                break;
        }
   
    }

}

-(NSString*)bigCardImageString {
    //Kick_L1a.png
    
    switch (_deck.category) {
        case CardCategoryMove: return @"Move";
        case CardCategoryKick: return @"Kick";
        case CardCategoryChallenge: return @"Chal";
        case CardCategorySpecial:
            switch (_specialCategory) {
                case CardCategoryMove: return @"Special";
                case CardCategoryKick: return @"Special";
                case CardCategoryChallenge: return @"Special";
                default: break;
            }
            
        default:
            break;
    }
    return @"NIL";
}

-(NSString*)thumbnailImageString {
    switch (_deck.category) {
        case CardCategoryMove: return @"Move";
        case CardCategoryKick: return @"Kick";
        case CardCategoryChallenge: return @"Chal";
        case CardCategorySpecial:
            switch (_specialCategory) {
                case CardCategoryMove: return @"SpecM";
                case CardCategoryKick: return @"SpecK";
                case CardCategoryChallenge: return @"SpecC";
                default: break;
            }
            
        default:
            break;
    }
    return @"NIL";
}

-(NSString*)fileNameForBigCard {
    NSString *fileName = [NSString stringWithFormat:@"%@_L%da", [self bigCardImageString], _level];
    return fileName;
}

-(NSString*)fileNameForThumbnail {
    NSString *fileName = [NSString stringWithFormat:@"Card_Icon_%@_L%d", [self thumbnailImageString], _level];
    return fileName;
}


-(void)play {
    if ([_deck.inHand containsObject:self]){
        [_deck playCardFromHand:self];
    }
    else if ([_deck.theDeck containsObject:self]){
        [_deck playCardFromDeck:self];
    }
}

-(void)discard {
    
    if ([_deck.inGame containsObject:self]) {
          [_deck discardCardFromGame:self];
    }
    else if ([_deck.inHand containsObject:self]){
           [_deck discardCardFromHand:self];
    }
    else if ([_deck.theDeck containsObject:self]){
        [_deck discardCardFromDeck:self];
    }
    else {
        NSLog(@"discarding card that isn't located anywhere . . .");
    }
  
}

-(NSString*)name {
    return [self nameOrGeneric];
}

-(NSString*) descriptionForCard  {
    
//    if(_cardCategory == kCardCategoryActionHeader) return @"GOAL KICK ON \n SUCCESSFUL PASS";
//    if(_cardCategory == kCardCategoryActionSlideTackle) return @"Slide Tackle";
//    if(_cardCategory == kCardCategoryActionKamikazeKick) return @"Kamikaze Kick";
//      if(_cardCategory == kCardCategoryActionAdrenalBoost) return [NSString stringWithFormat:@"GET %d BONUS \n AP", _actionPointEarn];
//    if(_cardCategory == kCardCategoryActionAdrenalFlood) return [NSString stringWithFormat:@"GET %d BONUS \n AP", _actionPointEarn];
//    
//    if(_cardCategory == kCardCategoryActionMercurialAcceleration) return @"Mercurial Acceleration";
//    
//    if(_cardCategory == kCardCategoryActionPredictiveAnalysis1) return [NSString stringWithFormat:@"CHALLENGE \n WITH +%@", [self pP:_abilities.handling]];
//    if(_cardCategory == kCardCategoryActionPredictiveAnalysis2) return [NSString stringWithFormat:@"CHALLENGE \n WITH +%@", [self pP:_abilities.handling]];
//    
//    if(_cardCategory == kCardCategoryActionNeuralTriggerFear) return @"Neural Trigger Fear";
//    if(_cardCategory == kCardCategoryActionAutoPlayerTrackingSystem) return @"Auto Player  Tracking System";
//    
    return @"add card descriptions";
    
    
}

-(NSString*) pP:(float)p {
    
    return [NSString stringWithFormat:@"%d%%", (int)(p * 100)];

}

-(void)setEnchantee:(Player *)enchantee {
    _enchantee = enchantee;
    if (enchantee) {
         _location = [enchantee.location copy];
    }
}

#pragma mark - INTERROGATION

-(Game*)game {
    return self.deck.player.manager.game;
}

-(NSArray*)rangeMask {
    
    BoardLocation *center = [_deck.player.location copy];
    
    NSMutableArray *obstacles = [[self.game allBoardLocations] mutableCopy];
    
    NSLog(@"obstacles for %d,%d, range %d", center.x, center.y, _range);
    for (int x = center.x - _range; x<=center.x + _range; x++){
        
        if (x >= 0 && x < 7) {
            
            for (int y = center.y - _range; y<=center.y + _range; y++){
                
                if (y >= 0 && y < 10) {
                    
                    [obstacles removeObject:[BoardLocation pX:x Y:y]];
                    
                }
            }
            
        }
        
    }
    
    
    return obstacles;
    
}

-(NSArray*)selectionSet {
   // NSLog(@"selectionSet...");
    
    if (self.category == CardCategoryKick) {
        if (!self.deck.player.ball) {
            return nil;
        }
    }
    
    NSMutableArray* obstacles = [[self rangeMask] mutableCopy];
   // NSMutableArray* obstacles = [[NSMutableArray alloc] init];
    
    
    // STEP 1:  GET BOARD OBSTACLES
    
    if (self.category == CardCategoryMove || self.category == CardCategoryChallenge) {
        for (Player* p in self.game.players) {
            [obstacles addObject:[p.location copy]];
        }
        if (self.category == CardCategoryChallenge) {
            [obstacles removeObject:[self.game.ball.location copy]];
        }
    }
    
    else if (self.category == CardCategoryKick) {
        for (Player* p in self.deck.player.manager.opponent.players.inGame) {
            [obstacles addObject:[p.location copy]];
        }
    }
    
    
    AStar *aStar = [[AStar alloc]initWithColumns:7 Rows:10 ObstaclesCells:obstacles];
    NSArray *accessible;
    
    // STEP 2: CALCULATE ACCESSIBLE WITH RANGE
    
    if (self.category == CardCategoryMove){
        switch(self.moveCategory){
            case CardMoveCategoryBishop:
                accessible = [aStar cellsAccesibleFromStraight:_deck.player.location NeighborhoodType:NeighborhoodTypeBishopStraight walkDistance:_range];
                break;
            case CardMoveCategoryQueen:
                accessible = [aStar cellsAccesibleFromStraight:_deck.player.location NeighborhoodType:NeighborhoodTypeQueenStraight walkDistance:_range];
                break;
            case CardMoveCategoryRook:
                accessible = [aStar cellsAccesibleFromStraight:_deck.player.location NeighborhoodType:NeighborhoodTypeRookStraight walkDistance:_range];
                break;
            case CardMoveCategoryKnight:
                accessible = [aStar cellsAccesibleFromStraight:_deck.player.location NeighborhoodType:NeighborhoodTypeKnightStraight walkDistance:_range];
                break;
            case CardMoveCategoryNull:
                accessible = NULL;
                break;
            default:
                accessible = NULL;
                break;
        }
    }
    else if (self.category == CardCategoryChallenge) {
        accessible = [aStar cellsAccesibleFrom:_deck.player.location NeighborhoodType:NeighborhoodTypeQueen walkDistance:_range];
    }
    else if (self.category == CardCategoryKick) {
        switch(self.kickCategory){
            case CardKickCategoryStraight:
                accessible = [aStar cellsAccesibleFromStraight:_deck.player.location NeighborhoodType:NeighborhoodTypeQueenStraight walkDistance:_range];
                break;
            case CardKickCategoryLob:
                accessible = [aStar cellsAccesibleFromStraight:_deck.player.location NeighborhoodType:NeighborhoodTypeQueenLobStraight walkDistance:_range];
                break;
            case CardKickCategoryBeckem:
                accessible = [aStar cellsAccesibleFromStraight:_deck.player.location NeighborhoodType:NeighborhoodTypeKnightStraight walkDistance:_range];
                break;
            default:
                accessible = NULL;
                break;
        }
    }
    else{
        accessible = NULL;
    }
    
    return accessible;
    
}

-(NSArray*)validatedSelectionSet {
  //  NSLog(@"validatedSelectionSet...");

    NSArray* accessible = [self selectionSet];
    
    // IF MOVING / KICK WE'RE DONE VALIDATING
    
    if (self.category == CardCategoryMove || self.category == CardCategoryKick){
        return accessible;
    }
    
    // ELSE LIMIT TO POSSIBLE PLAYER TARGETS
    
    NSMutableArray* set = [NSMutableArray array];
    
    // KICK NOW SHOWS ALL ACCESSIBLE
    
//    if (self.category == CardCategoryKick) {
//        for (Player* p in self.deck.player.manager.players.inGame) {
//            if ([accessible containsObject:p.location]){
//                [set addObject:p.location];
//            }
//        }
//        if ([accessible containsObject:self.deck.player.manager.goal]) {
//            [set addObject:self.deck.player.manager.goal];
//        }
//        
//        [set removeObject:self.deck.player.location];
//    }
    
    if (self.category == CardCategoryChallenge) {
        for (Player* p in self.deck.player.manager.opponent.players.inGame) {
            if (p.ball) {
                if ([accessible containsObject:p.location]) {
                    [set addObject:p.location];
                }
            }
        }
    }
    
    if (!set.count) return nil;
    
    return set;
}


-(NSArray*)validatedPath:(NSArray*)path{
    NSLog(@"validatedPath, self.range = %d, input.count = %d", [self range], [path count]);
    if(path){
        // NSArray* reversedPath = [[path reverseObjectEnumerator] allObjects];
        // NSArray* reversedPath = [[path reverseObjectEnumerator] allObjects];
        // for(BoardLocation *l in path){
        //     NSLog(@"%@", l);
        // }
        if([path count] >= [self range]){
            NSArray *retPath = [path subarrayWithRange:NSMakeRange(0, [self range])];
            NSLog(@"validatedPath, output.count = %d", [retPath count]);
            return retPath;
        }
        else{
            return NULL;
        }
    }
    else {
        return NULL;
    }
}


#pragma mark - ENCODING

//-(NSArray*)aArray {
//    
//    return @[@"type",               //0
//             @"manager",            //1
//
//             @"name",               //2
//             
//             @"actionPointEarn",    //3
//             @"actionPointCost",    //4
//
//             @"abilities",          //5
//             @"nearOpponentModifiers",//6
//             @"nearTeamModifiers",  //7
//             @"opponentModifiers",  //8
//             @"teamModifiers"];     //9
//}

- (id)initWithCoder:(NSCoder *)decoder {

    self = [super init];
    
    if (self) {
   
    _specialCategory = [decoder decodeIntForKey:NSFWKeyType];
    _deck = [decoder decodeObjectForKey:NSFWKeyPlayer];
    
    _name = [decoder decodeObjectForKey:NSFWKeyName];
        
    _actionPointEarn = [decoder decodeIntForKey:NSFWKeyActionPointEarn];
    _actionPointCost = [decoder decodeIntForKey:NSFWKeyActionPointCost];
    _level = [decoder decodeIntForKey:NSFWKeyCardLevel];
    _range = [decoder decodeIntForKey:NSFWKeyCardRange];
        
    _abilities = [decoder decodeObjectForKey:NSFWKeyAbilities];

        
    }
    
    return self;
    
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    
    [encoder encodeInt:_specialCategory forKey:NSFWKeyType];
    [encoder encodeObject:_deck forKey:NSFWKeyPlayer];

    [encoder encodeObject:_name forKey:NSFWKeyName];
    
    [encoder encodeInteger:_actionPointEarn forKey:NSFWKeyActionPointEarn];
    [encoder encodeInteger:_actionPointCost forKey:NSFWKeyActionPointCost];
    [encoder encodeInteger:_level forKey:NSFWKeyCardLevel];
    [encoder encodeInteger:_range forKey:NSFWKeyCardRange];
    
    [self encodeAbilities:_abilities with:encoder forKey:NSFWKeyAbilities];

    
}

-(void)encodeAbilities:(Abilities*)a with:(NSCoder *)encoder forKey:(NSString*)s{
    if (a.persist) {
        [encoder encodeObject:a forKey:s];
    }
}

@end

@implementation Abilities

#pragma mark ABILITIES NSCODER

-(NSArray*)aArray {
    
    return @[@"kick",
             @"move",
             @"challenge",
             @"dribble",
             @"pass",
             @"shoot",
             @"save"];
}

-(instancetype)init {
    self = [super init];
    if (self) {
        _persist = YES;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
    
    BOOL persist = [decoder decodeBoolForKey:@"persist"];
    
    if (!persist) {
        return nil;
    }
         
    self = [super init];
    
    if (self) {
        NSArray *a = [self aArray];

        _persist = persist;
        _kick = [decoder decodeInt32ForKey:a[0]];
        _move = [decoder decodeInt32ForKey:a[1]];
        _challenge = [decoder decodeInt32ForKey:a[2]];
        
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    
    
    if (!_persist) {
        return;
    }
    
    
    NSArray *a = [self aArray];
    
    [encoder encodeBool:YES forKey:@"persist"];
    [encoder encodeInt32:_kick forKey:a[0]];
    [encoder encodeInt32:_move forKey:a[1]];
    [encoder encodeInt32:_challenge forKey:a[2]];

    
}

-(instancetype)copy {
    Abilities *a = [[Abilities alloc] init];
    
    a.kick = _kick;
    a.move = _move;
    a.challenge = _challenge;

    
    return a;
}

-(void)add:(Abilities*)modifier {
    
    _kick += modifier.kick;
    _move += modifier.move;
    _challenge += modifier.challenge;
    
}

@end