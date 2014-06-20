//
//  MenuScene.m
//  nike3dField
//
//  Created by Chroma Developer on 3/25/14.
//
//

#import "Menus.h"
#import "NodeKitten.h"
#import "GameScene.h"
#if TARGET_OS_IPHONE
#import "NikeViewController.h"
#endif
#import "Game.h"

@implementation MainMenu


-(instancetype)initWithSize:(S2t)size {
    self = [super initWithSize:size];
    
    if (self) {
        
        NKSpriteNode *bg = [[NKSpriteNode alloc]initWithTexture:[NKTexture textureWithImageNamed:@"Screen_Menu.png"] color:NKWHITE size:self.size2d];
        [self addChild:bg];
        
       // [bg repeatAction:[NKAction sequence:@[[NKAction fadeAlphaTo:0 duration:1.],[NKAction fadeAlphaTo:1. duration:1.]]]];
        //[bg repeatAction:[NKAction rotateByAngles:90 duration:1]];
//        fuelBar = [[FuelBar alloc] init];
//        [fuelBar setPosition:P2Make(-72*w/640, 500*h/1136)];
//        // @LEIF - not sure why the animation isn't working here?
//        [self addChild:fuelBar];
//        // @Eric - add as child before setFill, needs parent for animation otherwise doesn't get animation updates.
//        // also we need a way to snap and animate so I added 'animated' boolean.
//        [fuelBar setFill:0 animated:false];
//        [fuelBar setFill:1 animated:true];

//        NKScrollNode* table = [[NKScrollNode alloc] initWithColor:nil size:self.size];
//        [self addChild:table];
//        [table setPadding:P2Make(0,0)];
//        // table.scrollingEnabled = true;
//        table.scale = 1.02;  // to correct for image...this needs to be fixed
//        table.name = @"table";
//        table.delegate = self;
//        //V3t rot =
//        //table.node->setOrientation
//        
//        NKMeshNode *s = [[NKMeshNode alloc]initWithPrimitive:NKPrimitiveSphere texture:[NKTexture textureWithImageNamed:@"Screen_Menu.png"] color:NKWHITE size:V3MakeF(100.)];
//        [self addChild:s];
        
        [NKSoundManager loadSoundFileNamed:@"Androyd-Bulbtone-41.wav"];
        [NKSoundManager loadSoundFileNamed:@"03 Bass [A$AP Rocky].mp3"];
        [NKSoundManager playMusicNamed:@"03 Bass [A$AP Rocky].mp3"];
    }
    
    NSLog(@"initmainmenu");
    return self;
}

-(void)handleEvent:(NKEvent *)event {
    
    if (NKEventPhaseEnd == event.phase) {
        
    [NKSoundManager playSoundNamed:@"Androyd-Bulbtone-41.wav"];
    
    NSLog(@"MainMenu touchUP location = %f,%f",event.screenLocation.x, event.screenLocation.y);
    R4t syncButtonRect = R4Make(200, 500, 400, 200);
    R4t startButtonRect = R4Make(200, 200, 400, 200);
    
    R4t HiddenAIButtonRect = R4Make(200, 700, 400, 200);
    
    if(R4ContainsPoint(syncButtonRect,event.screenLocation)){
        NSLog(@"*NSYNC!");
#if TARGET_OS_IPHONE
        NikeViewController* sync = [[NikeViewController alloc]init];
        [self.nkView.controller presentViewController:sync animated:YES completion:^{
            
        }];
#endif
    }
    else if(R4ContainsPoint(startButtonRect, event.screenLocation)){
        NSLog(@"start button pressed, starting game...");
        Pregame* newScene = [[Pregame alloc] initWithSize:self.size2d];
        [self.nkView setScene:newScene];
        
   //     RecapMenuWin *recapMenuWin = [[RecapMenuWin alloc] initWithSize:self.size];
   //     [self.nkView setScene:recapMenuWin];

//        NKSceneNode* newScene = [[GameScene alloc]initWithSize:self.size];
//        [[(GameScene*)newScene game] startSinglePlayerGame];
//        self.nkView.scene = newScene;
    }
    else if(R4ContainsPoint(HiddenAIButtonRect,event.screenLocation)){
        NSLog(@"AI button pressed, starting game...");
        NKSceneNode* newScene = [[GameScene alloc]initWithSize:self.size2d];
        [[(GameScene*)newScene game] startAIGame];
        self.nkView.scene = newScene;
    }
        
    }
}

-(void)cellWasSelected:(NKScrollNode *)cell {
   // NSLog(@"MainMenu cellWasSelected: %@ was selected", cell.name);
    
}

-(void)cellWasDeSelected:(NKScrollNode *)cell {
    
}

@end
