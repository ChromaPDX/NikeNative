//
//  NKGaussianZ.m
//  NodeKittenExample
//
//  Created by Chroma Developer on 2/26/14.
//  Copyright (c) 2014 Chroma. All rights reserved.
//

#import "NKGaussianZ.h"
#import "NKShaderTypes.h"

@implementation NKGaussianZ

- (instancetype)initWithNode:(NKNode *)node paramBlock:(ShaderParamBlock)block {
    {
        _blurRadiusInPixels = 4.; // For now, only do integral sigmas
//        
//        // Calculate the number of pixels to sample from by setting a bottom limit for the contribution of the outermost pixel
//        CGFloat minimumWeightToFindEdgeOfSamplingArea = 1.0/256.0;
//        NSUInteger calculatedSampleRadius = floor(sqrt(-2.0 * pow(_blurRadiusInPixels, 2.0f) * log(minimumWeightToFindEdgeOfSamplingArea * sqrt(2.0 * M_PI * pow(_blurRadiusInPixels, 2.0f))) ));
//        calculatedSampleRadius += calculatedSampleRadius % 2; // There's nothing to gain from handling odd radius sizes, due to the optimizations I use
//
        NSUInteger calculatedSampleRadius = 4;
        
        NSLog(@"Blur radius: %f, calculated sample radius: %d", _blurRadiusInPixels, calculatedSampleRadius);
        //
        NSString *newGaussianBlurVertexShader = [NKGaussianZ vertexShaderForOptimizedBlurOfRadius:calculatedSampleRadius sigma:_blurRadiusInPixels];
        NSString *newGaussianBlurFragmentShader = [NKGaussianZ fragmentShaderForOptimizedDepthBlurOfRadius:calculatedSampleRadius sigma:_blurRadiusInPixels];
        //
        //        NSString *newGaussianBlurVertexShader = [[self class] vertexShaderForOptimizedBlurOfRadius:calculatedSampleRadius sigma:blurRadiusInPixels];
        //        NSString *newGaussianBlurFragmentShader = [[self class] fragmentShaderForOptimizedBlurOfRadius:calculatedSampleRadius sigma:blurRadiusInPixels];
        //
        
        self = [super initWithShaderStringArray:@[newGaussianBlurVertexShader, newGaussianBlurFragmentShader] node:node paramBlock:block];
        
        if (self) {
            
            shouldResizeBlurRadiusWithImageSize = NO;
            
            self.usesFbo = true;
            self.needsDepthBuffer = true;
            
        }
        
        return self;
        
    }
}

