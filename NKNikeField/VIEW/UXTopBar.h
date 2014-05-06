//
//  UXTopBar.h
//  NKNikeField
//
//  Created by Chroma Developer on 4/17/14.
//  Copyright (c) 2014 Chroma Developer. All rights reserved.
//

#import "UXWindow.h"

@class GameScene;

@interface UXTopBar : NKSpriteNode {
    S2t cardSize;
    NKLabelNode *fuelPoints;
    NKLabelNode *fuelLabel;
}

@property (nonatomic, weak) GameScene *delegate;
@property (nonatomic, weak) Manager *manager;
@property (nonatomic, strong) NSMutableArray* playerSprites;

@property (nonatomic) int fuel;

@end
