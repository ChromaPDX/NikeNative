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

-(void)getRandomKickAttributes {
    _kickCategory = rand()%3 + 1;
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
    _challengeCategory = CardChallengeCategoryNull;
    _specialTypeCategory = CardSpecialCategoryNull;
    _specialCategory = CardCategoryNull;
}

-(void)getRandomMoveAttributes {
    _level = 2;
    _moveCategory = rand()%4 + 1;
    _kickCategory = CardKickCategoryNull;
    _challengeCategory = CardChallengeCategoryNull;
    _specialTypeCategory = CardSpecialCategoryNull;
    _specialCategory = CardCategoryNull;
}

-(void)getRandomChallengeAttributes {
    _level = 1;
    _challengeCategory = rand()%3 + 1;
    _kickCategory = CardKickCategoryNull;
    _moveCategory = CardMoveCategoryNull;
    _specialCategory = CardCategoryNull;
    _specialTypeCategory = CardSpecialCategoryNull;
}

-(void)getRandomSpecialAttributes {
    _level = 1;
    _kickCategory = CardKickCategoryNull;
    _moveCategory = CardMoveCategoryNull;
    _challengeCategory = CardChallengeCategoryNull;
    _specialTypeCategory = rand() % 7 + 1;
    switch (_specialTypeCategory) {
        case CardSpecialCategoryFreeze:
            self.specialCategory = CardCategoryGeneral;
            break;
        case CardSpecialCategoryNoLegs:
            self.specialCategory = CardCategoryGeneral;
            break;
        case CardSpecialCategoryBlock:
            self.specialCategory = CardCategoryGeneral;
            break;
        case CardSpecialCategoryDeRez:
            self.specialCategory = CardCategoryGeneral;
            break;
        case CardSpecialCategoryNewDeal:
            self.specialCategory = CardCategoryGeneral;
            break;
        case CardSpecialCategoryPredictiveAnalysis:
            self.specialCategory = CardCategoryGeneral;
            break;
        case CardSpecialCategorySuccubus:
            self.specialCategory = CardCategoryGeneral;
            break;
        default:
            self.specialCategory = CardCategoryGeneral;
            break;
    }
}

-(void)getEnergyCost{
    switch(self.specialTypeCategory){
        case CardSpecialCategoryDeRez:
            self.energyCost = 1000;
            return;
        case CardSpecialCategoryBlock:
            self.energyCost = 200;
            return;
        case CardSpecialCategoryFreeze:
            self.energyCost = 200;
            return;
        case CardSpecialCategoryNewDeal:
            self.energyCost = 50;
            return;
        case CardSpecialCategoryNoLegs:
            self.energyCost = 100;
            return;
        case CardSpecialCategoryPredictiveAnalysis:
            self.energyCost = 50;
            return;
        case CardSpecialCategorySuccubus:
            self.energyCost = 100;
            return;
        default:
            self.energyCost = 0;
            return;
    }
}

-(id)initWithDeck:(Deck*)deck {
    self = [super init];
    if(self){
        _deck = deck;
        _abilities = [[Abilities alloc]init];
        _aiActionType = NONE;
        //_energyCost = 0;
        
        switch (_deck.category) {
            case CardCategoryMove:
                [self getRandomMoveAttributes];
                break;
            case CardCategoryKick:
                [self getRandomKickAttributes];
                break;
            case CardCategoryChallenge:
                [self getRandomChallengeAttributes];
                break;
            case CardCategorySpecial:
                [self getRandomSpecialAttributes];
                break;
            default:
                break;
        }
        [self getEnergyCost];

       
        _range = _level;
        if (_level > 3) _level = 3;
        
        if (_deck.category == CardCategorySpecial) {
            _energyCost = _level*100;
        }
        
    }
    return self;
}

-(CardCategory)category{
    if (_deck.category == CardCategorySpecial) {
       // return self.specialCategory;
        return _deck.category;
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
        case CardCategoryChallenge: return @"Challenge";
        case CardCategorySpecial:
            switch(_specialCategory){
                case CardCategoryGeneral: return @"SpecialCards_General";
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
                case CardCategoryMove: return @"SpecGeneral";
                case CardCategoryKick: return @"SpecGeneral";
                case CardCategoryChallenge: return @"SpecGeneral";
                case CardCategoryGeneral: return @"SpecGeneral";
               // case CardCategoryGeneral: return
                default: break;
            }
        default:
            break;
    }
    return @"NIL";
}

-(NSString*)fileNameForBigCard {
    NSString *fileName;
    if(_deck.category == CardCategorySpecial){
        fileName = [NSString stringWithFormat:@"%@", [self bigCardImageString]];
    }
    else{
         fileName = [NSString stringWithFormat:@"%@_L%da", [self bigCardImageString], _level];
    }
    return fileName;
}

