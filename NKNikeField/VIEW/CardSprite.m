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

-(instancetype) initWithTexture:(NKTexture *)texture color:(UIColor *)color size:(S2t)size {
    
    self = [super initWithTexture:nil color:nil size:size];
    
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
            _shadow = [[NKSpriteNode alloc] initWithTexture:[NKTexture textureWithImageNamed:@"Card_Ipad_shadow"] color:[NKColor blackColor]  size:self.size];
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
        
        if (model.validatedSelectionSet) {
            self.color = [self colorForCategory];
        }
        else {
             self.color = [NKColor colorWithRed:.5 green:.5 blue:.5 alpha:1.];
        }
        
        [self setCorrectTexture];
        
    }
}


-(NKColor*)colorForCategory {

//    switch (_model.category) {
//        case CardCategoryKick: return V2PURPLE;
//        case CardCategoryChallenge: return V2MAGENTA;
//        case CardCategoryMove: return V2BLUE;
//        default: return NKWHITE;
//            break;
//    }
    return V2YELLOW;
}

-(void)showLabels{
    NKLabelNode *text = [NKLabelNode labelNodeWithFontNamed:@"Arial Black.ttf"];
    
    text.fontSize = 20;
    text.fontColor = V2ORANGE;
    [text setSize:S2Make(500,100)];
    //[text setZPosition:1];
    [text setText:[NSString stringWithFormat:@"%d", self.model.energyCost]];
    //[text setText:@"test"];
    [text setPosition:P2Make(0, 5)];
    [self addChild:text];
    
    
    text = [NKLabelNode labelNodeWithFontNamed:@"Arial Black.ttf"];
    text.fontSize = 16;
    text.fontColor = V2ORANGE;
    [text setSize:S2Make(500,100)];
    [text setText:[self.model descriptionForCard]];
    [text setPosition:P2Make(0, -100)];
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

-(NKTouchState)touchDown:(P2t)location id:(int)touchId {
    NKTouchState hit = [super touchMoved:location id:touchId];
    
    cachedPosition = self.position;
    lastTouch = location;
    return hit;
    
}

-(NKTouchState)touchMoved:(P2t)location id:(int)touchId {
    NKTouchState hit = [super touchMoved:location id:touchId];
    if (hit == 2) {
        if (location.y < lastTouch.y) {
            self.position = P2Make(self.position.x, self.position.y - (lastTouch.y - location.y));
            lastTouch = location;
        }
    }
    
    return hit;
    
}

-(void)showLocked {
    if (![self childNodeWithName:@"lock"]) {
        
    NKSpriteNode *lock =  [[NKSpriteNode alloc] initWithTexture:[NKTexture textureWithImageNamed:@"lock-4"] color:self.color size:S2Make(self.size.width*.5, self.size.width*.5)];
    [self addChild:lock];
    [lock setPosition:P2Make(w *.25, h*-.25)];
    lock.name = @"lock";
        
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

-(NKTouchState)touchUp:(P2t)location id:(int)touchId {
    
    NKTouchState hit = [super touchUp:location id:touchId];
    if (hit == 2) {
        
        if (self.position.y < cachedPosition.y - (h*.125)) {
            [self toggleLocked];
            [self runAction:[NKAction moveTo:cachedPosition duration:FAST_ANIM_DUR]];
        }
        else {
            
            if (!_model.locked) {
                
                numtouches++;
                if (numtouches > 1) {
                    numtouches = 0;
                    [_window cardDoubleTap:self];
                }
                else {
                    [_window cardTouchEnded:self atPoint:location];
                    [(GameScene*)self.scene playSoundWithKey:@"cardTap"];
                }
                
            }
            else {
                [(GameScene*)self.scene playSoundWithKey:@"badTouch"];
            }
        }
    }
    return hit;
}

-(NKAction*)goBack {
    
    NKAction *goBack = [NKAction moveTo:_origin duration:FAST_ANIM_DUR];
    
    [goBack setTimingMode:NKActionTimingEaseIn];
    
    return goBack;
    
}



-(void)updateWithTimeSinceLast:(F1t)dt {
    
    touchTimer -= dt;
    if (touchTimer < 0) {
        numtouches = 0;
        touchTimer = 600.;
    }
    
    [super updateWithTimeSinceLast:dt];
}

@end