+ (NSString *)vertexShaderForOptimizedBlurOfRadius:(NSUInteger)blurRadius sigma:(CGFloat)sigma;
{
    if (blurRadius < 1)
    {
        return nkImageVertexShaderString;
    }
    
    // First, generate the normal Gaussian weights for a given sigma
    GLfloat *standardGaussianWeights = (GLfloat *)calloc(blurRadius + 1, sizeof(GLfloat));
    GLfloat sumOfWeights = 0.0;
    for (NSUInteger currentGaussianWeightIndex = 0; currentGaussianWeightIndex < blurRadius + 1; currentGaussianWeightIndex++)
    {
        standardGaussianWeights[currentGaussianWeightIndex] = (1.0 / sqrt(2.0 * M_PI * pow(sigma, 2.0f))) * exp(-pow(currentGaussianWeightIndex, 2.0) / (2.0 * pow(sigma, 2.0f)));
        
        if (currentGaussianWeightIndex == 0)
        {
            sumOfWeights += standardGaussianWeights[currentGaussianWeightIndex];
        }
        else
        {
            sumOfWeights += 2.0 * standardGaussianWeights[currentGaussianWeightIndex];
        }
    }
    
    // Next, normalize these weights to prevent the clipping of the Gaussian curve at the end of the discrete samples from reducing luminance
    for (NSUInteger currentGaussianWeightIndex = 0; currentGaussianWeightIndex < blurRadius + 1; currentGaussianWeightIndex++)
    {
        standardGaussianWeights[currentGaussianWeightIndex] = standardGaussianWeights[currentGaussianWeightIndex] / sumOfWeights;
    }
    
    // From these weights we calculate the offsets to read interpolated values from
    NSUInteger numberOfOptimizedOffsets = MIN(blurRadius / 2 + (blurRadius % 2), 7);
    GLfloat *optimizedGaussianOffsets = (GLfloat *)calloc(numberOfOptimizedOffsets, sizeof(GLfloat));
    
    for (NSUInteger currentOptimizedOffset = 0; currentOptimizedOffset < numberOfOptimizedOffsets; currentOptimizedOffset++)
    {
        GLfloat firstWeight = standardGaussianWeights[currentOptimizedOffset*2 + 1];
        GLfloat secondWeight = standardGaussianWeights[currentOptimizedOffset*2 + 2];
        
        GLfloat optimizedWeight = firstWeight + secondWeight;
        
        optimizedGaussianOffsets[currentOptimizedOffset] = (firstWeight * (currentOptimizedOffset*2 + 1) + secondWeight * (currentOptimizedOffset*2 + 2)) / optimizedWeight;
    }
    
    NSMutableString *shaderString = [[NSMutableString alloc] init];
    
    //[shaderString appendString:nkVertexHeader];
    // Header
    [shaderString appendFormat:@"\
     attribute vec4 position;\n\
     attribute vec2 texcoord;\n\
     \n\
     uniform mat4 modelViewMatrix;\n\
     uniform mat4 projectionMatrix;\n\
     uniform float texelWidthOffset;\n\
     uniform float texelHeightOffset;\n\
     uniform sampler2D depthTexture;\n\
     \n\
     varying vec2 blurCoordinates[%lu];\n\
     varying highp vec2 textureCoordinate;\n\
     \n\
     void main()\n\
     {\n\
     gl_Position = projectionMatrix * modelViewMatrix * position;\n\
     textureCoordinate = texcoord;\n\
     \n\
     highp float blurAlpha = texture2D(depthTexture, textureCoordinate).r;\n\
     vec2 singleStepOffset = vec2(texelWidthOffset, texelHeightOffset);\n", (unsigned long)(1 + (numberOfOptimizedOffsets * 2))];
    
    // Inner offset loop
    [shaderString appendString:@"blurCoordinates[0] = texcoord;\n"];
    for (NSUInteger currentOptimizedOffset = 0; currentOptimizedOffset < numberOfOptimizedOffsets; currentOptimizedOffset++)
    {
        [shaderString appendFormat:@"\
         blurCoordinates[%lu] = texcoord + singleStepOffset * %f;\n\
         blurCoordinates[%lu] = texcoord - singleStepOffset * %f;\n", (unsigned long)((currentOptimizedOffset * 2) + 1), optimizedGaussianOffsets[currentOptimizedOffset], (unsigned long)((currentOptimizedOffset * 2) + 2), optimizedGaussianOffsets[currentOptimizedOffset]];
        
//        [shaderString appendFormat:@"\
//         if (texture2D(depthTexture, blurCoordinates[%lu]).r < blurAlpha-.1){\n\
//         blurCoordinates[%lu] = texcoord;\n\
//         }\n\
//         if (texture2D(depthTexture, blurCoordinates[%lu]).r < blurAlpha-.1){\n\
//         blurCoordinates[%lu] = texcoord;\n\
//         }\n\
//         ", (unsigned long)((currentOptimizedOffset * 2) + 1),(unsigned long)((currentOptimizedOffset * 2) + 1),(unsigned long)((currentOptimizedOffset * 2) + 2),(unsigned long)((currentOptimizedOffset * 2) + 2)];
    }
    
    // Footer
    [shaderString appendString:@"}\n"];
    
    free(optimizedGaussianOffsets);
    free(standardGaussianWeights);
    return shaderString;
}

