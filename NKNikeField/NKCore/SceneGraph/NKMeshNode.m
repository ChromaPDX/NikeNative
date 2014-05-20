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

-(instancetype)initWithPrimitive:(NKPrimitive)primitive texture:(NKTexture*)texture color:(NKByteColor *)color size:(V3t)size {
    
    self = [super init];
    if (self) {
        self.size3d = size;
        
        if (self.size3d.z == 0) {
            [self setSize3d:V3Make(self.size.x, self.size.y, 1.)];
        }
        
        self.texture = texture;
        
        self.alpha = 1.0f;
        _colorBlendFactor = 1.;
        
        if (color) {
            self.color = color;        }
        
        if (self.texture && !_color) {
            self.color = NKWHITE;
        }

        _mesh = [[NKMesh alloc]initWithPrimitive:primitive];
        
        self.cullFace = NKCullFaceBack;
    }
    
    return self;
}

//-(void)setColor:(NKColor *)color {
//    _color = color;
//    _intColor = [self glColor];
//}
//
//-(void)setTransparency:(F1t)transparency {
//    [super setTransparency:transparency];
//    _intColor.a = self.alpha;
//}
//
//-(void)recursiveAlpha:(F1t)alpha {
//    [super recursiveAlpha:alpha];
//    _intColor.a = self.alpha;
//}

//-(C4t)glColor {
//    C4t col;
//    if (_texture) {
//        CGFloat c[4];
//        
//        [_color getRed:&c[0] green:&c[1] blue:&c[2] alpha:&c[3]];
//        
//        if (self.colorBlendFactor > 0.) {
//            F1t colBlend = self.colorBlendFactor;
//            col.r =cblend(c[0],colBlend);
//            col.g =cblend(c[1],colBlend);
//            col.b =cblend(c[2],colBlend);
//        }
//        else {
//            col.r = c[0];
//            col.g = c[1];
//            col.b = c[2];
//        }
//        
//        col.a = c[3] * self.alpha;
//        //  [[self textureColorForSprite] getRed:&col.r green:&col.g blue:&col.b alpha:&col.a];
//    }
//    else {
//        CGFloat c[4];
//
//        [_color getRed:&c[0] green:&c[1] blue:&c[2] alpha:&c[3]];
//        col.r = c[0];
//        col.g = c[1];
//        col.b = c[2];
//        col.a = c[3] * self.alpha;
//    }
//    return col;
//}

-(void)customDrawForHitDetection {
    [self.scene pushScale:self.size3d];
    
    [self.scene.activeShader setVec4:self.uidColor.C4Color forUniform:UNIFORM_COLOR];
    
    [_mesh draw];
    
    [self.scene popMatrix];
}

-(C4t)glColor {
    return [[self color] colorWithBlendFactor:_colorBlendFactor alpha:self.alpha];
}

-(void)customDraw {
    
    if (NK_GL_VERSION == 2) {
        
        if (_color || _texture) {
            
            [self.scene pushScale:self.size3d];
            
            C4t col;
            
            if (_color.alpha) {
                col = [self glColor];
                //NSLog(@"draw mesh %f, %f, %f, %f", col.r, col.g, col.b, col.a);
                [self.scene.activeShader setVec4:col forUniform:UNIFORM_COLOR];
                [self.scene.activeShader setInt:1 forUniform:USE_UNIFORM_COLOR];
            }
            else {
                [self.scene.activeShader setInt:0 forUniform:USE_UNIFORM_COLOR];
            }
            
            if (_texture) {
                [self.scene.activeShader setInt:1 forUniform:UNIFORM_NUM_TEXTURES];
                [_mesh drawWithTexture:_texture color:col];
            }
            
            else {
                [self.scene.activeShader setInt:0 forUniform:UNIFORM_NUM_TEXTURES];
                [_mesh drawWithColor:col];
            }
            
            [self.scene popMatrix];
            
        }
    }
    else {
        if (_texture || _color) {
            
            glPushMatrix();
            glScalef(w,h,d);
            
            if (_texture) {
                [_mesh drawWithTexture:_texture color:self.glColor];
            }
            else {
                [_mesh drawWithColor:self.glColor];
            }
            
            glPopMatrix();
        }
    }
}



@end

