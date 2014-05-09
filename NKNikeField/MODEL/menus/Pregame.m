
#import "Pregame.h"
#import "NodeKitten.h"
#import "GameScene.h"
#import "Menus.h"


@implementation Pregame


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
        
        NKTexture *image = [NKTexture textureWithImageNamed:[NSString stringWithFormat:@"screen_menu.png"]];
        UIColor *highlightColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
        [table setTexture:image];
        [table setHighlightColor:highlightColor];
        table.color = [UIColor colorWithRed:1 green:1 blue:1 alpha:1.0];
        
        [NKSoundManager loadSoundFileNamed:@"Androyd-Bulbtone-41.wav"];
        [NKSoundManager loadSoundFileNamed:@"03 Bass [A$AP Rocky].mp3"];
        [NKSoundManager playMusicNamed:@"03 Bass [A$AP Rocky].mp3"];
        
        NSArray *listOfNames = [FakeFriends getNamesForText:3];
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
    CGRect syncButtonRect = CGRectMake(101, 301, 120, 50);
    CGRect startButtonRect = CGRectMake(101, 367, 120, 50);
    CGRect HiddenAIButtonRect = CGRectMake(116, 151, 50, 50);
    CGPoint point = CGPointMake(location.x, location.y);
    if(CGRectContainsPoint(syncButtonRect, point)){
        NSLog(@"*NSYNC!");
    }
    else if(CGRectContainsPoint(startButtonRect, point)){
        NSLog(@"start button pressed, starting game...");
        NKSceneNode* newScene = [[GameScene alloc]initWithSize:self.size];
        [[(GameScene*)newScene game] startSinglePlayerGame];
        self.nkView.scene = newScene;
    }
    else if(CGRectContainsPoint(HiddenAIButtonRect, point)){
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
