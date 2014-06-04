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

        
        NKSpriteNode *bg = [[NKSpriteNode alloc]initWithTexture:[NKTexture textureWithImageNamed:@"Screen_Menu.png"] color:NKWHITE size:self.size];
        [self addChild:bg];
   
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

-(NKTouchState)touchUp:(P2t)location id:(int)touchId {
    NKTouchState hit = [super touchUp:location id:touchId];
    
  
    [NKSoundManager playSoundNamed:@"Androyd-Bulbtone-41.wav"];
    
    NSLog(@"MainMenu touchUP location = %f,%f", location.x, location.y);
    R4t syncButtonRect = R4Make(200, 500, 400, 200);
    R4t startButtonRect = R4Make(200, 200, 400, 200);
    
    R4t HiddenAIButtonRect = R4Make(200, 700, 400, 200);
    
    if(R4ContainsPoint(syncButtonRect, location)){
        NSLog(@"*NSYNC!");
#if TARGET_OS_IPHONE
        NikeViewController* sync = [[NikeViewController alloc]init];
        [self.nkView.controller presentViewController:sync animated:YES completion:^{
            
        }];
#endif
    }
    else if(R4ContainsPoint(startButtonRect, location)){
        NSLog(@"start button pressed, starting game...");
        Pregame* newScene = [[Pregame alloc] initWithSize:self.size];
        [self.nkView setScene:newScene];
        
        //RecapMenuLoss *recapMenu = [[RecapMenuLoss alloc] init];
        //[self.nkView setScene:[recapMenu initWithSize:self.size]];

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
