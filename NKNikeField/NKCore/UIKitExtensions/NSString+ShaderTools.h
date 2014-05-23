//
//  NSString+ShaderTools.h
//  EMA Stage
//
//  Created by Leif Shackelford on 5/23/14.
//  Copyright (c) 2014 EMA. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(GLint, NKS_VARIABLE)
{
    NKS_VARIABLE_ATTRIBUTE,
    NKS_VARIABLE_UNIFORM,
    NKS_VARIABLE_VARYING
} NS_ENUM_AVAILABLE(10_8, 5_0);

typedef NS_ENUM(GLint, NKS_PRECISION)
{
    NKS_PRECISION_LOW,
    NKS_PRECISION_MEDIUM,
    NKS_PRECISION_HIGH
} NS_ENUM_AVAILABLE(10_8, 5_0);


typedef NS_ENUM(GLint, NKS_TYPE)
{
    NKS_TYPE_VEC2,
    NKS_TYPE_VEC3,
    NKS_TYPE_VEC4,
    NKS_TYPE_MAT3,
    NKS_TYPE_MAT4,
    NKS_TYPE_INT,
    NKS_TYPE_BOOL
} NS_ENUM_AVAILABLE(10_8, 5_0);

// UNIFORMS
static NSString *const NKS_UNIFORM_MODELVIEWPROJECTION_MATRIX = @"u_modelViewProjectionMatrix";
static NSString *const NKS_UNIFORM_NORMAL_MATRIX = @"u_normalMatrix";
static NSString *const NKS_UNIFORM_COLOR = @"u_color";
static NSString *const NKS_USE_UNIFORM_COLOR = @"u_useUniformColor";
static NSString *const NKS_UNIFORM_NUM_TEXTURES = @"u_numTextures";

@interface NSString (ShaderTools)

-(NSString*)variableWithType;
-(NSString*)appendNewLine:(NSString*)newLine;
-(NSString*)shaderUniformString:(NSDictionary *)uniform;
//-(NSString*)commaTerminatedStringFromArray:(NSArray*)array;


+(NSString*)nksVariable:(NKS_VARIABLE)variable precision:(NKS_PRECISION)precision type:(NKS_TYPE)type;
//+(NSString*)nksVariableString:(NKS_VARIABLE) variable;
//+(NSString*)nksPrecisionString:(NKS_VARIABLE) precision;
//+(NSString*)nksTypeString:(NKS_VARIABLE) type;

@end

@interface NSDictionary (ShaderTools)

-(NSString*)appendValueIfKey:(NSString*)key toShaderString:(NSString*)shader;

@end