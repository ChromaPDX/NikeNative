//
//  NKMeshNode.h
//  nike3dField
//
//  Created by Chroma Developer on 3/31/14.
//
//
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

#import "NKNode.h"
#import "NKTexture.h"
#import "NKMesh.h"

@class NKMesh;


@interface NKMeshNode : NKNode

@property (nonatomic, strong) NKMesh *mesh;
@property (nonatomic, strong) NKTexture *texture;

-(instancetype)initWithObjFileNamed:(NSString*)name texture:(NKTexture*)texture size:(V3t)size;
-(instancetype)initWithPrimitive:(NKPrimitive)primitive texture:(NKTexture*)texture color:(UIColor *)color size:(V3t)size;

@property (nonatomic) float colorBlendFactor;
@property (nonatomic, strong) UIColor* color;
@property (nonatomic) C4t intColor;

@end