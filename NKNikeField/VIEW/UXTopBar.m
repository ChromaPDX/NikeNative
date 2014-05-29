//
//  UXTopBar.m
//  NKNikeField
//
//  Created by Chroma Developer on 4/17/14.
//  Copyright (c) 2014 Chroma Developer. All rights reserved.
//

#import "NikeNodeHeaders.h"
#import "ModelHeaders.h"
#import "FuelBar.h"

@implementation UXTopBar

-(void)setEnergyLabelForManager:(Manager *) manager {
    [fuelLabel setColor:V2YELLOW];
   // [fuelLabel setZPosition:3];
    [fuelLabel setText:[NSString stringWithFormat:@"%dE",manager.energy]];
    [_fuelBar setFill:((float)manager.energy)/1000.00 animated:true];
}

-(instancetype) initWithTexture:(NKTexture *)texture color:(NKByteColor *)color size:(S2t)size {

    self = [super initWithTexture:texture color:color size:size];
    
    if (self) {
        
        self.name = @"UX TOP BAR";
        
        _playerSprites = [NSMutableArray arrayWithCapacity:3];
        
        self.userInteractionEnabled = true;
        
        cardSize.width =  55; //(1. / (7)) * w;
        cardSize.height = 55; //(cardSize.width * (67. / 65.));
        
        _fuelBar = [[FuelBar alloc] init];
        [_fuelBar setPosition:P2Make(-82, -13.5)];
        [_fuelBar setFill:0 animated:false];
       
        //fuelLabel = [NKLabelNode labelNodeWithFontNamed:@"Arial Black.ttf"];
        
        ///@Leif : this font doesn't load corecctly on first display, but updates correclty after first special card played, can't figure out why...
        fuelLabel = [NKLabelNode labelNodeWithFontNamed:@"MYRIADPRO-REGULAR.OTF"];
        //fuelLabel = [NKLabelNode labelNodeWithFontNamed:NULL];
        [fuelLabel setPosition:P2Make(-60+fuelLabel.size.width/2, -61)];
        //[fuelLabel setFontSize:12.0];

        [self setEnergyLabelForManager:self.manager.game.me];
        //[fuelLabel setText:@"0"];

        NKTexture *logoImage = [NKTexture textureWithImageNamed:[NSString stringWithFormat:@"TopCornerLockupEnergy"]];
        logo = [[NKSpriteNode alloc] initWithTexture:logoImage];
        [logo setPosition:P2Make(-118, 0)];

        [self addChild: logo];
        [self addChild:_fuelBar];
         
        [self addChild:fuelLabel];
    //    [self addChild:logo];
 
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
        [self setEnergyLabelForManager:p.manager];
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
    
    PlayerSprite* ps = [[PlayerSprite alloc] initWithTexture:nil color:NULL size:cardSize];
    
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
    Player* p;
    for (int i = 0; i < _playerSprites.count; i++){
        [(PlayerSprite*)_playerSprites[i] setPosition:P2Make(110 + i*(cardSize.width+25), 0)];
        p = ((PlayerSprite*)_playerSprites[i]).model;
    }
    [self setEnergyLabelForManager:p.manager];
}

-(NKTouchState) touchUp:(P2t)location id:(int)touchId {
    //P2t myLoc = location;
    //NKTouchState hit = [super touchUp:location id:touchId];
    
//    for (PlayerSprite *ps in _playerSprites) {
//        if ([ps containsPoint:location]) {
//            if (!ps.model.used){
//                self.delegate.selectedPlayer = ps.model;
//            }
//        }x
//    }
    

//    if ([fuelLabel containsPoint:location]) {
//        GameStatsViewController *stats = [[GameStatsViewController alloc]initWithGame:self.delegate.game style:UITableViewStyleGrouped];
//        [self.delegate.nkView.controller presentViewController:stats animated:YES completion:^{
//            
//        }];
//    }

    R4t menuButton = R4Make(17, 1042, 70, 70);
    if(R4ContainsPoint(menuButton, location)){
        // @eric uncomment to switch back
        // @leif : not sure why this is causing a crash??
     //   [self.scene.nkView setScene:[[MainMenu alloc]initWithSize:self.scene.size]];
//        self.scene = [[MainMenu alloc]initWithSize:S2Make(self.frame.size.width*scale, self.frame.size.height*scale)];
        NSLog(@"init first scene");
        return true;

       // recomment this
       // pop-up example
       // NKAlertSprite *test = [[NKAlertSprite alloc]initWithTexture:[NKTexture textureWithImageNamed:@"kitty"] color:NKWHITE size:S2Make(400, 400)];
       // [self.scene presentAlert:test animated:true];
    }
    return false;
}

@end
