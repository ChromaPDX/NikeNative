//
//  NOCShaderProgram.h
//  Nature of Code
//
//  Created by William Lindmeier on 2/2/13.
//  Copyright (c) 2013 wdlindmeier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NKShaderTypes.h"

// ATTRIBUTES

typedef NS_ENUM(GLint, GLKVertexAttrib)
{
    NKVertexAttribPosition,
    NKVertexAttribNormal,
    NKVertexAttribColor,
    NKVertexAttribTexCoord0,
    NKVertexAttribTexCoord1
} NS_ENUM_AVAILABLE(10_8, 5_0);

// UNIFORMS
static NSString *const UNIFORM_MODELVIEWPROJECTION_MATRIX = @"u_modelViewProjectionMatrix";
static NSString *const UNIFORM_NORMAL_MATRIX = @"u_normalMatrix";
static NSString *const UNIFORM_COLOR = @"u_color";
static NSString *const USE_UNIFORM_COLOR = @"u_useUniformColor";
static NSString *const UNIFORM_NUM_TEXTURES = @"u_numTextures";

//GLint uniforms[NUM_UNIFORMS];

@class NKTexture;

@interface NKShaderProgram : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) GLuint glPointer;
@property (nonatomic, strong) NSMutableDictionary *attributes;
@property (nonatomic, strong) NSArray *uniformNames;
@property (nonatomic, readonly) NSDictionary *uniformLocations;

+ (instancetype)defaultShader;
- (instancetype)initWithName:(NSString *)name;
- (instancetype)initWithVertexShader:(NSString *)vertShaderName fragmentShader:(NSString *)fragShaderName;
- (instancetype)initWithVertexSource:(NSString*)vertexSource fragmentSource:(NSString*)fragmentSource;

@property (nonatomic, strong) NSString *vertexSource;
@property (nonatomic, strong) NSString *fragmentSource;

- (BOOL)load;
- (void)unload;
- (void)use;

// Convenience methods
- (void)setFloat:(const GLfloat)f forUniform:(NSString *)uniformName;
- (void)setInt:(const GLint)i forUniform:(NSString *)uniformName;

- (void)setMatrix3:(const M9t)mat forUniform:(NSString *)uniformName;
- (void)setMatrix4:(const M16t)mat forUniform:(NSString *)uniformName;

- (void)set1DFloatArray:(const GLfloat[])array withNumElements:(int)num forUniform:(NSString *)uniformName;
- (void)set2DFloatArray:(const GLfloat[])array withNumElements:(int)num forUniform:(NSString *)uniformName;
- (void)set3DFloatArray:(const GLfloat[])array withNumElements:(int)num forUniform:(NSString *)uniformName;
- (void)set4DFloatArray:(const GLfloat[])array withNumElements:(int)num forUniform:(NSString *)uniformName;

- (void)setVec4:(V4t)vec4 forUniform:(NSString *)uniformName;
- (void)setVec3:(V3t)vec3 forUniform:(NSString *)uniformName;
- (void)setVec2:(V2t)vec2 forUniform:(NSString *)uniformName;

- (void)setColor:(UIColor *)color forUniform:(NSString *)uniformName;

- (void)bindTexture:(NKTexture *)texture forUniform:(NSString *)uniformName;

- (void)enableAttribute2D:(NSString *)attribName withArray:(const GLvoid*)arrayValues;
- (void)enableAttribute3D:(NSString *)attribName withArray:(const GLvoid*)arrayValues;
- (void)disableAttributeArray:(NSString *)attribName;

@end
