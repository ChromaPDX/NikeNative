//
//  DevMenu.m
//  nike3dField
//
//  Created by Chroma Developer on 3/25/14.
//
//

#include "ofApp.h"
#import "DevMenu.h"
#import "ofxNodeKitten.h"
#import "MiniGameScene.h"
#import "GameScene.h"
#import "Menus.h"

@implementation DevMenu 

-(instancetype)initWithSize:(CGSize)size {

    self = [super initWithSize:size];
    
    if (self){
    
    NKScrollNode *table = [[NKScrollNode alloc] initWithColor:nil size:size];
    [self addChild:table];
    
    NKScrollNode *leif = [[NKScrollNode alloc] initWithParent:table autoSizePct:.33];
    [table addChild:leif];
    leif.normalColor = [UIColor colorWithRed:1. green:.5 blue:.5 alpha:1.0];
    leif.name = @"LEIF";
    leif.delegate = self;
        
    NKLabelNode* llabel = [[NKLabelNode alloc] initWithSize:leif.size FontNamed:@"Helvetica"];
    llabel.text = @"LEIF - FIELD";
    [leif addChild:llabel];
    [llabel setZPosition:2];
        
    NKScrollNode *robby = [[NKScrollNode alloc] initWithParent:table autoSizePct:.33];
    [table addChild:robby];
    robby.normalColor = [UIColor colorWithRed:.5 green:1. blue:.5 alpha:1.0];
    robby.name = @"ROBBY";
    robby.delegate = self;
        
    NKLabelNode* rlabel = [[NKLabelNode alloc] initWithSize:leif.size FontNamed:@"Helvetica"];
    rlabel.text = @"ROBBY - MINIGAMES";
    [robby addChild:rlabel];
    [rlabel setZPosition:2];
        
    NKScrollNode *eric = [[NKScrollNode alloc] initWithParent:table autoSizePct:.33];
    [table addChild:eric];
    eric.normalColor = [UIColor colorWithRed:.5 green:.5 blue:1. alpha:1.0];
    eric.name = @"ERIC";
    eric.delegate = self;
        
    NKLabelNode* elabel = [[NKLabelNode alloc] initWithSize:leif.size FontNamed:@"Helvetica"];
    elabel.text = @"ERIC - MAIN MENU";
    [elabel setZPosition:2];
    [eric addChild:elabel];
    
    }
    
    return self;
}

-(void)cellWasSelected:(NKScrollNode *)cell {
    NSLog(@"%@ was selected", cell.name);
    
    NKSceneNode* newScene;
    
    if ([cell.name isEqualToString:@"ROBBY"]) {
        newScene = [[MiniGameScene alloc]initWithSize:self.size];

        
    }
    else if ([cell.name isEqualToString:@"ERIC"]) {
        newScene = [[GameScene alloc]initWithSize:self.size];
        [[(GameScene*)newScene game] startAIGame];
        
    }
    else if ([cell.name isEqualToString:@"LEIF"]) {
        newScene = [[GameScene alloc]initWithSize:self.size];
        
        
        [[(GameScene*)newScene game] startSinglePlayerGame];

    }
    
#ifdef OF_BACKED
    ((ofApp*)ofGetAppPtr())->scene = newScene;
#else
    self.nkView.scene = newScene;
#endif
    
}

-(void)cellWasDeSelected:(NKScrollNode *)cell {
    NSLog(@"%@ was deselected", cell.name);
}

@end
