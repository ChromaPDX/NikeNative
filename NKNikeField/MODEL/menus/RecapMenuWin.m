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



@implementation RecapMenuWin


-(NSArray*)getNamesForText:(int)numNames{
    NSMutableArray *retArray = [[NSMutableArray alloc] init];
    
    NSMutableArray *listOfNames = [[NSArray arrayWithObjects:
                            @"ERIC",
                            @"MARCUS",
                            @"MIKE",
                            @"VV",
                            @"LEIF",
                            NULL] mutableCopy];
    
    for(int i = 0; i < numNames; i++){
        int randVal = rand()%[listOfNames count];
        [retArray addObject:[listOfNames objectAtIndex:randVal]];
        [listOfNames removeObjectAtIndex:randVal];
    }
    return retArray;
}


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

        UIColor *highlightColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
        [table setTexture:image];
        [table setHighlightColor:highlightColor];
        table.color = [UIColor colorWithRed:1 green:1 blue:1 alpha:1.0];
        
        NSArray *listOfNames = [self getNamesForText:3];
        NKLabelNode *bigText = [NKLabelNode labelNodeWithFontNamed:@"Arial Black.ttf"];

        bigText.fontSize = 20;
        bigText.fontColor = V2ORANGE;
        [bigText setSize:S2Make(500,100)];
        [bigText setZPosition:1];
        [bigText setText:[listOfNames objectAtIndex:0]];
        [bigText setPosition:P2Make(-190, 250)];
        [self addChild:bigText];
        
        NKLabelNode *bigText2 = [NKLabelNode labelNodeWithFontNamed:@"Arial Black.ttf"];

        bigText2.fontSize = 40;
        bigText2.fontColor = V2ORANGE;
        [bigText2 setSize:S2Make(500, 100)];
        [bigText2 setZPosition:2];
        [bigText2 setText:[listOfNames objectAtIndex:1]];
        [bigText2 setPosition:P2Make(0, 350)];
        [self addChild:bigText2];
        
        NKLabelNode *bigText3 = [NKLabelNode labelNodeWithFontNamed:@"Arial Black.ttf"];
        
        bigText3.fontSize = 20;
        bigText3.fontColor = V2ORANGE;
        [bigText3 setSize:S2Make(500,100)];
        [bigText3 setZPosition:3];
        [bigText3 setText:[listOfNames objectAtIndex:2]];
        [bigText3 setPosition:P2Make(190, 250)];
        [self addChild:bigText3];
    }

    return self;
}

-(NKTouchState)touchUp:(CGPoint)location id:(int)touchId {
    NKTouchState hit = [super touchUp:P2Make(location.x, location.y) id:touchId];
    
    [NKSoundManager playSoundNamed:@"Androyd-Bulbtone-41.wav"];
    
    NSLog(@"RecapMenu touchUP location = %f,%f", location.x, location.y);
    CGRect startButtonRect = CGRectMake(97, 470, 120, 50);
    if(CGRectContainsPoint(startButtonRect, location)){
        NKSceneNode* newScene = [[MainMenu alloc]initWithSize:self.size];
        self.nkView.scene = newScene;
    }
    return hit;
}

-(void)cellWasSelected:(NKScrollNode *)cell {
   // NSLog(@"RecapMenu cellWasSelected: %@ was selected", cell.name);
    
}

-(void)cellWasDeSelected:(NKScrollNode *)cell {
    
}

@end