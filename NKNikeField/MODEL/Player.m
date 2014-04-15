//
//  Player.m
//  nike3dField
//
//  Created by Chroma Developer on 3/25/14.
//
//

#import "ModelHeaders.h"

@implementation Player

-(id) initWithManager:(Manager*)m {
    self = [super initWithDeck:m.players];
    if (self) {
        _manager = m;
    }
    return self;
}

-(void)generateDefaultCards {
    
    _cardSlots = 4;
    
    _moveDeck = [[Deck alloc]initWithPlayer:self type:CardCategoryMove];
    _kickDeck = [[Deck alloc]initWithPlayer:self type:CardCategoryKick];
    _challengeDeck = [[Deck alloc]initWithPlayer:self type:CardCategoryChallenge];
    _specialDeck = [[Deck alloc]initWithPlayer:self type:CardCategorySpecial];
    
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    
    [aCoder encodeInt32:_cardSlots forKey:@"cardSlots"];
    [aCoder encodeObject:_manager forKey:NSFWKeyManager];
    [aCoder encodeObject:_moveDeck forKey:@"moveDeck"];
    [aCoder encodeObject:_kickDeck forKey:@"kickDeck"];
    [aCoder encodeObject:_challengeDeck forKey:@"challengeDeck"];
    [aCoder encodeObject:_specialDeck forKey:@"specialDeck"];
    
}

-(void)setLocation:(BoardLocation *)location {
    
    [super setLocation:location];
    
    for (Card* c in _enchantments) {
        c.location = location;
    }
    
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    
    if (self) {
     
        _cardSlots = [decoder decodeInt32ForKey:@"cardSlots"];
        _manager = [decoder decodeObjectForKey:NSFWKeyManager];
        _kickDeck = [decoder decodeObjectForKey:@"kickDeck"];
        _challengeDeck = [decoder decodeObjectForKey:@"challengeDeck"];
        _moveDeck = [decoder decodeObjectForKey:@"moveDeck"];
        _specialDeck = [decoder decodeObjectForKey:@"specialDeck"];
    }
    
    return self;
}


-(void)addEnchantment:(Card*)enchantment {
    
    
    
    NSMutableArray *enchantmentsMutable;
    
    if (!_enchantments) enchantmentsMutable = [NSMutableArray arrayWithCapacity:3];
    else enchantmentsMutable = [_enchantments mutableCopy];
    
    
    [enchantmentsMutable addObject:enchantment];
    _enchantments = enchantmentsMutable;
    
    enchantment.enchantee = self;
    
}

-(void)removeEnchantment:(Card*)enchantment {
    
    NSMutableArray *enchantmentsMutable = [_enchantments mutableCopy];
    [enchantmentsMutable removeObject:enchantment];
    
    if (!enchantmentsMutable.count) _enchantments = Nil;
    else _enchantments = enchantmentsMutable;
    
}


-(void)removeLastEnchantment {
    
    NSMutableArray *enchantmentsMutable = [_enchantments mutableCopy];
    [enchantmentsMutable removeLastObject];
    _enchantments = enchantmentsMutable;
    
}

-(NSArray*)allCardsInHand {
    return [[[_moveDeck.inHand arrayByAddingObjectsFromArray:_kickDeck.inHand]arrayByAddingObjectsFromArray:_challengeDeck.inHand]arrayByAddingObjectsFromArray:_specialDeck.inHand];
}

-(NSArray*)allCardsInDeck {
    return [[[_moveDeck.theDeck arrayByAddingObjectsFromArray:_kickDeck.theDeck]arrayByAddingObjectsFromArray:_challengeDeck.theDeck]arrayByAddingObjectsFromArray:_specialDeck.theDeck];
}

-(Card*)cardInHandAtlocation:(BoardLocation*)location {
    
    for (Card* inHand in [self allCardsInHand]) {
        if ([inHand.location isEqual:location]) {
            return inHand;
        }
    }
    return Nil;
}

-(Card*)cardInDeckAtLocation:(BoardLocation*)location {
    
    for (Card* inDeck in [self allCardsInDeck]) {
        if ([inDeck.location isEqual:location]) {
            return inDeck;
        }
    }
    return Nil;
}


-(void)setBall:(Card *)ball {
    
    if (ball) { // not setting to nil
        
        if (ball.enchantee && ![ball.enchantee isEqual:self]) {
            [ball.enchantee setBall:nil];
            ball.enchantee = self;
            
        }
        
        else {
            ball.enchantee = self;
        }
        
        _ball = ball;
        
    }
    
    else {
        _ball = Nil;
    }
    
}

