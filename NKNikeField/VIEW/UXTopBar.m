//
//  UXTopBar.m
//  NKNikeField
//
//  Created by Chroma Developer on 4/17/14.
//  Copyright (c) 2014 Chroma Developer. All rights reserved.
//

#import "NikeNodeHeaders.h"
#import "ModelHeaders.h"
#import "GameStatsViewController.h"
#import "FuelBar.h"

@implementation UXTopBar

-(instancetype) initWithTexture:(NKTexture *)texture color:(UIColor *)color size:(S2t)size {
    
    self = [super initWithTexture:texture color:color size:size];
    
    if (self) {
        self.name = @"UX TOP BAR";
        
        _playerSprites = [NSMutableArray arrayWithCapacity:3];
        
        self.userInteractionEnabled = true;
        
        cardSize.width =  55; //(1. / (7)) * w;
        cardSize.height = 55; //(cardSize.width * (67. / 65.));
        
        _fuelBar = [[FuelBar alloc] init];
        [_fuelBar setPosition:P2Make(-80, 10)];
        [_fuelBar setFill:0 animated:false];
        
        fuelLabel = [NKLabelNode labelNodeWithFontNamed:@"Arial Black.ttf"];
        fuelLabel.fontSize = 18;
        [fuelLabel setColor:V2YELLOW];
        [fuelLabel setText:[NSString stringWithFormat:@"ENERGY : %d",self.manager.game.me.energy]];  
        [fuelLabel setPosition:P2Make(-165, -50)];
        [fuelLabel setZPosition:3];
        
        NKTexture *logoImage = [NKTexture textureWithImageNamed:[NSString stringWithFormat:@"LOGO_Icon_Bola_small.png"]];
        NKSpriteNode* logo = [[NKSpriteNode alloc] initWithTexture:logoImage];
        //[logo setScale:.33];
        [logo setPosition:P2Make(-270, -5)];
        [logo setZPosition:4];

        [self addChild:_fuelBar];
        [self addChild:fuelLabel];
        [self addChild:logo];

        //        fuelLabel = [NKLabelNode labelNodeWithFontNamed:@"Arial Black.ttf"];
//        fuelLabel.fontSize = 36;
//        
//        [self addChild:fuelLabel];
//        
//        [fuelLabel setText:@"FUEL"];
//        [fuelLabel setPosition3d:V3Make(-w*.25, 0, 2)];
//
//        self.fuel = 1000;
    }
    
    return self;
}

-(void)setFuel:(int)fuel {
    
    if (_fuel != fuel) {
        
    
    if (fuelPoints) {
        [self fadeOutChild:fuelPoints duration:1. withCompletion:^{
        }];
    }
    
    fuelPoints = [NKLabelNode labelNodeWithFontNamed:@"Arial Black.ttf"];
    fuelPoints.fontSize = 32;
    fuelPoints.fontColor = V2GREEN;
    [self fadeInChild:fuelPoints duration:1.];
    
    [fuelPoints setText:[NSString stringWithFormat:@"%d", fuel]];
    [fuelPoints setPosition3d:V3Make(-w*.25, h*-.3, 2)];

    }
    
    _fuel = fuel;
}

-(void)removeCards {
    _manager = nil;
    
    for (PlayerSprite* ps in _playerSprites) {
        [ps removeFromParent];
    }
    [_playerSprites removeAllObjects];
    
}


-(void)setManager:(Manager *)manager {
    if (_manager) {
        [self removeCards];
    }
    _manager = manager;
    
    for (Player*p in _manager.players.inGame) {
        [self addPlayer:p animated:true withCompletionBlock:^{}];
    }
    
}

-(void)setPlayer:(Player *)p WithCompletionBlock:(void (^)())block {
    if (p) {
        
        if (![p.manager isEqual:_manager]) {
            [self setManager:p.manager];
        }
        [fuelLabel setText:[NSString stringWithFormat:@"ENERGY : %d",p.manager.energy]];
        [_fuelBar setFill:((float)p.manager.energy)/1000.00 animated:true];
        
        for (PlayerSprite* ps in _playerSprites) {
            
             [ps setStateForBar];
            
            if (ps.model == p) {
                [ps setHighlighted:true];
            }
            else {
                [ps setHighlighted:false];
            }
        }
        
        [self sortPlayers];
        
    }
//    else {
//        [self removeCards];
//    }
}

-(void)addPlayer:(Player*)p animated:(BOOL)animated withCompletionBlock:(void (^)())block{
    
    // NSLog(@"** adding card %@ from %@", card.name, card.deck.name);
    
    PlayerSprite* ps = [[PlayerSprite alloc] initWithTexture:nil color:NKCLEAR size:cardSize];
    
    ps.userInteractionEnabled = true;
    
    ps.model = p;
    ps.delegate = self.delegate;
    
    [_playerSprites addObject:ps];
    
    [self addChild:ps];
    [ps setPosition3d:V3Make(0,0,1)];
    
    if (block) {
        block();
    }
    
}

-(void)sortPlayers {
    for (int i = 0; i < 3; i++){
        [(PlayerSprite*)_playerSprites[i] setPosition:P2Make(110 + i*(cardSize.width+25), 0)];
    }
}

-(NKTouchState) touchUp:(P2t)location id:(int)touchId {
    //NKTouchState hit = [super touchUp:location id:touchId];
    
//    for (PlayerSprite *ps in _playerSprites) {
//        if ([ps containsPoint:location]) {
//            if (!ps.model.used){
//                self.delegate.selectedPlayer = ps.model;
//            }
//        }
//    }
    
    if ([fuelLabel containsPoint:location]) {
        GameStatsViewController *stats = [[GameStatsViewController alloc]initWithGame:self.delegate.game style:UITableViewStyleGrouped];
        [self.delegate.nkView.controller presentViewController:stats animated:YES completion:^{
            
        }];
    }
    
    return false;
}

@end
