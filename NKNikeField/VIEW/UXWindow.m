
#import "NikeNodeHeaders.h"
#import "ModelHeaders.h"


@implementation UXWindow

-(instancetype) initWithTexture:(NKTexture *)texture color:(UIColor *)color size:(CGSize)size {
    
    self = [super initWithTexture:texture color:color size:size];
    
    if (self) {

        
        
         //NSLog(@"init uxWindow, size: %f %f, cardSize: %f %f", w,h, cardSize.width, cardSize.height);
        
        

        _playerHands = [NSMutableDictionary dictionary];
 
        self.name = @"ACTION WINDOW";
        
        self.userInteractionEnabled = true;

       
//        
//        NKLabelNode *yourCards = [[NKLabelNode alloc] initWithFontNamed:@"TradeGothicLTStd-BdCn20"];
//        [yourCards setText:@"YOUR CARDS"];
//        [yourCards setFontSize:TILE_SIZE/4.];
//        [yourCards setFontColor:[UIColor whiteColor]];
//        [yourCards setVerticalAlignmentMode:NKLabelVerticalAlignmentModeTop];
//        [yourCards setPosition:CGPointMake(0, h*.485)];
//        [self addChild:yourCards];
//        
//        // action points window stuff
//        _turnTokensWindow = [[NKSpriteNode alloc] initWithTexture:nil color:color size:CGSizeMake(size.width, size.width*1.2)];
//        
//        NKSpriteNode *bottomShadow = [[NKSpriteNode alloc] initWithTexture:[NKTexture textureWithImageNamed:@"shadowUp"] color:Nil size:CGSizeMake(self.size.width, 20)];
//        [bottomShadow setAlpha:1.];
//        //[bottomShadow setBlendMode:NKBlendModeSubtract];
//        [bottomShadow setPosition:CGPointMake(0,_turnTokensWindow.size.height*.5+10)];
//        [_turnTokensWindow addChild:bottomShadow];
//        
//        
//        _turnTokenCount = [[NKLabelNode alloc] initWithFontNamed:@"TradeGothicLTStd-BdCn20"];
//        [_turnTokenCount setText:@"#"];
//        [_turnTokenCount setFontSize:TILE_SIZE/2.];
//        [_turnTokenCount setFontColor:[UIColor whiteColor]];
//        [_turnTokenCount setPosition:CGPointMake(_turnTokensWindow.size.width*.28, _turnTokensWindow.size.height*.1)];
        
        //        NKSpriteNode *topShadow = [[NKSpriteNode alloc] initWithTexture:[NKTexture textureWithImageNamed:@"shadowUp"] color:Nil size:CGSizeMake(self.size.width, 20)];
        //        [topShadow setZRotation:M_PI];
        //        [topShadow setAlpha:0.5];
        //        [topShadow setPosition:CGPointMake(0,self.size.height*.4)];
        //        [self addChild:topShadow];
        
//        _opTokenCount = [[NKLabelNode alloc] initWithFontNamed:@"TradeGothicLTStd-BdCn20"];
//        [_opTokenCount setText:@"#"];
//        [_opTokenCount setFontSize:TILE_WIDTH/4.];
//        [_opTokenCount setFontColor:[UIColor whiteColor]];
//        [_opTokenCount setPosition:CGPointMake(self.scene.size.width - WINDOW_WIDTH*.5 - cardSize.width*.125, self.size.height*.5 - TILE_SIZE/2.)];
//        
//        
//        NKLabelNode *turnTokenDescription = [[NKLabelNode alloc] initWithFontNamed:@"TradeGothicLTStd-BdCn20"];
//        [turnTokenDescription setFontColor:[UIColor whiteColor]];
//        [turnTokenDescription setText:@"ACTION"];
//        [turnTokenDescription setFontSize:TILE_SIZE/4.];
//        [turnTokenDescription setHorizontalAlignmentMode:NKLabelHorizontalAlignmentModeCenter];
//        [turnTokenDescription setPosition:CGPointMake(-_turnTokensWindow.size.height*.125, _turnTokensWindow.size.height*.23)];
//        [_turnTokensWindow addChild:turnTokenDescription];
//        NKLabelNode *turnTokenDescription2 = [[NKLabelNode alloc] initWithFontNamed:@"TradeGothicLTStd-BdCn20"];
//        [turnTokenDescription2 setFontColor:[UIColor whiteColor]];
//        [turnTokenDescription2 setText:@"POINTS"];
//        [turnTokenDescription2 setHorizontalAlignmentMode:NKLabelHorizontalAlignmentModeCenter];
//        [turnTokenDescription2 setFontSize:TILE_SIZE/4.];
//        [turnTokenDescription2 setPosition:CGPointMake(-_turnTokensWindow.size.height*.125, _turnTokensWindow.size.height*.05)];
//        [_turnTokensWindow addChild:turnTokenDescription2];
//        
//        [_turnTokensWindow addChild:_turnTokenCount];
//        
//        [_turnTokensWindow setPosition:CGPointMake(0, -self.size.height*.5+_turnTokensWindow.size.height*.5)];
//        [self addChild:_turnTokensWindow];
//        
//        
//        
//        [self addChild:_opTokenCount];
//        
//        [_opTokenCount setZPosition:8];
        
        
//        ButtonSprite *ap = [ButtonSprite buttonWithNames:@[@"", @""] color:@[[NKColor clearColor],[NKColor clearColor]] type:ButtonTypePush size:CGSizeMake(size.width*.66, cardSize.height/3)];
//        [ap setPosition:CGPointMake(0, _turnTokensWindow.size.height*.23)];
//        
//        ap.delegate = self;
//        ap.method = @selector(cheatGetPoints:);
//        [_turnTokensWindow addChild:ap];
//        
//        [_turnTokensWindow setZPosition:8];
        
        
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
//        _actionButton = [ButtonSprite buttonWithTextureOn:[NKTexture textureWithImageNamed:@"Button_EndTurnON"] TextureOff:[NKTexture textureWithImageNamed:@"Button_EndTurnOFF"] type:ButtonTypePush size:CGSizeMake(TILE_SIZE*UI_MULT, TILE_SIZE*UI_MULT)];
//        [_actionButton setPosition:CGPointMake(self.size.width-(TILE_SIZE*.5),TILE_SIZE*.5)];
//        _actionButton.delegate = _delegate;
//        _actionButton.method = @selector(endTurn:);
//        
//    }
//    
//    else if ([function isEqualToString:@"draw"]) {
//        
//        
//        _actionButton = [ButtonSprite buttonWithTextureOn:[NKTexture textureWithImageNamed:@"Button_DrawCardON"] TextureOff:[NKTexture textureWithImageNamed:@"Button_DrawCardOFF"] type:ButtonTypePush size:CGSizeMake(TILE_SIZE*UI_MULT, TILE_SIZE*UI_MULT)];
//        [_actionButton setPosition:CGPointMake(self.size.width-(TILE_SIZE*.5),TILE_SIZE*.5)];
//        _actionButton.delegate = _delegate;
//        _actionButton.method = @selector(drawCard:);
//        
//    }
//    
//    [_actionButton setPosition:CGPointMake(0, -_turnTokensWindow.size.height*.25)];
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
//    fieldHUD = [[NKSpriteNode alloc] initWithTexture:[_delegate.sharedAtlas textureNamed:@"soccer_field_mini"]  color:[UIColor colorWithRed:0.0 green:0.5 blue:0.0 alpha:1.0] size:CGSizeMake(75*1.35, 75)];
//    [fieldHUD setAlpha:0.75];
//    [fieldHUD setPosition:CGPointMake(self.size.width/2. - self.size.height*.4, .2*self.size.height)];
//    [self addChild:fieldHUD];
//    fieldHUDSelectionBar = [[NKSpriteNode alloc] initWithTexture:Nil color:[UIColor colorWithWhite:1.0 alpha:0.33] size:CGSizeMake(fieldHUD.size.width*.1,fieldHUD.size.height)];
//    [fieldHUDSelectionBar setPosition:CGPointMake(fieldHUD.position.x, fieldHUD.position.y)];
//    [self addChild:fieldHUDSelectionBar];
//}
//-(void)refreshFieldHUDXOffset:(NSInteger)xOffset{
//    if(!fieldHUD) [self setupHUD];
//    [fieldHUDSelectionBar setPosition:CGPointMake(fieldHUD.position.x-(8-xOffset)/15.0*fieldHUD.size.width, fieldHUD.position.y)];
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
    if ([card.deck.player.manager isEqual:_delegate.game.me]) return 1;
    return 0;
}


-(void)removeCard:(Card *)card {
    
    //[self removeCard:card animated:NO withCompletionBlock:^{}];
    
}

-(void)swapCard:(CardSprite*)c withCard:(CardSprite*)c2 {
    
}

-(CardSprite*)spriteForCard:(Card*)c {
    
    PlayerHand *hand = [_playerHands objectForKey:c.deck.player];
    
    if (hand) {
        
        return [hand.cardSprites objectForKey:c];
        
    }
    
    NSLog(@"error, no cardSprite found . . .");
    return nil;
    
}

-(void)cleanup {
    
    for (PlayerHand *hand in _playerHands.allValues) {
        [self removeCardsForPlayer:hand.player animated:YES WithCompletionBlock:^{}];
    }

    _playerHands = [NSMutableDictionary dictionary];
    
}


-(void)begin {
    [super begin];
    glDisable(GL_DEPTH_TEST);
}

-(void)end {
    glEnable(GL_DEPTH_TEST);
    [super end];
}

-(void)cardTouchEnded:(CardSprite*)card atPoint:(CGPoint)point {
    
    self.selectedCard = card.model;
    _delegate.selectedCard = _selectedCard;
    
}

-(void)cardDoubleTap:(CardSprite*)card {

    PlayerHand* ph =   [_playerHands objectForKey:card.model.deck.player];
    
    float dur = FAST_ANIM_DUR;
    
    if (!ph.bigCards) {
        BigCards* big = [[BigCards alloc]initWithColor:NKCLEAR size:CGSizeMake(w, h*5.)];

        ph.bigCards = big;
        big.scrollDirectionVertical = false;
        big.name = @"BIG CARD SCROLLER";
        
        for (CardSprite *cs in ph.myCards) {
            NKScrollNode* node = [[NKScrollNode alloc] initWithParent:ph.bigCards autoSizePct:(3./ph.myCards.count)];
            [node setTexture:[NKTexture textureWithImageNamed:[cs.model fileNameForBigCard]]];
            [node setColor:NKWHITE];
            [big addCard:node];
            node.name = [cs.model fileNameForBigCard];
            node.userInteractionEnabled = false;
        }
        
        [self runAction:[NKAction resizeToWidth:w height:h*8. duration:dur]];
        
        [big setPosition3d:V3Make(0, -h*2.5, 0)];
        [ph addChild:big];
        [big runAction:[NKAction move3dTo:V3Make(0, h*2.5, 0) duration:dur]];
        
        int cardNum = [ph.myCards indexOfObject:[self spriteForCard:card.model]];
        [big scrollToChild:cardNum withOffset:.125 duration:FAST_ANIM_DUR];
        
    }
    else {
        [ph.bigCards runAction:[NKAction move3dTo:V3Make(0, -h*5.5, 0) duration:dur] completion:^{
            ph.bigCards = nil;
            [ph.bigCards removeFromParent];
        }];
        [self runAction:[NKAction resizeToWidth:w height:h*.125 duration:dur]];
        
    }
    
}

-(void)setSelectedCard:(Card *)selectedCard {
    
    if (selectedCard) {
         [[_playerHands objectForKey:selectedCard.deck.player] shuffleAroundCard:[self spriteForCard:selectedCard]];
    }
    
    PlayerHand* ph =   [_playerHands objectForKey:selectedCard.deck.player];
    BigCards *big = ph.bigCards;
    
    int cardNum = [ph.myCards indexOfObject:[self spriteForCard:selectedCard]];
    
    [big scrollToChild:cardNum withOffset:.125 duration:FAST_ANIM_DUR];

    _selectedCard = selectedCard;
    
}

-(void)removeCardsForPlayer:(Player*)p animated:(BOOL)animated WithCompletionBlock:(void (^)())block{
    
    PlayerHand *hand = [_playerHands objectForKey:p];
    
    if (hand.bigCards) {
        [hand.bigCards runAction:[NKAction move3dTo:V3Make(0, -h*2., 0) duration:FAST_ANIM_DUR] completion:^{
            hand.bigCards = nil;
            [hand.bigCards removeFromParent];
        }];
        
        [self runAction:[NKAction resizeToWidth:w height:h*.125 duration:FAST_ANIM_DUR]];
    }

    
    [hand runAction:[NKAction moveByX:0 y:-hand.size.height duration:FAST_ANIM_DUR ] completion:^{
        [hand removeFromParent];
        block();
    }];
    
    
}

-(void)refreshCardsForPlayer:(Player *)p WithCompletionBlock:(void (^)())block{
    if (_selectedPlayer){
        [self removeCardsForPlayer:_selectedPlayer animated:YES WithCompletionBlock:^{}];
    }
    
    _selectedPlayer = p;

    if (p) {
        PlayerHand *nHand = [[PlayerHand alloc] initWithPlayer:p delegate:self];
        
        [_playerHands setObject:nHand forKey:p];
        
        [self addChild:nHand];
        
        [nHand sortCardsAnimated:true WithCompletionBlock:^{
            block();
        }];
        
    }
    else {
        block();
    }

}

-(void)sortCardsForPlayer:(Player*)p animated:(BOOL)animated WithCompletionBlock:(void (^)())block{
 
    [[_playerHands objectForKey:_selectedCard.deck.player] sortCards];
    
}

@end

@implementation PlayerHand

-(instancetype)initWithPlayer:(Player*)p delegate:(UXWindow*)delegate {
    self = [super init];
    
    if (self){
        

        _cardSprites = [NSMutableDictionary dictionaryWithCapacity:6];
        _myCards = [NSMutableArray arrayWithCapacity:6];
        
        self.userInteractionEnabled = true;
        
         _delegate = delegate;
        self.size = delegate.size;
        _player = p;
       
        
        cardSize.width = (1. / (p.cardSlots+2)) * w;
        cardSize.height = (cardSize.width * (100. / 70.));
        
        _playerName = [[NKLabelNode alloc]initWithSize:CGSizeMake(cardSize.width*2., cardSize.height) FontNamed:@"Helvetica"];
        _playerName.fontSize = 20;
        _playerName.text = p.name;
        
        [self addChild:_playerName];
        
        [_playerName setPosition3d:V3Make(w,0,2)];
        
        for (Card* c in p.moveDeck.inHand) {
            [self addCard:c];
        }
        
        if (p.manager.hasPossesion){
            for (Card* c in p.kickDeck.inHand) {
                [self addCard:c];
            }
        }
        else {
            for (Card* c in p.challengeDeck.inHand) {
                [self addCard:c];
            }
        }
        
        for (Card* c in p.specialDeck.inHand) {
            [self addCard:c];
        }
        
        [self sortCards];
        
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
    
    newCard.model = card;
    newCard.window = _delegate;
    
    if (card.validatedSelectionSet) {
        newCard.color = newCard.colorForCategory;
    }
    else {
        newCard.color = [NKColor colorWithRed:.5 green:.5 blue:.5 alpha:1.];
    }
    
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
    [_cardSprites removeObjectForKey:card];

}


-(void)shuffleAroundCard:(CardSprite*)card {
    
    float offSet = cardSize.width * -1.1;
    float nscale = 1.;
    
    for (int i = 0; i < _myCards.count; i++) {
        
        CardSprite *cs = _myCards[i];
        
        
        [cs setAlpha:1.];
        cs.order = i;
        
        
        if (cs.order == card.order){
            
            
            offSet += cardSize.width * .1;
            cs.origin = CGPointMake(offSet, cardSize.height*.1);
            offSet += cardSize.width * 1.2;
            nscale = 1.15;
            
        }
        
        
        else {
            
            nscale = 1.;
            
            cs.origin = CGPointMake(offSet, 0);
            offSet += cardSize.width * 1.1;
            
        }
        
        [cs runAction:[NKAction group:@[[NKAction scaleTo:nscale duration:FAST_ANIM_DUR],
                                        [NKAction moveTo:cs.origin duration:FAST_ANIM_DUR]]]];
        
    }
    
}

-(void)sortCards{
    
    [self sortCardsAnimated:true WithCompletionBlock:^{}];
    
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
        
        //cs.origin = CGPointMake((w*.3) - ((cardSize.width*.15 + (w*.125)* (2./_myCards.count) ) * i),0);
        cs.origin = CGPointMake(cardSize.width * 1.1 * (i-1), 0);
        
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
            [cs setPosition3d:V3Make(cs.origin.x, cs.origin.y,2)];
        }
        
    }
    
    if (animated) {
        
    [_playerName runAction:[NKAction move3dTo:V3Make( (_playerName.size.width * .4) - w*.5, -h*.4, 2) duration:CARD_ANIM_DUR] completion:^{
            block();
    }];

    }
    
    else {
        block();
    }
    
    
}



@end

@implementation BigCards

-(void)addCard:(NKNode*)card {
    if (!_cards) {
        _cards = [NSMutableArray array];
    }
    
    [_cards addObject:card];
    [self addChild:card];
}

@end

