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
#import "NikeViewController.h"
#import "Game.h"

@implementation MainMenu


-(instancetype)initWithSize:(S2t)size {
    self = [super initWithSize:size];
    
    if (self) {
        NKScrollNode* table = [[NKScrollNode alloc] initWithColor:nil size:self.size];
        [self addChild:table];
        [table setPadding:P2Make(0,0)];
        // table.scrollingEnabled = true;
        table.scale = 1.02;  // to correct for image...this needs to be fixed
        table.name = @"table";
        table.delegate = self;
        //V3t rot =
        //table.node->setOrientation
        
        NKTexture *image = [NKTexture textureWithImageNamed:[NSString stringWithFormat:@"Screen_Menu.png"]];
        UIColor *highlightColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
        [table setTexture:image];
        [table setHighlightColor:highlightColor];
        table.color = NKWHITE;
        
//       [table repeatAction:[NKAction rotateYByAngle:90 duration:2.]];
//        [table repeatAction:[NKAction sequence:@[[NKAction move3dBy:V3Make(0, .1, 1.) duration:.25],
//                             [NKAction move3dBy:V3Make(0, -.1, -1.) duration:.25],
//                                                 [NKAction rotateYByAngle:33 duration:.5]
//                             ]]];
        
        [NKSoundManager loadSoundFileNamed:@"Androyd-Bulbtone-41.wav"];
        [NKSoundManager loadSoundFileNamed:@"03 Bass [A$AP Rocky].mp3"];
        [NKSoundManager playMusicNamed:@"03 Bass [A$AP Rocky].mp3"];
    }
    
    /*
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button addTarget:self action:@selector(buttonPushed)
     forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"Show View" forState:UIControlStateNormal];
    button.frame = CGRectMake(80.0, 210.0, 160.0, 40.0);
    [self.view addSubview:button];
    */
    
    return self;
}

-(NKTouchState)touchUp:(P2t)location id:(int)touchId {
    NKTouchState hit = [super touchUp:location id:touchId];
    
  
    [NKSoundManager playSoundNamed:@"Androyd-Bulbtone-41.wav"];
    
    NSLog(@"MainMenu touchUP location = %f,%f", location.x, location.y);
    R4t syncButtonRect = R4Make(101*2, 430, 120*2, 100);
    R4t startButtonRect = R4Make(101*2, 300, 120*2, 100);
    
    R4t HiddenAIButtonRect = R4Make(116*2, 700, 50*2, 200);
    
    if(R4ContainsPoint(syncButtonRect, location)){
        NSLog(@"*NSYNC!");
        NikeViewController* sync = [[NikeViewController alloc]init];
        [self.nkView.controller presentViewController:sync animated:YES completion:^{
        
        }];
    }
    else if(R4ContainsPoint(startButtonRect, location)){
        NSLog(@"start button pressed, starting game...");
          Pregame* newScene = [[Pregame alloc] initWithSize:self.size];
         [self.nkView setScene:newScene];
//        NKSceneNode* newScene = [[GameScene alloc]initWithSize:self.size];
//        [[(GameScene*)newScene game] startSinglePlayerGame];
//        self.nkView.scene = newScene;
    }
    else if(R4ContainsPoint(HiddenAIButtonRect, location)){
        NSLog(@"AI button pressed, starting game...");
        NKSceneNode* newScene = [[GameScene alloc]initWithSize:self.size];
        [[(GameScene*)newScene game] startAIGame];
        self.nkView.scene = newScene;
    }
    return hit;
}

-(void)cellWasSelected:(NKScrollNode *)cell {
   // NSLog(@"MainMenu cellWasSelected: %@ was selected", cell.name);
    
}

-(void)cellWasDeSelected:(NKScrollNode *)cell {
    
}

@end
