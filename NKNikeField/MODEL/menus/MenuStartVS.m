//
//  MenuScene.m
//  nike3dField
//
//  Created by Chroma Developer on 3/25/14.
//
//

#import "MenuStartVS.h"
#import "NodeKitten.h"
#import "GameScene.h"
#import "Game.h"


@implementation MenuStartVS


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
        
        NKTexture *image = [NKTexture textureWithImageNamed:[NSString stringWithFormat:@"screens_01_vspagenew.png"]];
        [table setTexture:image];
        [table setHighlightColor:NKBLACK];
        table.color = NKWHITE;
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

-(void)handleEvent:(NKEvent *)event {
    
    if (NKEventPhaseEnd == event.phase) {
        // NSLog(@"MenuStartVS.m touchUP location = %f,%f", location.x, location.y);
        R4t buttonRect = R4Make(95, 80, 130, 55);
        if(R4ContainsPoint(buttonRect, event.screenLocation)){
            NSLog(@"start button pressed, starting game...");
            NKSceneNode* newScene = [[GameScene alloc]initWithSize:self.size];
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
