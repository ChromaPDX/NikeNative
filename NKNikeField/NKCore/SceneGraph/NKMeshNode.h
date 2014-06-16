//
//  NKMeshNode.h
//  nike3dField
//
//  Created by Chroma Developer on 3/31/14.
//
//
#import "NKPch.h"

#import "NKNode.h"
//#import "NKTexture.h"
#import "NKVertexBuffer.h"

@class NKTexture;
@class NKByteColor;
//@class NKVertexBuffer;

@interface NKMeshNode : NKNode
{
    NKVertexBuffer *_vertexBuffer;
    NSMutableArray *_textures;
    NSMutableArray *_materials;
    U1t _numTextures;
    float _colorBlendFactor;
    bool _drawBoundingBox;
    NKPrimitive _primitiveType;
    GLenum _drawMode;
}

-(instancetype)initWithObjNamed:(NSString *)name;
-(instancetype)initWithObjNamed:(NSString *)name withSize:(V3t)size normalize:(bool)normalize;
-(instancetype)initWithObjNamed:(NSString *)name withSize:(V3t)size normalize:(bool)normalize anchor:(bool)anchor;

-(instancetype)initWithPrimitive:(NKPrimitive)primitive texture:(NKTexture*)texture color:(NKByteColor *)color size:(V3t)size;
-(instancetype)initWithVertexBuffer:(NKVertexBuffer*)buffer drawMode:(GLenum)drawMode texture:(NKTexture*)texture color:(NKByteColor *)color size:(V3t)size;

-(C4t)glColor;
-(void)setTexture:(NKTexture *)texture;
-(void)setDrawMode:(GLenum)drawMode;

@end
