
#import "NikeNodeHeaders.h"
#import "ModelHeaders.h"


@implementation UXWindow

-(instancetype) initWithTexture:(NKTexture *)texture color:(UIColor *)color size:(S2t)size {
    
    self = [super initWithTexture:texture color:color size:size];
    
    if (self) {

        
        
         //NSLog(@"init uxWindow, size: %f %f, cardSize: %f %f", w,h, cardSize.width, cardSize.height);
        
        

       // _managerHands = [NSMutableDictionary dictionary];
 
        self.name = @"ACTION WINDOW";
        
        self.userInteractionEnabled = true;
        
    }
    return self;
}

-(void)setActionButtonTo:(NSString *)function {
    
    
//    
//    if (!function) {
//        
//        [self fadeOutSprite:_actionButton time:CARD_ANIM_DUR];
//        return;
//        
//    }
//    
//    BOOL new = YES;
//    
//    if (_actionButton.parent) {
//        new = NO;
//        [_actionButton removeFromParent];
//    }
//    
//    if ([function isEqualToString:@"end"]) {
//        
//        
//        _actionButton = [ButtonSprite buttonWithTextureOn:[NKTexture textureWithImageNamed:@"Button_EndTurnON"] TextureOff:[NKTexture textureWithImageNamed:@"Button_EndTurnOFF"] type:ButtonTypePush size:S2Make(TILE_SIZE*UI_MULT, TILE_SIZE*UI_MULT)];
//        [_actionButton setPosition:P2Make(self.size.width-(TILE_SIZE*.5),TILE_SIZE*.5)];
//        _actionButton.delegate = _delegate;
//        _actionButton.method = @selector(endTurn:);
//        
//    }
//    
//    else if ([function isEqualToString:@"draw"]) {
//        
//        
//        _actionButton = [ButtonSprite buttonWithTextureOn:[NKTexture textureWithImageNamed:@"Button_DrawCardON"] TextureOff:[NKTexture textureWithImageNamed:@"Button_DrawCardOFF"] type:ButtonTypePush size:S2Make(TILE_SIZE*UI_MULT, TILE_SIZE*UI_MULT)];
//        [_actionButton setPosition:P2Make(self.size.width-(TILE_SIZE*.5),TILE_SIZE*.5)];
//        _actionButton.delegate = _delegate;
//        _actionButton.method = @selector(drawCard:);
//        
//    }
//    
//    [_actionButton setPosition:P2Make(0, -_turnTokensWindow.size.height*.25)];
//    
//    if (new) {
//        [_turnTokensWindow fadeInSprite:_actionButton duration:CARD_ANIM_DUR];
//    }
//    else {
//        [_turnTokensWindow addChild:_actionButton];
//    }
    
}

#pragma mark METHODS TO MODEL / DELEGATE

//-(void) setupHUD{
//    fieldHUD = [[NKSpriteNode alloc] initWithTexture:[_delegate.sharedAtlas textureNamed:@"soccer_field_mini"]  color:[UIColor colorWithRed:0.0 green:0.5 blue:0.0 alpha:1.0] size:S2Make(75*1.35, 75)];
//    [fieldHUD setAlpha:0.75];
//    [fieldHUD setPosition:P2Make(self.size.width/2. - self.size.height*.4, .2*self.size.height)];
//    [self addChild:fieldHUD];
//    fieldHUDSelectionBar = [[NKSpriteNode alloc] initWithTexture:Nil color:[UIColor colorWithWhite:1.0 alpha:0.33] size:S2Make(fieldHUD.size.width*.1,fieldHUD.size.height)];
//    [fieldHUDSelectionBar setPosition:P2Make(fieldHUD.position.x, fieldHUD.position.y)];
//    [self addChild:fieldHUDSelectionBar];
//}
//-(void)refreshFieldHUDXOffset:(NSInteger)xOffset{
//    if(!fieldHUD) [self setupHUD];
//    [fieldHUDSelectionBar setPosition:P2Make(fieldHUD.position.x-(8-xOffset)/15.0*fieldHUD.size.width, fieldHUD.position.y)];
//}

-(void)cheatGetPoints:(ButtonSprite*)sender {
    [_delegate.game cheatGetPoints];
}

-(void)shouldPerformAction:(ButtonSprite*)sender {
    [_delegate.game playTouchSound];
    [_delegate shouldPerformCurrentAction];
}

#pragma mark METHODS FROM MODEL / DELEGATE


-(void)alertDidCancel {
    
    [self fadeOutChild:_alert duration:1.];
    
}