#pragma mark - AI CONVENIENCE FUNCTIONS

-(NSArray*)pathToBall{
    BoardLocation *ballLocation = _manager.game.ball.location;
    return [self pathToBoardLocation:ballLocation];
}

-(NSArray*)pathToGoal{
    BoardLocation *goalLocation = _manager.goal;
    return [self pathToBoardLocation:goalLocation];
}

-(NSArray*)pathToBoardLocation:(BoardLocation *)location{
    if(!location){
        NSLog(@"pathToBoardLocation Error, null location");
        return NULL;
    }
    
    NSMutableArray *obstacles = [[NSMutableArray alloc] init];
   // BoardLocation *goalLocation = _manager.goal;
    
    for (Player* p in [_manager.players inGame]) {
        // add all players that aren't on the ball to the obstacles
      //  if(!([location isEqual:p.location])){
            [obstacles addObject:p.location];
      //  }
    }
    for (Player* p in [_manager.opponent.players inGame]) {
        // add all players that aren't on the ball to the obstacles
       // if(!([location isEqual:p.location])){
            [obstacles addObject:p.location];
       // }
    }
    AStar *aStar = [[AStar alloc]initWithColumns:7 Rows:10 ObstaclesCells:obstacles];
   // NSLog(@"in pathToLocation, player = %@ ball = %@", self.location, location);
    NSArray* path = [aStar pathFromAtoB:self.location B:location NeighborhoodType:NeighborhoodTypeMoore];
    
    return path;
}
-(NSArray*)pathToClosestBoardLocation:(BoardLocation *)location{
    if(!location){
        NSLog(@"pathToBoardLocation Error, null location");
        return NULL;
    }
    
    NSMutableArray *obstacles = [[NSMutableArray alloc] init];
    // BoardLocation *goalLocation = _manager.goal;
    
    for (Player* p in [_manager.players inGame]) {
        // add all players that aren't on the ball to the obstacles
        if(!([location isEqual:p.location])){
            [obstacles addObject:p.location];
        }
    }
    for (Player* p in [_manager.opponent.players inGame]) {
        // add all players that aren't on the ball to the obstacles
        if(!([location isEqual:p.location])){
            [obstacles addObject:p.location];
        }
    }
    AStar *aStar = [[AStar alloc]initWithColumns:7 Rows:10 ObstaclesCells:obstacles];
    // NSLog(@"in pathToLocation, player = %@ ball = %@", self.location, location);
    NSArray* path = [aStar pathFromAtoB:self.location B:location NeighborhoodType:NeighborhoodTypeMoore];
    
    return path;
}


-(NSArray*)pathToKickRange:(Player *)player{
    NSArray *retPath;
    NSArray *kickPath;
    NSArray *movePath;
    Card* kickCard;
    if(player.kickDeck.inHand && [player.kickDeck.inHand count]){
        kickCard = player.kickDeck.inHand[0];
    }
    else{
        return NULL;
    }
    
    if(kickCard){
        kickPath = kickCard.selectionSet;
    }
    else{
        return retPath;
    }
    if(kickPath){
        Card* moveCard;
        if(self.moveDeck.inHand && [player.moveDeck.inHand count]){
            moveCard = self.moveDeck.inHand[0];
        }
        else{
            return NULL;
        }
        if(moveCard){
            movePath = moveCard.selectionSet;
            if(movePath){
                // NSArray *intersectPath = [BoardLocation setIntersect:movePath withSet:kickPath];
                NSArray *intersectPath = [BoardLocation  tileSetIntersect:movePath withTileSet:kickPath];
                if(intersectPath){
                    BoardLocation *closestLocation = [self closestLocationInTileSet:intersectPath];
                    if(closestLocation){
                        retPath = [self pathToBoardLocation:closestLocation];
                    }
                }
            }
        }
        else{
            return retPath;
        }
        
    }
    return retPath;
}

-(NSArray*)pathToChallenge:(Player *)player{
    NSMutableArray *retPath;
   
    retPath = [NSMutableArray arrayWithArray:[self pathToClosestBoardLocation:player.location]];
    if(!retPath){
        return NULL;
    }
    if([retPath count] > 1){
        [retPath removeObjectAtIndex:[retPath count]-1];
    }
    return retPath;
}

