//
//  NKMeshNode.h
//  nike3dField
//
//  Created by Chroma Developer on 3/31/14.
//
//
#import "NKPch.h"

#import "NKNode.h"
#import "NKTexture.h"
#import "NKVertexBuffer.h"

@class NKMesh;
@class NKByteColor;

@interface NKMeshNode : NKNode

@property (nonatomic, strong) NKVertexBuffer *vertexBuffer;
@property (nonatomic) GLenum drawMode;
@property (nonatomic, strong) NKTexture *texture;

-(instancetype)initWithObjNamed:(NSString *)name withSize:(V3t)size;
-(instancetype)initWithObjNamed:(NSString *)name withSize:(V3t)size normalize:(bool)normalize;
-(instancetype)initWithObjNamed:(NSString *)name withSize:(V3t)size normalize:(bool)normalize anchor:(bool)anchor;

-(instancetype)initWithPrimitive:(NKPrimitive)primitive texture:(NKTexture*)texture color:(NKByteColor *)color size:(V3t)size;
-(instancetype)initWithVertexBuffer:(NKVertexBuffer*)buffer drawMode:(GLenum)drawMode texture:(NKTexture*)texture color:(NKByteColor *)color size:(V3t)size;

@property (nonatomic) float colorBlendFactor;
@property (nonatomic) NKPrimitive primitiveType;

-(C4t)glColor;

@end
