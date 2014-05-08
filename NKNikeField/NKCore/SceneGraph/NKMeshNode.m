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
        
        if (self.size3d.z == 0) {
            [self setSize3d:V3Make(self.size.x, self.size.y, 1.)];
        }
        
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

//-(void)setAlpha:(CGFloat)alpha {
//    [super setAlpha:alpha];
//    _intColor = [self glColor];
//}

-(void)setRecursiveAlpha {
    [super setRecursiveAlpha];
    _intColor = [self glColor];
}

-(C4t)glColor {
    C4t col;
    if (_texture) {
        
        [_color getRed:&col.r green:&col.g blue:&col.b alpha:&col.a];
        
        col.a *= self.alpha;
        
        if (self.colorBlendFactor) {
            F1t colBlend = self.colorBlendFactor;
            col.r =cblend(col.r,colBlend);
            col.g =cblend(col.g,colBlend);
            col.b =cblend(col.b,colBlend);
        }
        
        //  [[self textureColorForSprite] getRed:&col.r green:&col.g blue:&col.b alpha:&col.a];
    }
    else {
        [_color getRed:&col.r green:&col.g blue:&col.b alpha:&col.a];
        col.a *= self.alpha;
    }
    return col;
}

-(void)customDraw {
    
    if (NK_GL_VERSION == 2) {
        
        if (_texture || _color) {
            
            [self.scene pushScale:self.size3d];
            
            if (_color) {
                [self.scene.activeShader setVec4:_intColor forUniform:UNIFORM_COLOR];
                [self.scene.activeShader setInt:1 forUniform:USE_UNIFORM_COLOR];
            }
            
            if (_texture) {
                [self.scene.activeShader setInt:1 forUniform:UNIFORM_NUM_TEXTURES];
                [_mesh drawWithTexture:_texture color:_intColor];
            }
            else {
                [self.scene.activeShader setInt:0 forUniform:UNIFORM_NUM_TEXTURES];
                [_mesh drawWithColor:_intColor];
            }
            
            [self.scene popMatrix];
            
        }
        
    }
    else {
        
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
}



@end

