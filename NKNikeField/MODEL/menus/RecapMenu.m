//
//  MenuScene.m
//  nike3dField
//
//  Created by Chroma Developer on 3/25/14.
//
//

#import "RecapMenu.h"
#import "NodeKitten.h"
#import "GameScene.h"
#import "Menus.h"



@implementation RecapMenu


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
        NKTexture *image;
        image = [NKTexture textureWithImageNamed:[NSString stringWithFormat:@"Screen_RecapWinNoText.png"]];
       // UIColor *highlightColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
        [table setTexture:image];
        [table setHighlightColor:NKBLACK];
        table.color = NKWHITE;
    }

    return self;
}

-(NKTouchState)touchUp:(P2t)location id:(int)touchId {
    NKTouchState hit = [super touchUp:location id:touchId];
    
    [NKSoundManager playSoundNamed:@"Androyd-Bulbtone-41.wav"];
    
    NSLog(@"RecapMenuWin touchUP location = %f,%f", location.x, location.y);
    CGRect startButtonRect = CGRectMake(201, 150, 220, 100);
    
    if(CGRectContainsPoint(startButtonRect, CGPointMake(location.x, location.y))){
        NKSceneNode* newScene = [[MainMenu alloc]initWithSize:self.size];
        self.nkView.scene = newScene;
    }
    return hit;
}

-(void)cellWasSelected:(NKScrollNode *)cell {
   // NSLog(@"RecapMenuWin cellWasSelected: %@ was selected", cell.name);
    
}

-(void)cellWasDeSelected:(NKScrollNode *)cell {
    
}

@end
