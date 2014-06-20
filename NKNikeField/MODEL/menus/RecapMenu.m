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
        NKScrollNode* table = [[NKScrollNode alloc] initWithColor:nil size:self.size.point];
        [self addChild:table];
        [table setPadding:P2Make(0,0)];
        // table.scrollingEnabled = true;
        table.scaleF = 1.02;  // to correct for image...this needs to be fixed
        table.name = @"table";
        table.delegate = self;
        NKTexture *image;
        image = [NKTexture textureWithImageNamed:[NSString stringWithFormat:@"Screen_RecapWinNoText.png"]];
       // UIColor *highlightColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
        [table setTexture:image];
        [table setHighlightColor:NKBLACK];
        [table setColor:NKWHITE];
    }

    return self;
}



-(void)handleEvent:(NKEvent *)event {
    
    if (NKEventPhaseEnd == event.phase) {
        [NKSoundManager playSoundNamed:@"Androyd-Bulbtone-41.wav"];
        
        NSLog(@"RecapMenuWin touchUP location = %f,%f", event.screenLocation.x, event.screenLocation.y);
        CGRect startButtonRect = CGRectMake(201, 150, 220, 100);
        
        if(CGRectContainsPoint(startButtonRect, CGPointMake(event.screenLocation.x, event.screenLocation.y))){
            NKSceneNode* newScene = [[MainMenu alloc]initWithSize:self.size.point];
            self.nkView.scene = newScene;
        }
    }
}


-(void)cellWasSelected:(NKScrollNode *)cell {
   // NSLog(@"RecapMenuWin cellWasSelected: %@ was selected", cell.name);
    
}

-(void)cellWasDeSelected:(NKScrollNode *)cell {
    
}

@end
