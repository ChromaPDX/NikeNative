
#import "Pregame.h"
#import "NodeKitten.h"
#import "NikeNodeHeaders.h"
#import "Game.h"
#import "Menus.h"


@implementation Pregame


-(instancetype)initWithSize:(S2t)size {
    self = [super initWithSize:size];
    
    if (self) {
        NKSpriteNode *bg = [[NKSpriteNode alloc]initWithTexture:[NKTexture textureWithImageNamed:[NSString stringWithFormat:@"Screen_Pregame.png"] ] color:nil size:self.size];
        
        [self addChild:bg];
        
        fuelBar = [[FuelBar alloc] init];
        [fuelBar setPosition:P2Make(-64, 505)];
        // @LEIF - not sure why the animation isn't working here?
        [self addChild:fuelBar];
        // @Eric - add as child before setFill, needs parent for animation otherwise doesn't get animation updates.
        // also we need a way to snap and animate so I added 'animated' boolean.
        [fuelBar setFill:0 animated:false];
        [fuelBar setFill:1 animated:true];
        
        
        NKLabelNode *text = [NKLabelNode labelNodeWithFontNamed:@"Arial Black.ttf"];
        
        text.fontSize = 30;
        text.fontColor = NKWHITE;
        [text setSize:S2Make(500,100)];
        [text setZPosition:1];
        // [text setText:[listOfNames objectAtIndex:0]];
        [text setText:@"1000E"];
        [text setPosition:P2Make(-81, 385)];
        [self addChild:text];
        
        
        NSArray *listOfNames = [FakeFriends getNamesForText:3];
        NKLabelNode *bigText = [NKLabelNode labelNodeWithFontNamed:@"Arial Black.ttf"];
        
        bigText.fontSize = 20;
        bigText.fontColor = V2ORANGE;
        [bigText setSize:S2Make(500,100)];
        [bigText setZPosition:1];
        [bigText setText:[listOfNames objectAtIndex:0]];
        [bigText setPosition:P2Make(-190, 150)];
        [self addChild:bigText];
        
        NKLabelNode *bigText2 = [NKLabelNode labelNodeWithFontNamed:@"Arial Black.ttf"];
        
        bigText2.fontSize = 40;
        bigText2.fontColor = V2ORANGE;
        [bigText2 setSize:S2Make(500, 100)];
        [bigText2 setZPosition:2];
        [bigText2 setText:[listOfNames objectAtIndex:1]];
        [bigText2 setPosition:P2Make(0, 250)];
        [self addChild:bigText2];
        
        NKLabelNode *bigText3 = [NKLabelNode labelNodeWithFontNamed:@"Arial Black.ttf"];
        
        bigText3.fontSize = 20;
        bigText3.fontColor = V2ORANGE;
        [bigText3 setSize:S2Make(500,100)];
        [bigText3 setZPosition:3];
        [bigText3 setText:[listOfNames objectAtIndex:2]];
        [bigText3 setPosition:P2Make(190, 150)];
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
    R4t startButtonRect = R4Make(200, 100, 400, 200);

    if(R4ContainsPoint(startButtonRect, P2Make(location.x, location.y))){
        NSLog(@"start button pressed, starting game...");
        NKSceneNode* newScene = [[GameScene alloc]initWithSize:self.size];
        [[(GameScene*)newScene game] startSinglePlayerGame];
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
