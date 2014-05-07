#import "NKSpriteNode.h"

@interface FuelBar : NKSpriteNode
{
    NKSpriteNode* fuel;
}

- (instancetype)init;
- (void)setFill:(float)fill;

@end
