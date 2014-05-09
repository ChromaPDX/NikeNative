//
//  NOCShaderProgram.h
//  Nature of Code
//
//  Created by William Lindmeier on 2/2/13.
//  Copyright (c) 2013 wdlindmeier. All rights reserved.
//

#import <Foundation/Foundation.h>

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

#pragma mark - SHADER CONST

#define STRINGIZE(x) #x
#define STRINGIZE2(x) STRINGIZE(x)
#define SHADER_STRING(text) @ STRINGIZE2(text)

static NSString *const nkImageVertexShaderString = SHADER_STRING
(
 attribute vec4 position;
 attribute vec4 inputTextureCoordinate;
 
 varying vec2 textureCoordinate;
 
 void main()
 {
     gl_Position = position;
     textureCoordinate = inputTextureCoordinate.xy;
 }
 );


static NSString *const nkVertexHeader = SHADER_STRING
(
 //precision highp float;
 
 attribute vec4 a_position;
 attribute vec3 a_normal;
 attribute vec4 a_color;
 attribute vec2 a_texCoord0;
 attribute vec2 a_texCoord1;
 
 uniform mat4 u_modelViewProjectionMatrix;
 uniform mat3 u_normalMatrix;
 uniform lowp int u_useUniformColor;
 uniform lowp int u_numTextures;
 uniform vec4 u_color;
 
 uniform sampler2D tex0;
 
 varying mediump vec2 v_texCoord0;
 varying mediump vec2 v_texCoord1;
 varying lowp vec4 v_color;
 );

static NSString *const nkDefaultTextureVertexShader = SHADER_STRING
(
 //precision highp float;
 
 attribute vec4 a_position;
 attribute vec3 a_normal;
 attribute vec4 a_color;
 attribute vec2 a_texCoord0;
 attribute vec2 a_texCoord1;
 
 uniform mat4 u_modelViewProjectionMatrix;
 uniform mat3 u_normalMatrix;
 uniform lowp int u_useUniformColor;
 uniform lowp int u_numTextures;
 uniform vec4 u_color;
 
 uniform sampler2D tex0;
 
 varying mediump vec2 v_texCoord0;
 varying mediump vec2 v_texCoord1;
 varying lowp vec4 v_color;
 
 void main()
{
      vec3 eyeNormal = normalize(u_normalMatrix * a_normal);
//    vec3 lightPosition = vec3(0.5, 1.5, -1.0);
      vec4 diffuseColor;
//    
    if (u_useUniformColor == 1){
        diffuseColor = u_color;
    }
    else {
        if (a_color.a > 0.){
            diffuseColor = a_color;
        }
        else {
            diffuseColor = vec4(1.,1.,1.,1.);
        }
    }
    
    //    float nDotVP = max(0.0, dot(eyeNormal, normalize(lightPosition)));
    //
    //    v_color = diffuseColor * nDotVP;
    
    v_color = diffuseColor;
    
    if (u_numTextures > 0){
        v_texCoord0 = a_texCoord0;
        if (u_numTextures > 1){
            v_texCoord1 = a_texCoord1;
        }
    }
    
    gl_Position = u_modelViewProjectionMatrix * a_position;
}
 
 );

static NSString *const nkDefaultTextureFragmentShader = SHADER_STRING
(
 uniform sampler2D tex0;
 uniform lowp int u_numTextures;
 
 varying lowp vec4 v_color;
 varying mediump vec2 v_texCoord0;
 varying mediump vec2 v_texCoord1;
 
 void main()
{
    if (u_numTextures > 0){
        gl_FragColor = texture2D(tex0, v_texCoord0) * v_color;// * v_color;
    }
    else {
        gl_FragColor = v_color;
    }
}
 
 );

static NSString *const nkFragmentHeader = SHADER_STRING
(
 uniform sampler2D tex0;
 uniform lowp int u_numTextures;
 
 varying lowp vec4 v_color;
 varying mediump vec2 v_texCoord0;
 varying mediump vec2 v_texCoord1;
 );
