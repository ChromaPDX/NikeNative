//
//  PlayerNode.m
//  nike3dField
//
//  Created by Chroma Developer on 3/4/14.
//
//

#import "NikeNodeHeaders.h"
#import "BoardLocation.h"
#import "ModelHeaders.h"

@implementation PlayerSprite

//-(void)draw {
//   // ofDisableDepthTest();
//    //glDisable(GL_CULL_FACE);
//    [super draw];
//    //glEnable(GL_CULL_FACE);
//    //ofEnableDepthTest();
//}

-(NKLabelNode*)styledLabelNode {
    NKLabelNode *node = [NKLabelNode labelNodeWithFontNamed:@"Arial Black.ttf"];
    node.fontColor = _model.manager.color;
    node.fontSize = h/8.;
    return node;
}

-(NSString*)imageString {
    
    NSString *base = @"Faction";
    switch (_model.faction) {
        case FactionKinforce:
            base = [base stringByAppendingString:@"Kinforce"];
            break;
            
        case FactionGenmod:
            base = [base stringByAppendingString:@"Genmod"];
            break;
            
        case FactionPsyke:
            base = [base stringByAppendingString:@"Psyke"];
            break;
            
        case FactionSention:
            base = [base stringByAppendingString:@"Sention"];
            break;
            
        default:
            base = [base stringByAppendingString:@"Kinforce"];
            break;
    }
    
    if(self.model.game.me == self.model.manager){
        base = [base stringByAppendingString:@"Home_"];
    }
    else{
        base = [base stringByAppendingString:@"Away_"];
    }
    if (_model.used) {
        return [base stringByAppendingString:@"OFF"];
    }else{
        return [base stringByAppendingString:@"ON"];
    }
}

-(void)showEffects {
    bool effectFound = false;
    
    if(effectSprite){
        [effectSprite setColor:nil];
        effectSprite.hidden = true;
        [self removeChild:effectSprite];
        effectSprite = nil;
    }
    
    if(self.model.noLegs){
        effectSprite = [[NKSpriteNode alloc] initWithTexture:[NKTexture textureWithImageNamed:@"player_effect.png"] color:V2RED size:S2Make(h, h)];
        effectFound = true;
    }
    
    if(self.model.frozen){
        effectSprite = [[NKSpriteNode alloc] initWithTexture:[NKTexture textureWithImageNamed:@"player_effect.png"] color:V2BLUE size:S2Make(h, h)];
        effectFound = true;
        
    }
    
    if(effectFound){
        [self addChild:effectSprite];
        // @leif : not sure why this isn't working?
        effectSprite.alpha = .5;
        [self fadeInChild:effectSprite duration:FAST_ANIM_DUR withCompletion:^{
            
        }];
    }
    
    
    
}

-(void)setModel:(Player *)model {
    
    if (model) {
        
        _model = model;
        
        /*
        NKSpriteNode *shadow = [[NKSpriteNode alloc] initWithTexture:[NKTexture textureWithImageNamed:NSFWPlayerShadow] color:NKBLACK size:S2Make(w, h)];
        [shadow setAlpha:.2];
        shadow.name = @"shadow";
        
        [self addChild:shadow];
        [shadow setPosition3d:V3Make(-self.size.width * .03, self.size.width*.03, -1)];
        */
        
        cardImg = [[NKSpriteNode alloc] initWithTexture:[NKTexture textureWithImageNamed:[self imageString]] color:_model.manager.color size:S2Make(w, h)];
        
        [cardImg setOrientationEuler:V3Make(45,0,0)];
        float cardOffset = -20;
        float cardScale = .8;
        //[shadow setPosition3d:V3Make(0,cardOffset, 0)];
        [cardImg setPosition3d:V3Make(0,cardOffset, 0)];
        //[shadow setScale3d:V3Make(cardScale, cardScale, 1)];
        [cardImg setScale3d:V3Make(cardScale, cardScale, 1)];
        [self addChild:cardImg];
        
        [cardImg setZPosition:h*.34];
        self.name = model.name;
        self.userInteractionEnabled = true;
        
    }
    else NSLog(@"CAN'T ASSIGN NIL MODEL TO CARDSPRITE");
}

-(void)setStateForBar {
    [self removeChildNamed:@"shadow"];
    [cardImg removeFromParent];
    
    cardImg = [[NKSpriteNode alloc] initWithTexture:[NKTexture textureWithImageNamed:[self imageString]] color:_model.manager.color size:S2Make(w, h)];
    [self addChild:cardImg];
    
    [cardImg setZPosition:2];
    
    if (_model.ball) {
        if (![self childNodeWithName:@"ball"]) {
        BallSprite *ballSprite = [[BallSprite alloc]initWithPrimitive:NKPrimitiveSphere texture:[NKTexture textureWithImageNamed:@"ball_Texture.png"] color:nil size:V3Make(w*.25,w*.25,w*.25)];
        ballSprite.name = @"ball";
        [self addChild:ballSprite];
        [ballSprite setPosition:P2Make(w*.25, h*-.25)];
        [ballSprite repeatAction:[NKAction rotateYByAngle:120 duration:1.]];
        }
    }
    
    else {
        [self removeChildNamed:@"ball"];
    }
    //self.userInteractionEnabled = false;
}