-(BOOL)cardIsMine:(Card*)card {
    if ([card.deck.manager isEqual:_delegate.game.me]) return 1;
    return 0;
}


-(void)removeCard:(Card *)card {
    
    //[self removeCard:card animated:NO withCompletionBlock:^{}];
    
}

-(void)swapCard:(CardSprite*)c withCard:(CardSprite*)c2 {
    
}

-(CardSprite*)spriteForCard:(Card*)c {
    
    ManagerHand *hand = _managerHand; //[_managerHands objectForKey:c.deck.player];
    
    if (hand) {
        
        return [hand.cardSprites objectForKey:c];
        
    }
    
    NSLog(@"error, no cardSprite found . . .");
    return nil;
    
}

-(void)cleanup {
    
    [self removeCardsAnimated:YES WithCompletionBlock:^{_managerHand = nil;
    }];
    
//    for (PlayerHand *hand in _managerHands.allValues) {
//        [self removeCardsForPlayer:hand.player animated:YES WithCompletionBlock:^{}];
//    }
//
//    _managerHands = [NSMutableDictionary dictionary];
    
    
    
}


-(void)begin {
    [super begin];
    glDisable(GL_DEPTH_TEST);
}

-(void)end {
    glEnable(GL_DEPTH_TEST);
    [super end];
}

-(void)drawForHitDetection {
    glDisable(GL_DEPTH_TEST);
    [super drawForHitDetection];
    glEnable(GL_DEPTH_TEST);
}

-(void)cardTouchEnded:(CardSprite*)card atPoint:(P2t)point {
    
    self.selectedCard = card.model;
    _delegate.selectedCard = _selectedCard;
    
}

-(void)cardDoubleTap:(CardSprite*)card {

    //PlayerHand* ph = [_managerHands objectForKey:card.model.deck.player];
    
    float dur = FAST_ANIM_DUR;
    
    if (!_managerHand.bigCards) {
        BigCards* big = [[BigCards alloc]initWithColor:NKCLEAR size:S2Make(w, h*3.)];
        big.delegate = _managerHand;
        
        _managerHand.bigCards = big;
        big.scrollDirectionVertical = false;
        big.name = @"BIG CARD SCROLLER";
        
        for (CardSprite *cs in _managerHand.myCards) {
            NKScrollNode* node = [[NKScrollNode alloc] initWithParent:_managerHand.bigCards autoSizePct:(2./_managerHand.myCards.count)];
            [node setTexture:[NKTexture textureWithImageNamed:[cs.model fileNameForBigCard]]];
            [node setColor:NKWHITE];
            [big addCard:node];
            node.name = [cs.model fileNameForBigCard];
           // node.userInteractionEnabled = false;
        }
        
        [self runAction:[NKAction resizeToWidth:w height:h*7.5 duration:dur]];
        
        [big setPosition3d:V3Make(0, -h*2.5, 0)];
        [_managerHand addChild:big];
        [big runAction:[NKAction move3dTo:V3Make(0, h*2.15, 0) duration:dur]];
        
        int cardNum = [_managerHand.myCards indexOfObject:[self spriteForCard:card.model]];
        [big scrollToChild:cardNum  duration:FAST_ANIM_DUR];
        [(GameScene*)self.scene playSoundWithKey:@"cardExpand"];
        
    }
    else {

        [self hideBigCards];
        
    }
    
}

-(void)hideBigCards {
    
    float dur = CARD_ANIM_DUR;
    
    //PlayerHand* ph =   [_managerHands objectForKey:_selectedCard.deck.player];
    
    NKAction *fadeLower = [NKAction group:@[[NKAction fadeAlphaTo:0. duration:dur],
                                            [NKAction move3dBy:V3Make(0, -h*.5, 0) duration:dur]]];
    
    [_managerHand.bigCards runAction:fadeLower completion:^{
         [_managerHand.bigCards removeFromParent];
        _managerHand.bigCards = nil;
    }];
    [self runAction:[NKAction resizeToWidth:w height:_delegate.size.height*.15 duration:dur]];
    
    [(GameScene*)self.scene playSoundWithKey:@"cardContract"];
}

-(void)setSelectedCard:(Card *)selectedCard {
    
    if (selectedCard) {
         [_managerHand shuffleAroundCard:selectedCard];
    }
    
    //PlayerHand* ph =   [_managerHand objectForKey:selectedCard.deck.player];
    BigCards *big = _managerHand.bigCards;
    
    int cardNum = [_managerHand.myCards indexOfObject:[self spriteForCard:selectedCard]];
    
    [big scrollToChild:cardNum duration:FAST_ANIM_DUR];

    _selectedCard = selectedCard;
    
}

