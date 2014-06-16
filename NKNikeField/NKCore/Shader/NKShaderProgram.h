//
//  NOCShaderProgram.h
//  Nature of Code
//
//  Created by William Lindmeier on 2/2/13.
//  Copyright (c) 2013 wdlindmeier. All rights reserved.
//

#import "NKPch.h"
#import "NKShaderTools.h"
// ATTRIBUTES

@class NKByteColor;

//GLint uniforms[NUM_UNIFORMS];

@class NKTexture;

@interface NKShaderProgram : NSObject

{
    int numAttributes;
    
    NSArray *attributes;
    NSSet *uniforms;
    NSSet *varyings;
    NSSet *vertexVars;
    NSSet *fragmentVars;
}

+(instancetype)newShaderNamed:(NSString*)name colorMode:(NKS_COLOR_MODE)colorMode numTextures:(NSUInteger)numTex numLights:(int)numLights withBatchSize:(int)batchSize;

+(instancetype)shaderNamed:(NSString*)name;

- (id)initWithDictionary:(NSDictionary*)shaderDict name:(NSString*)name;

- (instancetype)initWithName:(NSString *)name;
- (instancetype)initWithVertexShader:(NSString *)vertShaderName fragmentShader:(NSString *)fragShaderName;
- (instancetype)initWithVertexSource:(NSString*)vertexSource fragmentSource:(NSString*)fragmentSource;

#pragma mark - UTILS

@property (nonatomic, strong) NSString *vertexSource;
@property (nonatomic, strong) NSString *fragmentSource;

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) GLuint glPointer;

@property (nonatomic) int batchSize;

-(void)addLight:(NKLightShader*)light;

-(NSArray*)glslExtensions;

-(NKShaderVariable*)uniformNamed:(NKS_ENUM)name;
-(NKShaderVariable*)varyingNamed:(NKS_ENUM)name;
-(NKShaderVariable*)fragVarNamed:(NKS_ENUM)name;

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

- (void)setColor:(NKByteColor *)color forUniform:(NSString *)uniformName;

- (void)bindTexture:(NKTexture *)texture forUniform:(NSString *)uniformName;

- (void)enableAttribute2D:(NSString *)attribName withArray:(const GLvoid*)arrayValues;
- (void)enableAttribute3D:(NSString *)attribName withArray:(const GLvoid*)arrayValues;
- (void)disableAttributeArray:(NSString *)attribName;

-(NSString*)vertexStringFromShaderDictionary:(NSDictionary*)dict;
-(NSString*)fragmentStringFromShaderDictionary:(NSDictionary*)dict;

@end
