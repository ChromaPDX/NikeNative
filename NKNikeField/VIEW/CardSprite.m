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

-(instancetype) initWithTexture:(NKTexture *)texture color:(UIColor *)color size:(CGSize)size {
    
    self = [super initWithTexture:nil color:nil size:size];
    
    if (self) {
        

        self.userInteractionEnabled = YES;
        
        NSLog(@"Card sprite alloc");
    }
    return self;
}

//-(NKLabelNode*)styledLabelNode {
//    
//    NKLabelNode *node = [NKLabelNode labelNodeWithFontNamed:@"TradeGothicLTStd-BdCn20"];
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
            [_shadow setPosition:CGPointMake(-w*.075, h*.075)];
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
        
//        _art = [[NKSpriteNode alloc] initWithTexture:[NKTexture textureWithImageNamed:@"Card_Player_Male"] color:[NKColor blueColor] size:CGSizeMake(TILE_WIDTH, TILE_WIDTH*1.3)];
//        
//        [self addChild:_art];
        
        //[_art setPosition:CGPointMake(0, -h*.05)];
        
        //        cardName = [self styledLabelNode];
        //        cardName.fontSize = (int)(h/10.);
        //        [cardName setPosition:CGPointMake(0, h*.25)];
        //        cardName.text = [model.name uppercaseString];
        
//        _doubleName = [[NKLabelNode alloc]initWithSize:self.size FontNamed:@"TradeGothicLTStd-BdCn20"];
//        _doubleName.fontSize = 20;
//        _doubleName.text = _model.name;
//        
//        [self addChild:_doubleName];
        
//        _doubleName = [self spritenodecontaininglabelsFromStringcontainingnewlines:[[model.name uppercaseString] stringByReplacingOccurrencesOfString:@" " withString:@"\n"]
//                                                                          fontname:@"TradeGothicLTStd-BdCn20"
//                                                                         fontcolor:[NKColor blackColor] fontsize:h/12.
//                                                                    verticalMargin:0 emptylineheight:0];
        
//        [self addChild:_doubleName];
//        [_doubleName setPosition:CGPointMake(-w*.38, h*.32)];
//        
//        cost = [self styledLabelNode];
//        cost.text = [NSString stringWithFormat:@"%d", (int)(_model.actionPointCost)];
//        cost.position = CGPointMake((int)(w*.33), (int)(h*.23));
//        
//        NKSpriteNode *apIcon = [NKSpriteNode spriteNodeWithTexture:[NKTexture textureWithImageNamed:@"ActionPointsIconSM"] size:CGSizeMake(w*.07,h*.07)];
//        apIcon.position = CGPointMake((int)(w*.27), (int)(h*.23));
//        
//        [self addChild:apIcon];
//        [self addChild:cost];
//        
//        
//        actionPoints = [self styledLabelNode];
//        actionPoints.text = [NSString stringWithFormat:@"%d", (int)(_model.actionPointEarn)];
//        actionPoints.position = CGPointMake((int)(-w*.38), (int)(-h*.4));
//        
//        [self addChild:actionPoints];
//        
        
        [self setCorrectTexture];
        
//        if ([_model isTypePlayer]){
//            
//            kick = [self styledLabelNode];
//            kick.text = [NSString stringWithFormat:@"%d / %d", (int)(_model.abilities.kick * 100),  (int)(_model.abilities.handling * 100)];
//            kick.position = CGPointMake(0, (int)-h*.32);
//            kick.fontSize = (int)(h/6.);
//            
//            //            dribble = [self styledLabelNode];
//            //            dribble.text = [NSString stringWithFormat:@"%d%%", (int)(_model.abilities.handling * 100)];
//            //            dribble.position = CGPointMake(w*.2, (int)(-h*.32));
//            //            dribble.fontSize = (int)(h/6.);
//            
//            [self addChild:kick];
//            //  [self addChild:dribble];
//            
//            //            NKSpriteNode *ballIcon = [NKSpriteNode spriteNodeWithTexture:[[_delegate sharedAtlas] textureNamed:@"icon_pass"] size:CGSizeMake(w*.3, w*.3)];
//            //            NKSpriteNode *passIcon = [NKSpriteNode spriteNodeWithTexture:[[_delegate sharedAtlas] textureNamed:@"icon_ball"] size:CGSizeMake(w*.3, w*.3)];
//            //            [ballIcon setPosition:CGPointMake(-.25*w, .05*w)];
//            //            [passIcon setPosition:CGPointMake(-.25*w, -.3*w)];
//            //            [self addChild:ballIcon];
//            //            [self addChild:passIcon];
//            
//            
//            //            if (_model.female) {
//            //                [_art setTexture:[NKTexture textureWithImageNamed:@"Card_Player_Female"]];
//            //            }
//            //
//            //            else {
//            //                [_art setTexture:[NKTexture textureWithImageNamed:@"Card_Player_Male"]];
//            //            }
//            
//        }
    }
}

