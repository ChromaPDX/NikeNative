//
//  NKShaderVariable.h
//  EMA Stage
//
//  Created by Leif Shackelford on 5/24/14.
//  Copyright (c) 2014 EMA. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - DICTIONARY KEYS

#define NKS_STRING_CONST static NSString * const

#if TARGET_OS_IPHONE
NKS_STRING_CONST NKS_GLSL_VERSION = @"";// \n";
#else
NKS_STRING_CONST NKS_GLSL_VERSION = @"";// \n";
#endif

// SHADER DICT KEYS

NKS_STRING_CONST NKS_EXTENSIONS = @"extensions";
NKS_STRING_CONST NKS_UNIFORMS = @"uniforms";
NKS_STRING_CONST NKS_ATTRIBUTES = @"attributes";
NKS_STRING_CONST NKS_VARYINGS = @"varyings";
NKS_STRING_CONST NKS_VERT_INLINE = @"fragInline";
NKS_STRING_CONST NKS_FRAG_INLINE = @"fragInline";
NKS_STRING_CONST NKS_BATCH_SIZE = @"batchSize";
NKS_STRING_CONST NKS_PROGRAMS = @"programs";

NKS_STRING_CONST NKS_VERTEX_MAIN = @"vertexMain";
NKS_STRING_CONST NKS_FRAGMENT_MAIN = @"fragmentMain";

#pragma mark - SHADER MACROS

#define STRINGIZE(x) #x
#define STRINGIZE2(x) STRINGIZE(x)
#define SHADER_STRING(text) @ STRINGIZE2(text)

#define nksa(a,b) [NKShaderVariable variableWith:NKS_VARIABLE_ATTRIBUTE type:a name:b]
#define nksu(a,b,c) [NKShaderVariable variableWith:NKS_VARIABLE_UNIFORM precision:a type:b name:c]
#define nksua(a,b,c,d) [NKShaderVariable variableArrayWith:NKS_VARIABLE_UNIFORM precision:a type:b name:c arraySize:d]
#define nksv(a,b,c) [NKShaderVariable variableWith:NKS_VARIABLE_VARYING precision:a type:b name:c]
#define nksi(a,b,c) [NKShaderVariable variableWith:NKS_VARIABLE_INLINE precision:a type:b name:c]

#define nks(a) nksString(a)
#define nksf NSString stringWithFormat
#define nksGreater(a,b,c,d) [NSString nksIf:a greaterThan:b trueString:c falseString:d]
#define nksEquals(a,b) [NSString nksEquals:a r:b]

#pragma mark - SHADER ENUMS

typedef NS_ENUM(GLuint, NKS_ENUM)
{
    // VERTEX ATTRIBUTE POSITIONS ** THESE NEED TO STAY 0-4
    NKS_V4_POSITION,
    NKS_V3_NORMAL,
    NKS_V2_TEXCOORD,
    NKS_V4_COLOR,
    
    // GL_EXTENSIONS
    NKS_EXT_GPU_SHADER,
    NKS_EXT_DRAW_INSTANCED,
    
    // GL_SECTIONS
    NKS_VERTEX_SHADER,
    NKS_GEOMETRY_SHADER,
    NKS_FRAGMENT_SHADER,
    
    // GL VAR TYPES
    NKS_VARIABLE_ATTRIBUTE,
    NKS_VARIABLE_UNIFORM,
    NKS_VARIABLE_VARYING,
    NKS_VARIABLE_INLINE,
    
    // GL PRECISION
    NKS_PRECISION_NONE,
    NKS_PRECISION_LOW,
    NKS_PRECISION_MEDIUM,
    NKS_PRECISION_HIGH,

    // GL VECTOR TYPES
    NKS_TYPE_F1,
    NKS_TYPE_V2,
    NKS_TYPE_V3,
    NKS_TYPE_V4,
    NKS_TYPE_M9,
    NKS_TYPE_M16,
    NKS_TYPE_UB4,
    NKS_TYPE_INT,
    NKS_TYPE_BOOL,
    NKS_TYPE_SAMPLER_2D,

    NKS_STRUCT_LIGHT,
    NKS_STRUCT_MATERIAL,
    // NK VAR NAMES
    // M16
    NKS_M16_MVP,
    NKS_M16_MV,
    NKS_M16_P,
    
    // M9
    NKS_M9_NORMAL,
    

    // V3
    NKS_V3_EYE_DIRECTION,
    // V4
    NKS_V4_FINAL_COLOR,
    
    // SAMPLER
    NKS_S2D_TEXTURE,
    
    // LIGHT
    NKS_LIGHT,
    NKS_I1_NUM_LIGHTS,
    NKS_V3_LIGHT_DIRECTION,
    NKS_V3_LIGHT_HALF_VECTOR,
    NKS_F1_ATTENUATION,
    
    // GL
    NKS_V3_GL_POSITION,
    NKS_V4_GL_FRAG_COLOR,
    NKS_UINT_GL_INSTANCE_ID,
    
    // INT
    NKS_INT_NUM_TEXTURES,
    NKS_F1_INSTANCE,
    
    // BOOL
    NKS_INT_USE_UNIFORM_COLOR,
    
    // SUB-ROUTINE INLINES
    NKS_V4_LIGHT_COLOR,
    NKS_V4_TEX_COLOR
    
    // FUNCTIONS
} NS_ENUM_AVAILABLE(10_8, 5_0);

