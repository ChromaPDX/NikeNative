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


-(instancetype)initWithPrimitive:(NKPrimitive)primitive texture:(NKTexture*)texture color:(NKByteColor *)color size:(V3t)size;

@property (nonatomic) float colorBlendFactor;
@property (nonatomic, strong) NKByteColor* color;
@property (nonatomic) NKPrimitive primitiveType;
@end
