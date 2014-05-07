//
//  DevMenu.m
//  nike3dField
//
//  Created by Chroma Developer on 3/25/14.
//
//

#import "DevMenu.h"
#import "NodeKitten.h"
#import "GameScene.h"
#import "Menus.h"
#import "SyncScene.h"

@implementation DevMenu 

-(instancetype)initWithSize:(S2t)size {

    self = [super initWithSize:size];
    
    if (self){
    
    NKScrollNode *table = [[NKScrollNode alloc] initWithColor:nil size:size];
    [self addChild:table];
    table.delegate = self;
    
    NKScrollNode *leif = [[NKScrollNode alloc] initWithParent:table autoSizePct:.33];
    [table addChild:leif];
    leif.normalColor = [UIColor colorWithRed:1. green:.5 blue:.5 alpha:1.0];
    leif.name = @"LEIF";

        
    NKLabelNode* llabel = [[NKLabelNode alloc] initWithSize:leif.size FontNamed:@"Arial Black.ttf"];
    llabel.text = @"HUMAN GAME";
    [leif addChild:llabel];
    [llabel setZPosition:2];
        
    NKScrollNode *robby = [[NKScrollNode alloc] initWithParent:table autoSizePct:.33];
    [table addChild:robby];
    robby.normalColor = [UIColor colorWithRed:.5 green:1. blue:.5 alpha:1.0];
    robby.name = @"ROBBY";
    
        
    NKLabelNode* rlabel = [[NKLabelNode alloc] initWithSize:leif.size FontNamed:@"Arial Black.ttf"];
    rlabel.text = @"FUEL / SYNC";
    [robby addChild:rlabel];
    [rlabel setZPosition:2];
        
    NKScrollNode *eric = [[NKScrollNode alloc] initWithParent:table autoSizePct:.33];
    [table addChild:eric];
    eric.normalColor = [UIColor colorWithRed:.5 green:.5 blue:1. alpha:1.0];
    eric.name = @"ERIC";

        
    NKLabelNode* elabel = [[NKLabelNode alloc] initWithSize:leif.size FontNamed:@"Arial Black.ttf"];
    elabel.text = @"AI+MENU";
    [elabel setZPosition:2];
    [eric addChild:elabel];
    
    }
    
    return self;
}

-(void)cellWasSelected:(NKScrollNode *)cell {
    NSLog(@"%@ was selected", cell.name);
    
    NKSceneNode* newScene;
    
    if ([cell.name isEqualToString:@"ROBBY"]) {
     //   newScene = [[MiniGameScene alloc]initWithSize:self.size];
     //   newScene = [[GameScene alloc]initWithSize:self.size];
      //  [[(GameScene*)newScene game] startAIGame];
        newScene = [[SyncScene alloc]initWithSize:self.size];
    }
    else if ([cell.name isEqualToString:@"ERIC"]) {
        newScene = [[MainMenu alloc]initWithSize:self.size];
        [[(GameScene*)newScene game] startAIGame];
    }
    else if ([cell.name isEqualToString:@"LEIF"]) {
        newScene = [[GameScene alloc]initWithSize:self.size];
        [[(GameScene*)newScene game] startSinglePlayerGame];
    }
    
    self.nkView.scene = newScene;
    
}

-(void)cellWasDeSelected:(NKScrollNode *)cell {
    NSLog(@"%@ was deselected", cell.name);
}

@end