-(void)setHighlighted:(bool)highlighted {
    
   
    
    if (highlighted && !_highlighted) {
       // NKSpriteNode *crosshairs = [[NKSpriteNode alloc] initWithTexture:[NKTexture textureWithImageNamed:NSFWPlayerHighlight] color:NKWHITE size:S2Make(TILE_WIDTH, TILE_HEIGHT)];
        NKSpriteNode *crosshairs = [[NKSpriteNode alloc] initWithTexture:[NKTexture textureWithImageNamed:NSFWPlayerHighlight] color:NKWHITE size:S2Make(self.size.width + 6, self.size.height + 22)];
        crosshairs.name = @"crosshairs";
        [self addChild:crosshairs];
        [crosshairs setZPosition: 1];
    }
    
    else if (!highlighted && _highlighted){
        [self removeChildNamed:@"crosshairs"];
        
    }
    
     [cardImg setTexture:[NKTexture textureWithImageNamed:[self imageString]]];
    
    _highlighted = highlighted;
    
}

-(void)getReadyForPosession:(void (^)())block {
    
    if (!_ball) {
        
        if (!rotate) {
            
            rotate = [[NKNode alloc]init];
            [self addChild:rotate];
            
            [rotate repeatAction:[NKAction rotateByAngle:180 duration:4.]];
            [rotate setPosition3d:V3Make(0, -20, h*.3)];

            halo = [[NKSpriteNode alloc] initWithTexture:[NKTexture textureWithImageNamed:@"Halo.png"] color:self.model.manager.color size:S2Make(h, h)];
            
            //[halo setAlpha:.5];
            [halo setColorBlendFactor:1.];
            [halo setColor:_model.manager.color];
            //[halo setPosition3d:V3Make(0, -20, h*.3)];
            

            
            NKSpriteNode *haloMarks = [[NKSpriteNode alloc] initWithTexture:[NKTexture textureWithImageNamed:@"Halo_Marks_glow.png"] color:NKWHITE size:S2Make(h, h)];
            [halo addChild:haloMarks];
            [haloMarks setZPosition:2];
            
            _ballTarget = [[NKSpriteNode alloc]initWithColor:nil size:S2Make(4, 4)];
            
            [halo addChild:_ballTarget];
            [haloMarks repeatAction:[NKAction rotateByAngle:180 duration:8.]];
            [_ballTarget setPosition3d:V3Make(0, w*.42, 0)];
            
            [rotate fadeInChild:halo duration:FAST_ANIM_DUR withCompletion:^{
                
            }];
            
        }
        
    }
    
    if (block){
    block();
    }
    
    
}


-(void)startPossession {
    if (!_ball) {
        
        _ball = _delegate.ballSprite;
        
        [_ball runAction:[NKAction repeatActionForever:[NKAction rotateByAngle:-45 duration:.2]]];
        
        [_ball runAction:[NKAction scaleTo:BALL_SCALE_SMALL duration:1.] completion:^{
             _ball.player = self;
        }];
        
       
        
        [halo runAction:[NKAction repeatActionForever:
                               [NKAction group:@[
                                                                      [NKAction rotateByAngle:180 duration:2.]
                                                    ]]]];

    }
    
}
//
//-(ofPoint)ballLoc {
//    
//    //return [self.parent convertPoint:_ballTarget.position fromNode:self];
//    //P2tloc = [_ballTarget pos
//    
//    P2tcp = [halo childLocationIncludingRotation:_ballTarget];
//    
//    return V3Make(self.position3d.x + cp.x, self.position3d.y + cp.y, halo.position3d.z + self.position3d.z);
//}


-(void)stopPosession:(void (^)())block {

        [self fadeOutChild:rotate duration:FAST_ANIM_DUR withCompletion:^{
            NSLog(@"stopped possesion : %@", _model.name);
            [_ballTarget removeFromParent];
            _ball.player = nil;
            _ball = nil;
            [rotate removeFromParent];
            rotate = nil;
            block();
        }];

}

-(NKTouchState)touchUp:(P2t)location id:(int)touchId {
    
//    NKTouchState touchState = [super touchUp:location id:touchId];
//    
//    if (touchState == NKTouchIsFirstResponder){
        [_delegate playerSpriteDidSelectPlayer:self.model];
//    }
//
//    return touchState;
    return false;
}


@end
