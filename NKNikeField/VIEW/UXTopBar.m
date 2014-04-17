//
//  UXTopBar.m
//  NKNikeField
//
//  Created by Chroma Developer on 4/17/14.
//  Copyright (c) 2014 Chroma Developer. All rights reserved.
//

#import "NikeNodeHeaders.h"
#import "ModelHeaders.h"

@implementation UXTopBar

-(instancetype) initWithTexture:(NKTexture *)texture color:(UIColor *)color size:(CGSize)size {
    
    self = [super initWithTexture:texture color:color size:size];
    
    if (self) {
        self.name = @"UX TOP BAR";
        
        _playerSprites = [NSMutableArray arrayWithCapacity:3];
        
        self.userInteractionEnabled = true;
        
        cardSize.width = (1. / (6)) * w;
        cardSize.height = (cardSize.width * (100. / 80.));
        
    }
    return self;
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

-(void)refreshCardsForPlayer:(Player *)p WithCompletionBlock:(void (^)())block {
    if (p) {
        
        if (![p.manager isEqual:_manager]) {
            [self setManager:p.manager];
        }
        
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
    ps.model = p;
    
    [_playerSprites addObject:ps];
    
    [self addChild:ps];
    [ps setPosition3d:V3Make(0,0,0)];
    
    if (block) {
        block();
    }
    
}

-(void)sortPlayers {
    for (int i = 0; i < 3; i++){
        [_playerSprites[i] setPosition:P2Make(i*(cardSize.width+10), 0)];
    }
}

-(NKTouchState) touchUp:(CGPoint)location id:(int)touchId {
    NKTouchState hit = [super touchUp:location id:touchId];
    
    for (PlayerSprite *ps in _playerSprites) {
        if ([ps containsPoint:location]) {
            if (!ps.model.used){
                _delegate.selectedPlayer = ps.model;
            }
        }
    }
    
    return hit;
}

@end
