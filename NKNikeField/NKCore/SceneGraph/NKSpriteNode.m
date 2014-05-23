//
//  ofxGameNode.m
//  example-ofxTableView
//
//  Created by Chroma Developer on 2/13/14.
//
//

#import "NodeKitten.h"
#import <CoreText/CoreText.h>

@implementation NKSpriteNode

- (instancetype)initWithTexture:(NKTexture*)texture color:(NKByteColor*)color size:(S2t)size {
    
    self = [super init];
    
    if (self) {
        
        _colorBlendFactor = 1.;
        
        self.size3d = V3Make(size.x, size.y, 1);
        self.color = color;
        _texture = texture;
        
        NSString *pstring = [NKStaticDraw stringForPrimitive:NKPrimitiveRect];
        
        if (![[NKStaticDraw meshesCache]objectForKey:pstring]) {
             [[NKStaticDraw meshesCache] setObject:[NKVertexBuffer defaultRect] forKey:pstring];
        }
        
        _vert = [[NKStaticDraw meshesCache]objectForKey:pstring];
        _drawMode = GL_TRIANGLES;
        
        if (texture && !color) {
            _color = NKWHITE;
        }
        
        self.cullFace = NKCullFaceNone;
    }
    
    return self;
}


+ (instancetype)spriteNodeWithTexture:(NKTexture*)texture size:(S2t)size {
    NKSpriteNode *node = [[NKSpriteNode alloc] initWithTexture:texture color:NKWHITE size:size];
    return node;
}

+ (instancetype)spriteNodeWithTexture:(NKTexture*)texture {
    NKSpriteNode *node = [[NKSpriteNode alloc] initWithTexture:texture];
    return node;
}

+ (instancetype)spriteNodeWithImageNamed:(NSString *)name {
    NKSpriteNode *node = [[NKSpriteNode alloc] initWithImageNamed:name];
    return node;
}

+ (instancetype)spriteNodeWithColor:(NKByteColor*)color size:(S2t)size {
    NKSpriteNode *node = [[NKSpriteNode alloc] initWithColor:color size:size];
    return node;
}


- (instancetype)initWithTexture:(NKTexture*)texture {
    return [self initWithTexture:texture color:NKWHITE size:texture.size];
}

- (instancetype)initWithImageNamed:(NSString *)name {
    NKTexture *newTex = [NKTexture textureWithImageNamed:name];
    return [self initWithTexture:newTex color:NKWHITE size:self.texture.size];
}

- (instancetype)initWithColor:(NKByteColor*)color size:(S2t)size {
    self = [self initWithTexture:nil color:color size:S2Make(size.width, size.height)];
    
    if (self) {
    }
    
    return self;

}



// DRAW

-(void)customDraw {
    if (_vert && (_color || _texture)) {
        
        
        [self.scene pushScale:self.size3d];
        
        C4t col;
        
        if (_color.alpha) {
            col = [_color colorWithBlendFactor:_colorBlendFactor alpha:self.alpha];
            [self.scene.activeShader setVec4:col forUniform:UNIFORM_COLOR];
            [self.scene.activeShader setInt:1 forUniform:USE_UNIFORM_COLOR];
        }
        else {
            [self.scene.activeShader setInt:0 forUniform:USE_UNIFORM_COLOR];
        }
        
        if (_texture) {
            [self.scene.activeShader setInt:1 forUniform:UNIFORM_NUM_TEXTURES];
            
            if (self.scene.boundTexture != _texture) {
                [_texture bind];
                self.scene.boundTexture = _texture;
            }
        }
        
        else {
            [self.scene.activeShader setInt:0 forUniform:UNIFORM_NUM_TEXTURES];
        }
        
        if (self.scene.boundVertexBuffer != _vert) {
            [_vert bind];
            self.scene.boundVertexBuffer = _vert;
        }
        
        glDrawArrays(_drawMode, 0, _vert.numberOfElements);
        
        [self.scene popMatrix];
        
        //NSLog(@"draw mesh %f, %f, %f, %f", col.r, col.g, col.b, col.a);
        
    }
}

-(void)customdrawWithHitShader {
    [self.scene pushScale:self.size3d];
    
    [self.scene.activeShader setVec4:self.uidColor.C4Color forUniform:UNIFORM_COLOR];
    
    if (self.scene.boundVertexBuffer != _vert) {
        [_vert bind];
        self.scene.boundVertexBuffer = _vert;
    }
    
    glDrawArrays(_drawMode, 0, _vert.numberOfElements);
    
    [self.scene popMatrix];
}

- (void)updateWithTimeSinceLast:(F1t) dt {
    [super updateWithTimeSinceLast:dt];
}


@end
