
#import "NikeNodeHeaders.h"
#import "BoardLocation.h"
#import "ModelHeaders.h"
#import "FuelBar.h"

@implementation FuelBar
{
    NKSpriteNode *fuelContainer;
}

-(instancetype) init{

    NSLog(@"init FuelBar");
    NKTexture *image = [NKTexture textureWithImageNamed:[NSString stringWithFormat:@"fuelbar_fuel.png"]];
    fuel = [[NKSpriteNode alloc] initWithTexture:image];

    [fuel setZPosition:3];
    
    
    NKTexture *imageContainer = [NKTexture textureWithImageNamed:[NSString stringWithFormat:@"FuelBar_Container.png"]];
    fuelContainer = [[NKSpriteNode alloc] initWithTexture:imageContainer];
    [fuelContainer setYScale:1.15];
    [fuelContainer setXScale:1];
    [fuelContainer setPosition2d:P2Make(0, .5)];
    [fuelContainer setZPosition:2];
    
    
    S2t imageSize = [imageContainer size];
    
    self = [super initWithTexture:nil color:nil size:imageSize];
    [self setScale:V3Make(.98, 1, 1)];

   // [self addChild:fuelContainer];
    [self addChild:fuel];
    
    return self;
}

- (void)setFill:(float)fill animated:(bool)animated {
    
    
    if(fill > 1.0)fill = 1.0;
    
    S2t size = fuelContainer.size.point;
    
    size.width = fuelContainer.size.width * fill;
    P2t point = P2Make((-fuelContainer.size.width/2) + (size.width/2), 0);

    if (animated) {

    [fuel removeAllActions];
    [fuel runAction:[NKAction group:@[[NKAction resizeToWidth:size.width height:size.height duration:1.],
                                      [NKAction move2dTo:point duration:1.]]]];
    }
    
    else {
        fuel.size2d = size;
        fuel.position2d = point;
    }
    
}

@end
