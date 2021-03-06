//
//  CardSprite.m
//  cardGame
//
//  Created by Chroma Dev Pod on 9/17/13.
//  Copyright (c) 2013 ChromaGames. All rights reserved.
//

#import "NikeNodeHeaders.h"
#import "ModelHeaders.h"

@implementation CardSprite

-(instancetype) initWithTexture:(NKTexture *)texture color:(NKByteColor *)color size:(S2t)size {
    
    self = [super initWithTexture:texture color:color size:size];
    
    if (self) {

        self.userInteractionEnabled = YES;
        
        NSLog(@"Card sprite alloc");
    }
    return self;
}

//-(NKLabelNode*)styledLabelNode {
//    
//    NKLabelNode *node = [NKLabelNode labelNodeWithFontNamed:@"Arial Black.ttf"];
//    node.verticalAlignmentMode = NKLabelVerticalAlignmentModeCenter;
//    
//    node.fontColor = [NKColor blackColor];
//    node.fontSize = h/10.;
//    return node;
//}

-(void)setHasShadow:(BOOL)hasShadow {
    _hasShadow = hasShadow;
    
    [self showShadow:hasShadow withCompletionBlock:^{
        
    }];
    
}

-(void)showShadow:(BOOL)showShadow withCompletionBlock:(void (^)())block {
    
    if (showShadow) {
        
        if (!_shadow) {
            _shadow = [[NKSpriteNode alloc] initWithTexture:[NKTexture textureWithImageNamed:@"Card_Ipad_shadow"] color:NKBLACK size:self.size];
            [_shadow setZPosition:-1];
            [_shadow setPosition:P2Make(-w*.075, h*.075)];
            [self addChild:_shadow];
        }
        [_shadow setHidden:NO];
        [_shadow setAlpha:0.];
        [_shadow runAction:[NKAction scaleTo:1.2 duration:CARD_ANIM_DUR]];
        [_shadow runAction:[NKAction fadeAlphaTo:.4 duration:CARD_ANIM_DUR] completion:^{
            _hovering = YES;
            block();
        }];
    }
    else {
        
        [_shadow runAction:[NKAction scaleTo:1. duration:CARD_ANIM_DUR]];
        [_shadow runAction:[NKAction fadeAlphaTo:0. duration:CARD_ANIM_DUR] completion:^{
            block();
            [_shadow setHidden:YES];
            _hovering = NO;
        }];
    }
}


-(NSString*)name {
    return _model.name;
}

-(void)setModel:(Card *)model {
    
    if (model) {
        
        _model = model;
        
        self.color = [self colorForCategory];
//        if ([model validatedSelectionSetForPlayer:_delegate.selectedPlayer]){
//            self.color = [self colorForCategory];
//        }
//        else {
//             self.color = [NKColor colorWithRed:.5 green:.5 blue:.5 alpha:1.];
//        }
        
        [self setCorrectTexture];
        
    }
}


-(NKByteColor*)colorForCategory {

//    switch (_model.category) {
//        case CardCategoryKick: return V2PURPLE;
//        case CardCategoryChallenge: return V2MAGENTA;
//        case CardCategoryMove: return V2BLUE;
//        default: return NKWHITE;
//            break;
//    }
//    return V2YELLOW;
    return NKWHITE;
}

-(void)showLabels{
    NKLabelNode *text = [NKLabelNode labelNodeWithFontNamed:@"Helvetica"];
    
    text.fontSize = 16;
    text.fontColor = V2YELLOW;
    [text setSize:S2Make(w,100)];
    [text setText:[self.model descriptionForCard]];
    [text setPosition:P2Make(0, h*.075)];
    [self addChild:text];
    
    
    text = [NKLabelNode labelNodeWithFontNamed:@"Arial Black.ttf"];
    text.fontSize = 16;
    text.fontColor = V2YELLOW;
    [text setSize:S2Make(w,100)];
    [text setText:[NSString stringWithFormat:@"%d", self.model.energyCost]];

    [text setPosition:P2Make(0, -h*.7)];
    //[text setZPosition:2];
    [self addChild:text];
}

