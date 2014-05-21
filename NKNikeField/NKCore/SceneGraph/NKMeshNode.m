//
//  NKMeshNode.m
//  nike3dField
//
//  Created by Chroma Developer on 3/31/14.
//
//

#import "NodeKitten.h"


@implementation NKMeshNode


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
        
        
        NSString *pstring = [NKStaticDraw stringForPrimitive:primitive];
        
        if ([[NKStaticDraw meshesCache]objectForKey:pstring]) {
            _vertexBuffer = [[NKStaticDraw meshesCache]objectForKey:pstring];
        }
        
        else {
            switch (primitive) {
                    
                case NKPrimitiveSphere:
                    _vertexBuffer = [NKVertexBuffer sphereWithStacks:8 slices:16 squash:1.];
                    _drawMode = GL_TRIANGLE_STRIP;
                    break;
                    
                case NKPrimitiveCube:
                    _vertexBuffer = [NKVertexBuffer defaultCube];
                    _drawMode = GL_TRIANGLES;
                    break;
                    
                case NKPrimitiveRect:
                    _vertexBuffer = [NKVertexBuffer defaultRect];
                    _drawMode = GL_TRIANGLES;
                    break;
                    
                case NKPrimitiveAxes:
                    _vertexBuffer = [NKVertexBuffer axes];
                    _drawMode = GL_LINES;
                    break;
                    
                default:
                    break;
                    
            }
            
            
            [[NKStaticDraw meshesCache] setObject:_vertexBuffer forKey:pstring];
            
            NSLog(@"add primitive: %@ to mesh cache with %d vertices", pstring, _vertexBuffer.numberOfElements);
            
        }
        
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
    
    if (self.scene.boundVertexBuffer != _vertexBuffer) {
        [_vertexBuffer bind];
        self.scene.boundVertexBuffer = _vertexBuffer;
    }
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, _vertexBuffer.numberOfElements);
    
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
                
                if (self.scene.boundTexture != _texture) {
                    [_texture bind];
                    self.scene.boundTexture = _texture;
                }
                
                [self.scene.activeShader setInt:1 forUniform:UNIFORM_NUM_TEXTURES];
            }
            
            else {
                [self.scene.activeShader setInt:0 forUniform:UNIFORM_NUM_TEXTURES];
            }
            
            if (self.scene.boundVertexBuffer != _vertexBuffer) {
                [_vertexBuffer bind];
                self.scene.boundVertexBuffer = _vertexBuffer;
            }
            
            glDrawArrays(_drawMode, 0, _vertexBuffer.numberOfElements);
            
            [self.scene popMatrix];
            
        }
    }
    else {
        if (_texture || _color) {
            
            glPushMatrix();
            glScalef(w,h,d);
            
            if (self.scene.boundVertexBuffer != _vertexBuffer) {
                [_vertexBuffer bind];
                self.scene.boundVertexBuffer = _vertexBuffer;
            }
            
            glDrawArrays(_drawMode, 0, _vertexBuffer.numberOfElements);
//            if (_texture) {
//                [_vertexBuffer drawWithTexture:_texture color:self.glColor];
//            }
//            else {
//                [_vertexBuffer drawWithColor:self.glColor];
//            }
            
            glPopMatrix();
        }
    }
}



@end

