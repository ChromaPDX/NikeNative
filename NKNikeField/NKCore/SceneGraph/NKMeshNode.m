//
//  NKMeshNode.m
//  nike3dField
//
//  Created by Chroma Developer on 3/31/14.
//
//

#import "NodeKitten.h"


@implementation NKMeshNode

-(instancetype)initWithObjFileNamed:(NSString*)name texture:(NKTexture*)texture size:(V3t)size {
    
    self = [super init];
    if (self) {
        self.size3d = size;
        self.texture = texture;
        self.alpha = 1.;
        // ROBBY
        _colorBlendFactor = 1.;
        
        if (self.texture && !_color) {
            self.color = NKWHITE;
        }
        
        NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"obj"];
        _mesh = [[NKMesh alloc] initWithPath:path];
        
    }
    
    return self;
    
}

-(instancetype)initWithPrimitive:(NKPrimitive)primitive texture:(NKTexture*)texture color:(UIColor *)color size:(V3t)size {
    
    self = [super init];
    if (self) {
        self.size3d = size;
        self.texture = texture;
        self.alpha = 1.;
        _colorBlendFactor = 1.;
        self.color = color;
        
        if (self.texture && !_color) {
            self.color = NKWHITE;
        }
        
        _mesh = [[NKMesh alloc]initWithPrimitive:primitive];
        
    }
    
    return self;
}

-(void)setColor:(UIColor *)color {
    _color = color;
    _intColor = [self glColor];
}

-(void)setAlpha:(CGFloat)alpha {
    
    [super setAlpha:alpha];
    _intColor = [self glColor];
}

-(NKColor*)textureColorForSprite {
    
    if (_color) {
        float col[4];
        
        [_color getRed:&col[0] green:&col[1] blue:&col[2] alpha:&col[3]];
        
        col[3] *= self.alpha;
        
        return [NKColor colorWithRed:cblend(col[0],self.colorBlendFactor) green:cblend(col[1], self.colorBlendFactor) blue:cblend(col[2], self.colorBlendFactor) alpha:col[3]];
    }
    
    return NKWHITE;
    
}

-(C4t)glColor {
    C4t col;
    if (_texture) {
            [[self textureColorForSprite] getRed:&col.r green:&col.g blue:&col.b alpha:&col.a];
    }
    else {
        [_color getRed:&col.r green:&col.g blue:&col.b alpha:&col.a];
        col.a *= self.alpha;
    }
    return col;
}

-(void)customDraw {
    
    if (_texture || _color) {
    
    glPushMatrix();
    glScalef(w,h,d);
    
    if (_texture) {
        [_mesh drawWithTexture:_texture color:_intColor];
    }
    else {
        [_mesh drawWithColor:_intColor];
    }

    glPopMatrix();
        
    }
}



@end