-(NSString*)fileNameForThumbnail {
    NSString *fileName;
    if(_deck.category == CardCategorySpecial){
        fileName = [NSString stringWithFormat:@"Card_Icon_%@", [self thumbnailImageString]];
    }
    else{
        fileName = [NSString stringWithFormat:@"Card_Icon_%@_L%d", [self thumbnailImageString], _level];
    }
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
    if(self.category == CardCategorySpecial){
        if(self.specialTypeCategory == CardSpecialCategoryNoLegs){
           
        }
        if(self.specialTypeCategory == CardSpecialCategoryFreeze){
            return @"FREEZE";
        }
        switch (self.specialTypeCategory) {
            case CardSpecialCategoryNoLegs:
                return @"NO LEGS";
                break;
            case CardSpecialCategoryFreeze:
                return @"FREEZE";
                break;
            case CardSpecialCategoryBlock:
                return @"BLOCK";
                break;
            case CardSpecialCategorySuccubus:
                return @"SUCCUBUS";
                break;
            case CardSpecialCategoryDeRez:
                return @"DE-REZ";
                break;
            case CardSpecialCategoryNewDeal:
                return @"NEW DEAL";
                break;
            case CardSpecialCategoryPredictiveAnalysis:
                return @"ANALYZ";
            default:
                break;
        }
    }
    return @"##NONE##";
    
    
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
    return self.deck.manager.game;
}

-(NSArray*)rangeMaskForPlayer:(Player*)p {
    
    BoardLocation *center = [[p location] copy];
    
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

-(NSArray*)selectionSetForPlayer:(Player*)p {
    if (!p) {
         NSLog(@"selectionSet with no player");
        return nil;
    }
    
    NSLog(@"selectionSet... for %@", self.name);
    
    
    if (self.category == CardCategoryKick) {
        
//        if (self.enchantee.effects[Card_NoLegs]){
//            int noLegs = [self.enchantee.effects[Card_NoLegs] intValue];
//            
//            if(noLegs <= 0){
//                [self.enchantee.effects removeObjectForKey:Card_NoLegs];
//                return nil;
//            }
//            else{
//                [self.enchantee.effects setObject:@(noLegs--) forKey:Card_NoLegs];
//            }
//        }
        
        if (!p.ball) {
            return nil;
        }
    }
    
    NSMutableArray* obstacles = [[self rangeMaskForPlayer:p] mutableCopy];
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
        NSLog(@"opponent count %d for %@", p.manager.opponent.players.inGame.count, p.manager.opponent.name);
        for (Card* c in p.manager.opponent.players.inGame) {
            NSLog(@"obstacle for %@", p.name);
            [obstacles addObject:[c.location copy]];
        }
    }
    
    
    AStar *aStar = [[AStar alloc]initWithColumns:7 Rows:10 ObstaclesCells:obstacles];
    NSMutableArray *accessible = [[NSMutableArray alloc] init];
    
    // STEP 2: CALCULATE ACCESSIBLE WITH RANGE
    
    if (self.category == CardCategoryMove){
        switch(self.moveCategory){
            case CardMoveCategoryBishop:
                accessible = [[aStar cellsAccesibleFromStraight:p.location NeighborhoodType:NeighborhoodTypeBishopStraight walkDistance:_range] mutableCopy];
                break;
            case CardMoveCategoryQueen:
                accessible = [[aStar cellsAccesibleFromStraight:p.location NeighborhoodType:NeighborhoodTypeQueenStraight walkDistance:_range] mutableCopy];
                break;
            case CardMoveCategoryRook:
                accessible = [[aStar cellsAccesibleFromStraight:p.location NeighborhoodType:NeighborhoodTypeRookStraight walkDistance:_range] mutableCopy];
                break;
            case CardMoveCategoryKnight:
                accessible = [[aStar cellsAccesibleFromStraight:p.location NeighborhoodType:NeighborhoodTypeKnightStraight walkDistance:_range]mutableCopy];
                break;
            case CardMoveCategoryNull:
                accessible = NULL;
                break;
            default:
                accessible = NULL;
                break;
        }
        
        accessible = [[accessible arrayByAddingObject:[p.location copy]] mutableCopy];
    }
    
    else if (self.category == CardCategoryChallenge) {
       //if(self.challengeCategory == CardChallengeCategoryRook){
       //     accessible = [[aStar cellsAccesibleFrom:p.location NeighborhoodType:NeighborhoodTypeRookStraight walkDistance:_range] mutableCopy];
       // }
        if (self.challengeCategory == CardChallengeCategoryBishop){
            accessible = [[aStar cellsAccesibleFrom:p.location NeighborhoodType:NeighborhoodTypeBishopStraight walkDistance:_range] mutableCopy];
        }
        else if (self.challengeCategory == CardChallengeCategoryHorizantal){
            accessible = [[aStar cellsAccesibleFrom:p.location NeighborhoodType:NeighborhoodTypeRookStraight walkDistance:_range] mutableCopy];
            BoardLocation *WLoc = [self.location stepInDirection:W];
            BoardLocation *ELoc = [self.location stepInDirection:E];
            if(WLoc){
                [accessible removeObject:WLoc];
            }
            if(ELoc){
                [accessible removeObject:ELoc];
            }
        }
        else if (self.challengeCategory == CardChallengeCategoryVertical){
            accessible = [[aStar cellsAccesibleFrom:p.location NeighborhoodType:NeighborhoodTypeRookStraight walkDistance:_range] mutableCopy];
            accessible = [[aStar cellsAccesibleFrom:p.location NeighborhoodType:NeighborhoodTypeRookStraight walkDistance:_range] mutableCopy];
            BoardLocation *NLoc = [self.location stepInDirection:W];
            BoardLocation *SLoc = [self.location stepInDirection:E];
            if(NLoc){
                [accessible removeObject:NLoc];
            }
            if(SLoc){
                [accessible removeObject:SLoc];
            }

        }
    }
    else if (self.category == CardCategoryKick) {
        switch(self.kickCategory){
            case CardKickCategoryStraight:
                accessible = [[aStar cellsAccesibleFromStraight:p.location NeighborhoodType:NeighborhoodTypeQueenStraight walkDistance:_range] mutableCopy];
                break;
            case CardKickCategoryLob:
                accessible = [[aStar cellsAccesibleFromStraight:p.location NeighborhoodType:NeighborhoodTypeQueenLobStraight walkDistance:_range] mutableCopy];
                break;
            case CardKickCategoryBeckem:
                accessible = [[aStar cellsAccesibleFromStraight:p.location NeighborhoodType:NeighborhoodTypeKnightStraight walkDistance:_range] mutableCopy];
                break;
            default:
                accessible = NULL;
                break;
        }
    }
    else if (self.category == CardCategorySpecial){
        switch(self.specialTypeCategory){
            case CardSpecialCategoryNoLegs: case CardSpecialCategoryFreeze:  case CardSpecialCategoryDeRez:
                for(Card *c in p.manager.opponent.players.inGame){
                    if(c.location){
                        [accessible addObject:c.location];
                    }else{
                        NSLog(@"**ERROR no location for player");
                    }
                }
                break;
            case CardSpecialCategoryBlock:
                accessible = [[self.game allBoardLocations] mutableCopy];
                if(p.location){
                [accessible removeObject:p.location];
                }
                else{
                    NSLog(@"**ERROR no location for enchantee");
                }
                return accessible;
            case CardSpecialCategoryNewDeal: case CardSpecialCategoryPredictiveAnalysis: case CardSpecialCategorySuccubus:
                accessible = [[NSMutableArray alloc] init];
                [accessible addObject:p.location];
                return accessible;
                break;
                
                default:
                 NSLog(@"**ERROR no card special category");
                break;
        }
        
        
        if(self.category == CardCategorySpecial && self.specialTypeCategory == CardSpecialCategoryBlock){
           
        }
        if(self.category == CardCategorySpecial &&
           (self.specialTypeCategory == CardSpecialCategoryNewDeal || self.specialTypeCategory == CardSpecialCategoryPredictiveAnalysis)){
           
        }

    }
    else{
        accessible = NULL;
    }
    
    return accessible;
    
}