+ (NSString *)fragmentShaderForOptimizedDepthBlurOfRadius:(NSUInteger)blurRadius sigma:(CGFloat)sigma;
{
    if (blurRadius < 1)
    {
        return nkDefaultTextureFragmentShader;
    }
    
    // First, generate the normal Gaussian weights for a given sigma
    GLfloat *standardGaussianWeights = (GLfloat *)calloc(blurRadius + 1, sizeof(GLfloat));
    GLfloat sumOfWeights = 0.0;
    for (NSUInteger currentGaussianWeightIndex = 0; currentGaussianWeightIndex < blurRadius + 1; currentGaussianWeightIndex++)
    {
        standardGaussianWeights[currentGaussianWeightIndex] = (1.0 / sqrt(2.0 * M_PI * pow(sigma, 2.0f))) * exp(-pow(currentGaussianWeightIndex, 2.0) / (2.0 * pow(sigma, 2.0f)));
        
        if (currentGaussianWeightIndex == 0)
        {
            sumOfWeights += standardGaussianWeights[currentGaussianWeightIndex];
        }
        else
        {
            sumOfWeights += 2.0 * standardGaussianWeights[currentGaussianWeightIndex];
        }
    }
    
    // Next, normalize these weights to prevent the clipping of the Gaussian curve at the end of the discrete samples from reducing luminance
    for (NSUInteger currentGaussianWeightIndex = 0; currentGaussianWeightIndex < blurRadius + 1; currentGaussianWeightIndex++)
    {
        standardGaussianWeights[currentGaussianWeightIndex] = standardGaussianWeights[currentGaussianWeightIndex] / sumOfWeights;
    }
    
    // From these weights we calculate the offsets to read interpolated values from
    NSUInteger numberOfOptimizedOffsets = MIN(blurRadius / 2 + (blurRadius % 2), 7);
    NSUInteger trueNumberOfOptimizedOffsets = blurRadius / 2 + (blurRadius % 2);
    
    NSMutableString *shaderString = [[NSMutableString alloc] init];
    
    // Header
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
    [shaderString appendFormat:@"\
     uniform sampler2D tex0;\n\
     uniform highp float texelWidthOffset;\n\
     uniform highp float texelHeightOffset;\n\
     uniform sampler2D depthTexture;\n\
     \n\
     varying highp vec2 blurCoordinates[%lu];\n\
     varying highp vec2 textureCoordinate;\n\
     \n\
     void main()\n\
     {\n\
     lowp vec4 sum = vec4(0.0);\n\
     highp float blurAlpha = texture2D(depthTexture, textureCoordinate).r + texture2D(depthTexture, textureCoordinate).g + texture2D(depthTexture, textureCoordinate).b;\n\
     ", (unsigned long)(1 + (numberOfOptimizedOffsets * 2)) ];
    
#else
    [shaderString appendFormat:@"\
     uniform sampler2D tex0;\n\
     uniform float texelWidthOffset;\n\
     uniform float texelHeightOffset;\n\
     uniform sampler2D depthTexture;\n\
     varying highp vec2 textureCoordinate;\n\
     \n\
     varying vec2 blurCoordinates[%lu];\n\
     \n\
     void main()\n\
     {\n\
     highp float blurAlpha = texture2D(depthTexture, textureCoordinate).r ;\n\
     vec4 sum = vec4(0.0);\n", 1 + (numberOfOptimizedOffsets * 2) ];
#endif
    
    // Inner texture loop
    //[shaderString appendFormat:@"sum += texture2D(tex0, blurCoordinates[0]) * (1. - blurAlpha);\n"]; //, standardGaussianWeights[0]];
    //[shaderString appendFormat:@"sum += texture2D(tex0, blurCoordinates[0]) * %f;\n", standardGaussianWeights[0]];
    
    
    for (NSUInteger currentBlurCoordinateIndex = 0; currentBlurCoordinateIndex < numberOfOptimizedOffsets; currentBlurCoordinateIndex++)
    {
        GLfloat firstWeight = standardGaussianWeights[currentBlurCoordinateIndex * 2 + 1];
        GLfloat secondWeight = standardGaussianWeights[currentBlurCoordinateIndex * 2 + 2];
        GLfloat optimizedWeight = firstWeight + secondWeight;
        
        [shaderString appendFormat:@"sum += texture2D(tex0, blurCoordinates[%lu]) * %f;\n", (unsigned long)((currentBlurCoordinateIndex * 2) + 1), optimizedWeight * 1.2];
        [shaderString appendFormat:@"sum += texture2D(tex0, blurCoordinates[%lu]) * %f;\n", (unsigned long)((currentBlurCoordinateIndex * 2) + 2), optimizedWeight * 1.2];
    }
    
    // If the number of required samples exceeds the amount we can pass in via varyings, we have to do dependent texture reads in the fragment shader
    if (trueNumberOfOptimizedOffsets > numberOfOptimizedOffsets)
    {
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
        [shaderString appendString:@"highp vec2 singleStepOffset = vec2(texelWidthOffset, texelHeightOffset);\n"];
#else
        [shaderString appendString:@"vec2 singleStepOffset = vec2(texelWidthOffset, texelHeightOffset);\n"];
#endif
        
        for (NSUInteger currentOverlowTextureRead = numberOfOptimizedOffsets; currentOverlowTextureRead < trueNumberOfOptimizedOffsets; currentOverlowTextureRead++)
        {
            GLfloat firstWeight = standardGaussianWeights[currentOverlowTextureRead * 2 + 1];
            GLfloat secondWeight = standardGaussianWeights[currentOverlowTextureRead * 2 + 2];
            
            GLfloat optimizedWeight = firstWeight + secondWeight;
            GLfloat optimizedOffset = (firstWeight * (currentOverlowTextureRead * 2 + 1) + secondWeight * (currentOverlowTextureRead * 2 + 2)) / optimizedWeight;
            
            [shaderString appendFormat:@"sum += texture2D(tex0, blurCoordinates[0] + singleStepOffset * %f) * %f * blurAlpha;\n", optimizedOffset, optimizedWeight];
            [shaderString appendFormat:@"sum += texture2D(tex0, blurCoordinates[0] - singleStepOffset * %f) * %f * blurAlpha;\n", optimizedOffset, optimizedWeight];
        }
    }
    
    // Add Main pass
    //[shaderString appendFormat:@"sum = (sum*2. + (1. - blurAlpha) * texture2D(tex0, blurCoordinates[0]));\n"];
    
    // Footer
    [shaderString appendString:@"\
     gl_FragColor = sum;\n\
    // gl_FragColor = texture2D(depthTexture, textureCoordinate);\n\
     }\n"];
    
    free(standardGaussianWeights);
    return shaderString;
}



@end