typedef NS_ENUM(GLuint, NKS_COLOR_MODE)
{
    NKS_COLOR_MODE_NONE,
    NKS_COLOR_MODE_UNIFORM,
    NKS_COLOR_MODE_VERTEX
};

@class NKShaderVariable;

// SHADER BLOCKS

// TEXTURE

NSString *textureFragmentFunction(NSDictionary *shaderDict);

// UTILS

NSString* shaderStringWithDirective(NSString* name, NSString* directive);
NSString* nksString(NKS_ENUM string);
NSString* shaderStringWithArray(NSArray *array);
NSString* shaderLineWithArray(NSArray* array);
NSString* operatorString(NSArray* variables, NSString *operator);

#define nksl(a) shaderLineWithArray(a)

typedef struct NKLightProperties {
    V3t position;
    V3t ambient;
    V3t color;

    V3t halfVector;
    V3t coneDirection;
    
    F1t spotCosCutoff;
    F1t spotExponent;
    
    F1t constantAttenuation;
    F1t linearAttenuation;
    F1t quadraticAttenuation;
    
    bool isEnabled;
    bool isLocal;
    bool isSpot;
} NKLightProperties;

struct NKMaterialProperties {
    V3t emission;
    V3t ambient;
    V3t diffuse;
    V3t specular;
    float shininess;
};

#pragma mark - VARIABLE OBJECTS

union _NKS_SCALAR {
    M16t M16;
    struct {M9t M9; V3t V3; V4t V4;};
    struct {F1t F1; I1t I1[4]; U1t U1[44];};
};

typedef union _NKS_SCALAR NKS_SCALAR;

#pragma mark - NKSHADER VARIABLE

@class NKShaderProgram;

@interface NKShaderVariable : NSObject

@property NKS_ENUM type;
@property NKS_ENUM precision;
@property NKS_ENUM variable;
@property NKS_ENUM name;

@property GLuint arraySize;
@property GLuint glLocation;

@property (nonatomic, weak) NKShaderProgram* program;

+(instancetype)variableArrayWith:(NKS_ENUM)variable precision:(NKS_ENUM)precision type:(NKS_ENUM)type name:(NKS_ENUM)name arraySize:(GLuint)arraySize;
+(instancetype)variableWith:(NKS_ENUM)variable precision:(NKS_ENUM)precision type:(NKS_ENUM)type name:(NKS_ENUM)name;
+(instancetype)variableWith:(NKS_ENUM)variable type:(NKS_ENUM)type name:(NKS_ENUM)name;

-(NSString*)nameString;
-(NSString*)declarationStringForSection:(NKS_ENUM)section;

// BINDING UNIFORMS

-(void)bindI1:(int)data;

-(void)bindV3:(V3t)data;
-(void)bindV4:(V4t)data;
-(void)bindM9:(M9t)data;
-(void)bindM16:(M16t)data;

-(void)bindV4Array:(V4t*)data count:(int)count;
-(void)bindM9Array:(M9t*)data count:(int)count;
-(void)bindM16Array:(M16t*)data count:(int)count;

-(void)bindLightProperties:(NKLightProperties*)data count:(int)count;

// GENERIC UNION FOR OTHER TYPES
-(void)pushValue:(NKS_SCALAR)value;

@end


@interface NKLightShader : NSObject

@property NKShaderVariable * position;
@property NKShaderVariable * normal;
@property NKShaderVariable * color;

@end

#pragma mark - CATEGORY HELPERS

@interface NSMutableString (ShaderTools)

-(void)appendNewLine:(NSString*)newLine;

@end

@interface NSString (ShaderTools)

-(NSArray*)arrayWithNoSpaces;

-(NSString*)appendNewLine:(NSString*)newLine;

+(NSString*)nksIf:(NKShaderVariable*)var greaterThan:(float)greater trueString:(NSString*)trueString falseString:(NSString*)falseString;
+(NSString*)nksEquals:(NKShaderVariable*)varA r:(NKShaderVariable*)varB;

@end

@interface NSDictionary (ShaderTools)
-(NKShaderVariable*)attributeNamed:(NKS_ENUM)name;
-(NKShaderVariable*)uniformNamed:(NKS_ENUM)name;
-(NKShaderVariable*)varyingNamed:(NKS_ENUM)name;
-(NKShaderVariable*)fragVarNamed:(NKS_ENUM)name;

-(NSString*)appendValueIfKey:(NSString*)key toShaderString:(NSString*)shader;

@end