-(NSArray*)validatedSelectionSetForPlayer:(Player*)p {
    if (!p) {
        NSLog(@"selectionSet with no player");
        return nil;
    }
    
    NSArray* accessible = [self selectionSetForPlayer:p];
    
    // IF MOVING / KICK WE'RE DONE VALIDATING
    
    if (self.category == CardCategoryMove || self.category == CardCategoryKick || self.category == CardCategorySpecial){
        return accessible;
    }
    
    // ELSE LIMIT TO POSSIBLE PLAYER TARGETS
    
    NSMutableArray* set = [NSMutableArray array];
    
    // KICK NOW SHOWS ALL ACCESSIBLE
    
//    if (self.category == CardCategoryKick) {
//        for (Player* p in self.playerPerforming.manager.players.inGame) {
//            if ([accessible containsObject:p.location]){
//                [set addObject:p.location];
//            }
//        }
//        if ([accessible containsObject:self.playerPerforming.manager.goal]) {
//            [set addObject:self.playerPerforming.manager.goal];
//        }
//        
//        [set removeObject:self.playerPerforming.location];
//    }
    
    if (self.category == CardCategoryChallenge) {
        NSLog(@"opponent count %d", p.manager.opponent.players.inGame.count);
        for (Card* c in p.manager.opponent.players.inGame) {
            if ([(Player*)c ball]) {
                if ([accessible containsObject:c.location]) {
                    [set addObject:c.location];
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
        
    _energyEarn = [decoder decodeIntForKey:NSFWKeyActionPointEarn];
    _energyCost = [decoder decodeIntForKey:NSFWKeyActionPointCost];
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
    
    [encoder encodeInteger:_energyEarn forKey:NSFWKeyActionPointEarn];
    [encoder encodeInteger:_energyCost forKey:NSFWKeyActionPointCost];
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