-(void)removeCardsAnimated:(BOOL)animated WithCompletionBlock:(void (^)())block{
    
    if (_managerHand) {

    ManagerHand *hand = _managerHand;//[_managerHands objectForKey:p];
        
    if (hand.bigCards) {
        [hand.bigCards runAction:[NKAction move3dTo:V3Make(0, -h*2., 0) duration:FAST_ANIM_DUR] completion:^{
            hand.bigCards = nil;
            [hand.bigCards removeFromParent];
        }];
        
        [self runAction:[NKAction resizeToWidth:w height:h*.125 duration:FAST_ANIM_DUR]];
    }

    
    [hand runAction:[NKAction moveByX:0 y:-hand.size.height duration:FAST_ANIM_DUR ] completion:^{
        [hand removeFromParent];
        _managerHand = nil;
        block();
    }];
        
    }
    
    
}

-(void)refreshCardsForManager:(Manager *)m WithCompletionBlock:(void (^)())block {
    
    if (!_managerHand) {
        
    _managerHand = [[ManagerHand alloc] initWithManager:m delegate:self];
    
    [self addChild:_managerHand];
    
    NSLog(@"init manager hand %d", _managerHand.myCards.count);
    
    }
    
    if (_selectedCard) {
        [_managerHand shuffleAroundCard:_selectedCard];
        block();
    }
    
    else {
        [_managerHand sortCardsAnimated:true WithCompletionBlock:^{
            block();
        }];
    }
    
}


-(NKTouchState)touchUp:(P2t)location id:(int)touchId {
    
    //NKTouchState hit = [super touchUp:location id:touchId];
    //if (hit == 2) {
        [_delegate showCardPath:nil];
        [_managerHand sortCardsAnimated:true WithCompletionBlock:^{}];
        //[[_managerHands objectForKey:_selectedCard.deck.player] sortCards];
    //}
    return 0;
}

@end

@implementation ManagerHand

-(instancetype)initWithManager:(Manager *)m delegate:(UXWindow *)delegate {
    self = [super init];
    
    if (self){
        

        _cardSprites = [NSMutableDictionary dictionaryWithCapacity:6];
        _myCards = [NSMutableArray arrayWithCapacity:6];
        
        self.userInteractionEnabled = true;
        
        _delegate = delegate;
        self.size = delegate.size;
        _manager = m;
       
        
        cardSize.width = (1. / (5+2)) * w;
        cardSize.height = (cardSize.width * (100. / 70.));
        
//        _playerName = [[NKLabelNode alloc]initWithSize:S2Make(cardSize.width*2., cardSize.height) FontNamed:@"Arial Black.ttf"];
//        _playerName.fontSize = 20;
//        _playerName.text = p.name;
        
       // [self addChild:_playerName];
        
        //[_playerName setPosition3d:V3Make(w,0,2)];
        
        for (Card*c in m.allCardsInHand){
            [self addCard:c];
        }
        
//        for (Card* c in m.moveDeck.inHand) {
//            [self addCard:c];
//        }
//        
//        if (m.hasPossesion){
//            for (Card* c in p.kickDeck.inHand) {
//                [self addCard:c];
//            }
//        }
//        else {
//            for (Card* c in p.challengeDeck.inHand) {
//                [self addCard:c];
//            }
//        }
//        
//        for (Card* c in p.specialDeck.inHand) {
//            [self addCard:c];
//        }
        
        
        //[_uxWindow sortMyCards:YES WithCompletionBlock:nil];
        
    }
    else {
        NSLog(@"ERROR NO MODEL FOR SELECTED PLAYER");
    }
    
    return self;
    
}

-(void)addCard:(Card *)card {
    
    [self addCard:card animated:NO withCompletionBlock:^{}];
    
}

-(void)addCard:(Card *)card animated:(BOOL)animated withCompletionBlock:(void (^)())block{
    
    // NSLog(@"** adding card %@ from %@", card.name, card.deck.name);
    
    CardSprite* newCard = [[CardSprite alloc] initWithTexture:nil color:nil size:cardSize];
    newCard.delegate = self.delegate.delegate;
    
    newCard.model = card;
    newCard.window = _delegate;
    
    [_cardSprites setObject:newCard forKey:card];
    
    [self addChild:newCard];
    [newCard setPosition3d:V3Make(w,0,0)];
    
    [_myCards addObject:newCard];
    
    if (block) {
        block();
    }
    
}

-(void)removeCard:(Card *)card {
    
    [self removeCard:card animated:NO withCompletionBlock:^{}];
    
}

