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
#import "Game.h"

@implementation DevMenu 

-(instancetype)initWithSize:(S2t)size {

    self = [super initWithSize:size];
    
    if (self){
    
    NKScrollNode *table = [[NKScrollNode alloc] initWithColor:nil size:size];
    [self addChild:table];
    table.delegate = self;
    
    NKScrollNode *leif = [[NKScrollNode alloc] initWithParent:table autoSizePct:.33];
    [table addChild:leif];
    leif.normalColor = [NKByteColor colorWithRed:255 green:128 blue:128 alpha:255];
    leif.name = @"LEIF";

        
    NKLabelNode* llabel = [[NKLabelNode alloc] initWithSize:leif.size.point FontNamed:@"Arial Black.ttf"];
    llabel.text = @"HUMAN GAME";
    [leif addChild:llabel];
    [llabel setZPosition:2];
        
    NKScrollNode *robby = [[NKScrollNode alloc] initWithParent:table autoSizePct:.33];
    [table addChild:robby];
    robby.normalColor = [NKByteColor colorWithRed:128 green:255 blue:128 alpha:255];
    robby.name = @"ROBBY";
    
        
    NKLabelNode* rlabel = [[NKLabelNode alloc] initWithSize:leif.size.point FontNamed:@"Arial Black.ttf"];
    rlabel.text = @"FUEL / SYNC";
    [robby addChild:rlabel];
    [rlabel setZPosition:2];
        
    NKScrollNode *eric = [[NKScrollNode alloc] initWithParent:table autoSizePct:.33];
    [table addChild:eric];
    eric.normalColor = [NKByteColor colorWithRed:128 green:128 blue:255 alpha:255];
    eric.name = @"ERIC";

        
    NKLabelNode* elabel = [[NKLabelNode alloc] initWithSize:leif.size.point FontNamed:@"Arial Black.ttf"];
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
        newScene = [[SyncScene alloc]initWithSize:self.size.point];
    }
    else if ([cell.name isEqualToString:@"ERIC"]) {
        newScene = [[GameScene alloc]initWithSize:self.size.point];
        [[(GameScene*)newScene game] startAIGame];
    }
    else if ([cell.name isEqualToString:@"LEIF"]) {
        //newScene = [[GameScene alloc]initWithSize:self.size];
        //[[(GameScene*)newScene game] startSinglePlayerGame];
        newScene = [[MainMenu alloc]initWithSize:self.size.point];
        //newScene = [[Pregame alloc]initWithSize:self.size];
    }
    
    self.nkView.scene = newScene;
    
}

-(void)cellWasDeSelected:(NKScrollNode *)cell {
    NSLog(@"%@ was deselected", cell.name);
}

@end
