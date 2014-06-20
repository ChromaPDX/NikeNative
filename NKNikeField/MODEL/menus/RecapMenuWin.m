//
//  MenuScene.m
//  nike3dField
//
//  Created by Chroma Developer on 3/25/14.
//
//

#import "RecapMenuWin.h"
#import "NodeKitten.h"
#import "NikeNodeHeaders.h"
#import "Menus.h"


@implementation RecapMenuWin


-(instancetype)initWithSize:(S2t)size {
    self = [super initWithSize:size];
    if (self) {
     
        NKSpriteNode *bgSprite = [[NKSpriteNode alloc]initWithTexture:[NKTexture textureWithImageNamed:@"Screen_RecapWinNoText.png"] color:nil size:self.size.point];
        [self addChild:bgSprite];
       // [bgSprite setUserInteractionEnabled:true];

        NSArray *listOfNames = [FakeFriends getNamesForText:3];
        NKLabelNode *bigText = [NKLabelNode labelNodeWithFontNamed:@"Arial Black.ttf"];

        bigText.fontSize = 20;
        bigText.fontColor = V2ORANGE;
        [bigText setSize2d:S2Make(500,100)];
        [bigText setZPosition:1];
        [bigText setText:[listOfNames objectAtIndex:0]];
        [bigText setPosition2d:P2Make(-190, 250)];
        [self addChild:bigText];
        
        NKLabelNode *bigText2 = [NKLabelNode labelNodeWithFontNamed:@"Arial Black.ttf"];

        bigText2.fontSize = 40;
        bigText2.fontColor = V2ORANGE;
        [bigText2 setSize2d:S2Make(500, 100)];
        [bigText2 setZPosition:2];
        [bigText2 setText:[listOfNames objectAtIndex:1]];
        [bigText2 setPosition2d:P2Make(0, 350)];
        [self addChild:bigText2];
        
        NKLabelNode *bigText3 = [NKLabelNode labelNodeWithFontNamed:@"Arial Black.ttf"];
        
        bigText3.fontSize = 20;
        bigText3.fontColor = V2ORANGE;
        [bigText3 setSize2d:S2Make(500,100)];
        [bigText3 setZPosition:3];
        [bigText3 setText:[listOfNames objectAtIndex:2]];
        [bigText3 setPosition2d:P2Make(190, 250)];
        [self addChild:bigText3];
 
    }

    return self;
}

-(void)handleEvent:(NKEvent *)event {
    
    if (NKEventPhaseEnd == event.phase) {
        
        [NKSoundManager playSoundNamed:@"Androyd-Bulbtone-41.wav"];
        
        NSLog(@"RecapMenu touchUP location = %f,%f", event.screenLocation.x, event.screenLocation.y);
        CGRect startButtonRect = CGRectMake(201, 100, 220, 300);
        CGPoint rect = CGPointMake(event.screenLocation.x, event.screenLocation.y);
        
        if(CGRectContainsPoint(startButtonRect, rect)){
            NKSceneNode* newScene = [[MainMenu alloc]initWithSize:self.size.point];
            self.nkView.scene = newScene;
        }
    }
    
}


@end
