//
//  NSString+ShaderTools.m
//  EMA Stage
//
//  Created by Leif Shackelford on 5/23/14.
//  Copyright (c) 2014 EMA. All rights reserved.
//

#import "NSString+ShaderTools.h"

@implementation NSString (ShaderTools)

-(NSString*)appendNewLine:(NSString*)newLine {
    return [self stringByAppendingString:[NSString stringWithFormat:@"\n %@",newLine]];
}

-(NSString*)shaderUniformString:(NSDictionary *)uniform {
    
#if NK_USE_GLES
    return [NSString stringWithFormat:@"uniform %@ %@",uniform[@"precision"],uniform[@"name"]];
#else
    return [NSString stringWithFormat:@"uniform %@ %@",uniform[@"direciton"],uniform[@"name"]];
#endif
}

+(NSString*)nksVariableString:(NKS_VARIABLE) variable {
    switch (variable) {
        case NKS_VARIABLE_ATTRIBUTE:
            return @"attribute";
        case NKS_VARIABLE_UNIFORM:
            return @"uniform";
        case NKS_VARIABLE_VARYING:
            return @"varying";
        default:
            return @"";
    }
}

+(NSString*)nksPrecisionString:(NKS_PRECISION) precision {
    
    switch (precision) {
        case NKS_PRECISION_LOW:
            return @"lowp";
        case NKS_VARIABLE_UNIFORM:
            return @"mediump";
        case NKS_VARIABLE_VARYING:
            return @"highp";
        default:
            return @"";
    }
    
}

+(NSString*)nksTypeString:(NKS_TYPE) type {
    switch (type) {
        case NKS_TYPE_MAT3:
            return @"mat3";
        case NKS_TYPE_MAT4:
            return @"mat4";
        case NKS_TYPE_VEC2:
            return @"vec2";
        case NKS_TYPE_VEC3:
            return @"vec3";
        case NKS_TYPE_VEC4:
            return @"vec4";
        case NKS_TYPE_INT:
            return @"int";
        case NKS_TYPE_BOOL:
            return @"boolean";
        default:
            return @"";
    }
}

+(NSString*)nksVariable:(NKS_VARIABLE)variable precision:(NKS_PRECISION)precision type:(NKS_TYPE)type {
    return [[[[NSString nksVariableString:variable] stringByAppendingString:[NSString nksPrecisionString:precision]] stringByAppendingString:[NSString nksTypeString:type]]stringByAppendingString:@";\n"];
}

@end

@implementation NSDictionary (ShaderTools)

-(NSString*)appendValueIfKey:(NSString*)key toShaderString:(NSString*)shader {
    NSString* value = [self valueForKey:key];
    if (value) {
        [shader appendNewLine:value];
    }
    // FIX THIS
    return value;
}

@end