-(NSString*)cardImageStringForType {
    switch (_model.deck.category) {
        case CardCategoryMove: return @"Move";
        case CardCategoryKick: return @"Kick";
        case CardCategoryChallenge: return @"Chal";
        case CardCategorySpecial:
            switch (_model.specialCategory) {
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

-(NKColor*)colorForCategory {

    switch (_model.category) {
        case CardCategoryKick: return V2PURPLE;
        case CardCategoryChallenge: return V2MAGENTA;
        case CardCategoryMove: return V2BLUE;
        default: return NKWHITE;
            break;
    }
}

-(void)setCorrectTexture {
    
    NSString *fileName = [NSString stringWithFormat:@"Card_Icon_%@_L%d", [self cardImageStringForType], _model.level];
    self.texture = [NKTexture textureWithImageNamed:fileName];
 //   if (!_flipped) {
        
//        if ([_model isTypePlayer]){ // Player
//            if ([_model.manager isEqual:_delegate.game.me]) {
//                self.texture = [NKTexture textureWithImageNamed:@"CardPlayerBlue"];
//                self.color = V2BLUE;
//            }
//            else {
//                
//                self.texture = [NKTexture textureWithImageNamed:@"CardPlayerRed"];
//                self.color = V2RED;
//            }
//            
//        }

   //     NKColor *color;
        
        
//        if([_model isTypeSkill]){
//            self.texture = [NKTexture textureWithImageNamed:@"CardSkill"];
//            color = V2SKILL;
//        }
//        
//        else if([_model isTypeGear]){
//            self.texture = [NKTexture textureWithImageNamed:@"CardGear"];
//            color = V2GEAR;
//        }
//        
//        else if([_model isTypeBoost]){
//            self.texture = [NKTexture textureWithImageNamed:@"CardBoost"];
//            color = V2BOOST;
//        }
//        
        
//        self.color = color;
//        
//        
//        [_art setTexture:[NKTexture textureWithImageNamed:[NSString stringWithFormat:@"Card_%@", [[_model name] stringByReplacingOccurrencesOfString:@" " withString:@"_"]]]];
//
//        
//        [_art setColor:self.color];
//        [_art setColorBlendFactor:1.];
        //NSLog(@" setting art color: %@", _art.color);
        //self.colorBlendFactor = .05;
        
        
//    }
//    
//    else {
//        self.userInteractionEnabled = NO;
//        self.texture = [NKTexture textureWithImageNamed:@"CardReplay"];
//    }
    
    
    
    
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


//-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//    //   NSLog(@"CardSprite.m : touchesBegan:");
//    
//    _touchOffset = [[touches anyObject] locationInNode:self];
//    [_window cardTouchBegan:self atPoint:[[touches anyObject] locationInNode:self.parent]];
//    
//    
//    
//}
//
//-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
//    
//    [_window cardTouchMoved:self atPoint:[[touches anyObject] locationInNode:self.parent]];
//    
//}
//
-(NKTouchState)touchUp:(CGPoint)location id:(int)touchId {
    NKTouchState hit = [super touchUp:location id:touchId];
    if (hit == 2) {
          [_window cardTouchEnded:self atPoint:location];
    }
    return hit;
}

-(NKAction*)goBack {
    
    NKAction *goBack = [NKAction moveTo:_origin duration:FAST_ANIM_DUR];
    
    [goBack setTimingMode:NKActionTimingEaseIn];
    
    return goBack;
    
}


static inline CGPoint ccp( CGFloat x, CGFloat y )
{
    return CGPointMake(x, y);
}


@end