-(void)removeCard:(Card *)card animated:(BOOL)animated withCompletionBlock:(void (^)())block{

    CardSprite *cardToRemove = [_cardSprites objectForKey:card];
    [cardToRemove removeFromParent];
    [_myCards removeObject:card];
    [_cardSprites removeObjectForKey:card];

}

-(void)shuffleAroundCard:(Card*)card {
    
    CardSprite *cs = [_cardSprites objectForKey:card];
    [self shuffleAroundCardSprite:cs];
}

-(void)shuffleAroundCardSprite:(CardSprite *)card {

    float offSet = cardSize.width * -2.2;
    float nscale = 1.;
    
    for (int i = 0; i < _myCards.count; i++) {
        
        CardSprite *cs = _myCards[i];
        
        [cs setAlpha:1.];
        cs.order = i;
        
        
        if (cs.order == card.order){
            
            
            offSet += cardSize.width * .1;
            cs.origin = P2Make(offSet, cardSize.height*.1);
            offSet += cardSize.width * 1.2;
            nscale = 1.15;
            
        }
        
        
        else {
            
            nscale = 1.;
            
            cs.origin = P2Make(offSet, 0);
            offSet += cardSize.width * 1.1;
            
        }
        
        [cs runAction:[NKAction group:@[[NKAction scaleTo:nscale duration:FAST_ANIM_DUR],
                                        [NKAction moveTo:cs.origin duration:FAST_ANIM_DUR]]]];
        
    }
    
}


-(void)sortCardsAnimated:(BOOL)animated WithCompletionBlock:(void (^)())block{
    
    //NSLog(@"I HAVE %d CARD SPRITES IN MY HAND", _myCards.count);
    // MYCARDS
    
    //    if (_delegate.game.myTurn) {
    //        [_delegate.game sendRTPacketWithType:RTMessageSortCards point:nil];
    //    }
    
    for (int i = 0; i < _myCards.count; i++) {
        
        CardSprite *cs = _myCards[i];
        
        cs.order = i;
        //cs.zPosition = i;
        if (cs.hasShadow) {
            [cs setHasShadow:NO];
        }
        
        [cs setAlpha:1.];
        
        //cs.origin = P2Make(((cardSize.width*1.1*((int)(i-(2-cardSize))) ) * i),0);
        cs.origin = P2Make(cardSize.width * 1.1 * (i-2), 0);
        
        if (animated) {
            
            if (cs.hasActions){
                [cs removeAllActions];
            }
            
            [cs runAction:[NKAction scaleTo:1. duration:CARD_ANIM_DUR]];
            NKAction *move = [NKAction move3dTo:V3Make(cs.origin.x, cs.origin.y,2) duration:CARD_ANIM_DUR];
            [move setTimingMode:NKActionTimingEaseIn];
            [cs runAction:move];
            //           [cs setPosition3d:V3Make(cs.origin.x, cs.origin.y,2)];
            
        }
        
        else {
            [cs setScale:1.];
            [cs setPosition3d:V3Make(cs.origin.x, cs.origin.y,2)];
        }
        
    }
    
    if (animated) {
        
//    [_playerName runAction:[NKAction move3dTo:V3Make( (_playerName.size.width * .4) - w*.5, -h*.4, 2) duration:CARD_ANIM_DUR] completion:^{
//            block();
//    }];
        [self runAction:[NKAction delayFor:CARD_ANIM_DUR] completion:^{
            block();
        }];

    }
    
    else {
        block();
    }
    
    
}

#pragma mark - big cards delegate

-(void)cellWasDeSelected:(NKScrollNode *)cell {
    
}

-(void)cellWasSelected:(NKScrollNode *)cell {
    int index = [cell.parent.children indexOfObject:cell];
    CardSprite* cs = _myCards[index];
    [_delegate setSelectedCard:cs.model];
    [_delegate.delegate setSelectedCard:cs.model];
    
    [_delegate hideBigCards];
}





@end

@implementation BigCards

-(void)addCard:(NKNode*)card {
    if (!_cards) {
        _cards = [NSMutableArray array];
    }
    
    [_cards addObject:card];
    [self addChild:card];
    
    card.userInteractionEnabled = true;
}

-(void)scrollToChild:(int)child duration:(F1t)duration {
    [super scrollToChild:child duration:duration];
    //[(GameScene*)self.scene playSoundWithKey:@"cardSwipe"];
}

-(bool)scrollShouldStart {
    [(GameScene*)self.scene playSoundWithKey:@"cardSwipe"];
    return [super scrollShouldStart];
}

-(void)shouldBeginRestitution {
    [super shouldBeginRestitution];
}


@end

