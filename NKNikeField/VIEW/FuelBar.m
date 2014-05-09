
#import "NikeNodeHeaders.h"
#import "BoardLocation.h"
#import "ModelHeaders.h"
#import "FuelBar.h"

@implementation FuelBar


-(instancetype) init{

    NSLog(@"init FuelBar");
    NKTexture *image = [NKTexture textureWithImageNamed:[NSString stringWithFormat:@"fuelbar_fuel.png"]];
    fuel = [[NKSpriteNode alloc] initWithTexture:image];
    
   
    [fuel setZPosition:3];
    
    NKTexture *imageContainer = [NKTexture textureWithImageNamed:[NSString stringWithFormat:@"FuelBar_Container.png"]];
    NKSpriteNode *fuelContainer = [[NKSpriteNode alloc] initWithTexture:imageContainer];
    [fuelContainer setYScale:1.15];
    [fuelContainer setXScale:1.03];
    [fuelContainer setPosition:P2Make(0, .5)];
    [fuelContainer setZPosition:2];
    
    S2t imageSize = [imageContainer size];
    
    self = [super initWithTexture:nil color:nil size:imageSize];

    [self addChild:fuelContainer];
    [self addChild:fuel];
    
    return self;
}

- (void)setFill:(float)fill{
    
    S2t size = self.size;
    size.width = self.size.width * fill;
    [fuel setSize: size];
    R4t frame = [fuel getDrawFrame];
    P2t point = P2Make(frame.x, 0);
    [fuel setPosition:point];
   // CGPoint newPoint = CGPointMake(frame.x + )

  //  [fuel runAction:[NKAction group:@[[NKAction scaleXTo:2 duration:5], [NKAction moveToX:]]]];
    
    //size.width = self.size.width * fill;
    //[fuel setSize: size];
    
}

@end
