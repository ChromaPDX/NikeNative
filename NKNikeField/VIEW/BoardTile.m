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

-(instancetype)initWithTexture:(NKTexture*)texture color:(NKByteColor *)color size:(S2t)size {
    self = [super initWithTexture:texture color:color size:size];

    if (self){
        
       
        
      // box = (ofPlanePrimitive*)new ofBoxPrimitive(size.width, size.height, 4);
    }
    return self;
}

-(NSString*)name{
    return [NSString stringWithFormat:@"TILE: %ld %ld",(long)_location.x,(long)_location.y ];
}

-(void)handleEvent:(NKEvent *)event {
    
    if (NKEventPhaseEnd == event.phase) {
//    NKTouchState hit = [super touchUp:location id:touchId];
//    if (hit == 2) {
        _delegate.selectedBoardTile = self;
//    }
//    return hit;
    }
}



-(NSString*)stringForBorderTex:(BorderMask)border {
    
    NSMutableString* retval = [[NSMutableString alloc] init];
    switch (border) {
            
        case BorderMaskAll:
            retval = [@"tile_all" mutableCopy];
            break;
        case BorderMaskBottom:
            retval =  [@"tile_bottom" mutableCopy];
            break;
        case BorderMaskLeft:
            retval =  [@"tile_left" mutableCopy];
            break;
        case BorderMaskRight:
            retval =  [@"tile_right" mutableCopy];
            break;
        case BorderMaskTop:
            retval =  [@"tile_top" mutableCopy];
            break;
        case BorderMaskBottomLeft:
            retval =  [@"tile_bottomleft" mutableCopy];
            break;
        case BorderMaskBottomRight:
            retval =  [@"tile_bottomright" mutableCopy];
            break;
        case BorderMaskTopLeft:
            retval =  [@"tile_topleft" mutableCopy];
            break;
        case BorderMaskTopRight:
            retval =  [@"tile_topright" mutableCopy];
            break;
        case BorderMaskHorizontal:
            retval =  [@"tile_horizontal" mutableCopy];
            break;
        case BorderMaskVertical:
            retval =  [@"tile_vertical" mutableCopy];
            break;
        case BorderMask3Bottom:
            retval =  [@"tile_3bottom" mutableCopy];
            break;
        case BorderMask3Left:
            retval =  [@"tile_3left" mutableCopy];
            break;
        case BorderMask3Right:
            retval =  [@"tile_3right" mutableCopy];
            break;
        case BorderMask3Top:
            retval =  [@"tile_3top" mutableCopy];
            break;
        default:
            retval =  [@"tile_none" mutableCopy];
            return retval;
            break;
    }
    return retval;
}

-(NSString*)stringForOverlayTex:(BorderMask)border {
    NSMutableString *retVal = [[self stringForBorderTex:border] mutableCopy];
    [retVal appendString:@"_dotted"];
    NSLog(@"stringForBorderText dotted value = %@", retVal);
    return retVal;
}

-(void)setTextureForBorder:(BorderMask)border {
    self.texture = [NKTexture textureWithImageNamed:[self stringForBorderTex:border]];
}

-(void)setOverlayTextureForBorder:(BorderMask)border {
    _overlay.texture = [NKTexture textureWithImageNamed:[self stringForOverlayTex:border]];
}

-(void)showOverlay{
    NKTexture *texture = [NKTexture textureWithImageNamed:[self stringForOverlayTex:self.location.borderShape]];
    
    _overlay = [[NKSpriteNode alloc] initWithTexture:texture color:NKWHITE size:self.size];
    [self addChild:_overlay];
    [_overlay setZPosition:2];
    _overlay.alpha = .8;
    //[_overlay setZPosition:3];
}

-(void)hideOverlay{
    [self removeChild:_overlay];
    _overlay.hidden = TRUE;
    _overlay = nil;
}

@end