-(BoardLocation*)closestLocationInTileSet:(NSArray*)tileSet{
    int minPath = 100000;
    BoardLocation* retVal;
    for(BoardLocation* location in tileSet){
        NSArray *path = [self pathToBoardLocation:location];
        if(path.count < minPath){
            minPath = path.count;
            retVal = location;
        }
    }
    return retVal;
}

-(BOOL)isInShootingRange{
    Card *kickCard;
    if(self.kickDeck.inHand && [self.kickDeck.inHand count]){
        kickCard = self.kickDeck.inHand[0];
    }
    else{
        return FALSE;
    }
    NSArray* pathToGoal = [self pathToGoal];
    if(kickCard.range >= [pathToGoal count]){
        return TRUE;
    }
    else{
        return FALSE;
    }
}

-(NSArray*)playersInPassRange{
    NSMutableArray* retPlayers = [NSMutableArray array];
    NSArray* players = [self.manager playersClosestToBall];
    for(Player *p in players){
        NSArray *pathToKickRange = [self pathToKickRange:p];
        if([pathToKickRange count] == 1){
            [retPlayers addObject:p];
        }
    }
    return retPlayers;
}

-(Player *)passToPlayerInShootingRange{
    NSArray *playersInShootingRange = [self playersInPassRange];
    NSArray *playersInPassRange = [self.manager playersInShootingRange];
    NSArray *playersIntersect = [BoardLocation tileSetIntersect:playersInShootingRange withTileSet:playersInPassRange];
    if(playersIntersect){
        return playersIntersect[0];
    }
    else{
        return NULL;
    }

}

-(NSArray *)playersCloserToGoal{
    NSMutableArray* obstacles = [[NSMutableArray alloc] init];
    BoardLocation *goalLocation = [self.manager goal];
    
    for (Player* p in [self.manager.players allCards]) {
        // add all players that aren't on the ball to the obstacles
        if(!(p.location.x == goalLocation.x && p.location.y == goalLocation.y)){
            [obstacles addObject:p.location];
        }
    }
    for (Player* p in [self.manager.opponent.players allCards]) {
        // add all players that aren't on the ball to the obstacles
        if(!(p.location.x == goalLocation.x && p.location.y == goalLocation.y)){
            [obstacles addObject:p.location];
        }
    }
    
    AStar *aStar = [[AStar alloc]initWithColumns:7 Rows:10 ObstaclesCells:obstacles];
    
    //NSLog(@"_game = %@", _game.ball.location);
    NSArray* selfPath = [aStar pathFromAtoB:self.location B:goalLocation NeighborhoodType:NeighborhoodTypeMoore];
    
    NSMutableDictionary *playerPathsDict = [[NSMutableDictionary alloc] init];
    for(Player* p in self.manager.players.inGame) {
        if(p != self){
            //NSLog(@"in playersClosestToBall, operating on player = %@, player location = %@  ball location = %@", p.name, p.location, goalLocation);
            NSArray* path = [aStar pathFromAtoB:p.location B:goalLocation NeighborhoodType:NeighborhoodTypeMoore];
            //  NSLog(@"in playersClosestToBall, path = %@", path);
            // NSString* count = [NSString stringWithFormat:@"%d",[path count]];
            if(path && ([path count] < [selfPath count]-1)){
                [playerPathsDict setObject:p forKey:path];
            }
        }
    }
    // NSLog(@"in playersClosestToBall, playersPathsDict = %@", playerPathsDict);
    
    // sort the playerPathsDict by lenth of the paths
    NSArray *keys = [playerPathsDict allKeys];
    NSMutableArray *sortedPlayers = [[NSMutableArray alloc] init];
    NSSortDescriptor* descriptor = [NSSortDescriptor sortDescriptorWithKey: @"@count" ascending: YES];
    NSArray* sortedKeys= [keys sortedArrayUsingDescriptors: @[ descriptor ]];
    for(NSArray* key in sortedKeys){
        [sortedPlayers addObject:[playerPathsDict objectForKey:key]];
    }
    //NSLog(@"in playersClosestToBall, returning sortedPlayers: %@", sortedPlayers);
    if([sortedPlayers count]){
        return sortedPlayers;
    }
    else{
        return NULL;
    }

}

-(BOOL)canMoveToChallenge{
    NSArray* pathToChallenge = [self pathToBall];
    Card* moveCard = self.moveDeck.inHand[0];
    if(!pathToChallenge){
        return FALSE;
    }
    if([pathToChallenge count] <= moveCard.range){
        return TRUE;
    }
    else{
        return FALSE;
    }
}



@end
