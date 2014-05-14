//
//  UXTopBar.h
//  NKNikeField
//
//  Created by Chroma Developer on 4/17/14.
//  Copyright (c) 2014 Chroma Developer. All rights reserved.
//

#import "UXWindow.h"


@class GameScene;
@class FuelBar;

@interface UXTopBar : UXWindow {
    S2t cardSize;
    NKLabelNode *fuelPoints;
    NKLabelNode *fuelLabel;
}

@property (nonatomic, weak) GameScene *delegate;
@property (nonatomic, weak) Manager *manager;
@property (nonatomic, strong) NSMutableArray* playerSprites;
@property (nonatomic, strong) FuelBar *fuelBar;


@property (nonatomic) int fuel;

-(void)setPlayer:(Player*)p WithCompletionBlock:(void (^)())block;

@end