-(void)setCorrectTexture {
    self.texture = [NKTexture textureWithImageNamed:[_model fileNameForThumbnail]];
    if(self.model.category == CardCategorySpecial){
        [self showLabels];
    }
    if (_model.locked) {
        [self showLocked];
    }
}

-(void)setFlipped:(BOOL)flipped {
    
    _flipped = flipped;
    if (_flipped) {
        
        
        for (NKNode* s in self.children) {
            if (![s isEqual:_shadow]) {
                [s setHidden:YES];
            }
        }
        
    }
    else {
        
        for (NKNode* s in self.children) {
            if (![s isEqual:_shadow]) {
                [s setHidden:NO];
            }
        }
        
    }
    
    [self setCorrectTexture];
    
}

- (id)copyWithZone:(NSZone *)zone{
    // Copying code here.
    return self;
}

-(void)showLocked {
    if (_model.locked) {
        if (![self childNodeWithName:@"lock"]) {
            
            NKSpriteNode *lock =  [[NKSpriteNode alloc] initWithTexture:[NKTexture textureWithImageNamed:@"lock-4"] color:V2BLUE size:S2Make(self.size.width*.5, self.size.width*.5)];
            [self addChild:lock];
            [lock setPosition:P2Make(w *.25, h*-.25)];
            lock.name = @"lock";
            
        }
    }
    else {
        [self removeChildNamed:@"lock"];
    }
}

-(void)toggleLocked {
    NSLog(@"lock card");
    
    if (_model.locked) {
        _model.locked = false;
        [self removeChildNamed:@"lock"];
    }
    else {
        _model.locked = true;
        [self showLocked];
        
        [(GameScene*)self.scene playSoundWithKey:@"cardLock"];
    }
}

-(void)handleEvent:(NKEvent *)event {
    
    if (NKEventPhaseBegin == event.phase) {
   // NKTouchState hit = [super touchMoved:location id:touchId];
    cachedPosition = self.position;
    lastTouch = event.screenLocation;
    //return hit;
    }
    
    else if (NKEventPhaseMove == event.phase) {
        if (event.screenLocation.y < lastTouch.y) {
            self.position = P2Make(self.position.x, self.position.y - (lastTouch.y - event.screenLocation.y));
            lastTouch = event.screenLocation;
        }
    }

    else if (NKEventPhaseEnd == event.phase) {
        
        if (_endTurnCard) {
            NSLog(@"end turn pressed !!");
            [_delegate pressedEndTurn];
        }
        
        if (self.position.y < cachedPosition.y - (h*.125)) {
            [self toggleLocked];
            [self runAction:[NKAction moveTo:cachedPosition duration:FAST_ANIM_DUR]];
        }
        
        else {
            
            if (!_model.locked) {
//                numtouches++;
//                if (numtouches > 1) {
//                    numtouches = 0;
//                    [_window cardDoubleTap:self];
//                }
//                else {
                    [_window cardTouchEnded:self atPoint:event.screenLocation];
                    [(GameScene*)self.scene playSoundWithKey:@"cardTap"];
//                }
            }
            else {
                [(GameScene*)self.scene playSoundWithKey:@"badTouch"];
            }
        }
        
    }
    
    else if (NKEventPhaseDoubleTap == event.phase) {
        NSLog(@"card double tap");
        [_window cardDoubleTap:self];
    }
    
}


-(NKAction*)goBack {
    
    NKAction *goBack = [NKAction moveTo:_origin duration:FAST_ANIM_DUR];
    
    [goBack setTimingMode:NKActionTimingEaseIn];
    
    return goBack;
    
}



-(void)updateWithTimeSinceLast:(F1t)dt {
    
//    touchTimer -= dt;
//    if (touchTimer < 0) {
//        numtouches = 0;
//        touchTimer = 600.;
//    }
//    
    [super updateWithTimeSinceLast:dt];
}

@end
