//
//  BoardTile.m
//  nike3dField
//
//  Created by Chroma Developer on 3/3/14.
//
//

#import "NikeNodeHeaders.h"
#import "BoardLocation.h"

@implementation BoardTile

-(instancetype)initWithTexture:(NKTexture*)texture color:(UIColor *)color size:(CGSize)size {
    self = [super initWithTexture:texture color:color size:size];
    if (self){
      // box = (ofPlanePrimitive*)new ofBoxPrimitive(size.width, size.height, 4);
    }
    return self;
}

-(NSString*)name{
    return [NSString stringWithFormat:@"TILE: %d %d",_location.x,_location.y ];
}

-(NKTouchState)touchUp:(CGPoint)location id:(int)touchId {
    NKTouchState hit = [super touchUp:location id:touchId];
    if (hit == 2) {
        _delegate.selectedBoardTile = self;
    }
    return hit;
}

-(NSString*)stringForBorderTex:(BorderMask)border {
    
    switch (border) {
            
        case BorderMaskAll: return @"tile_all.png";
            
        case BorderMaskBottom: return @"tile_bottom.png";
        case BorderMaskLeft: return @"tile_left.png";
        case BorderMaskRight: return @"tile_right.png";
        case BorderMaskTop: return @"tile_top.png";
            
        case BorderMaskBottomLeft: return @"tile_bottomleft.png";
        case BorderMaskBottomRight: return @"tile_bottomright.png";
        case BorderMaskTopLeft: return @"tile_topleft.png";
        case BorderMaskTopRight: return @"tile_topright.png";
        case BorderMaskHorizontal: return @"tile_horizontal.png";
        case BorderMaskVertical: return @"tile_vertical.png";
            
        case BorderMask3Bottom: return @"tile_3bottom.png";
        case BorderMask3Left: return @"tile_3left.png";
        case BorderMask3Right: return @"tile_3right.png";
        case BorderMask3Top: return @"tile_3top.png";
            
        default: return @"tile_none";
    }
}

-(void)setTextureForBorder:(BorderMask)border {
    self.texture = [NKTexture textureWithImageNamed:[self stringForBorderTex:border]];
}

@end
