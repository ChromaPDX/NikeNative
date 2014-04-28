//
//  NKZBlur.m
//  NodeKittenExample
//
//  Created by Chroma Developer on 2/26/14.
//  Copyright (c) 2014 Chroma. All rights reserved.
//

#import "NodeKitten.h"

@implementation NKZBlur

@synthesize texelSpacingMultiplier = _texelSpacingMultiplier;
@synthesize blurRadiusInPixels = _blurRadiusInPixels;
@synthesize blurRadiusAsFractionOfImageWidth  = _blurRadiusAsFractionOfImageWidth;
@synthesize blurRadiusAsFractionOfImageHeight = _blurRadiusAsFractionOfImageHeight;
@synthesize blurPasses = _blurPasses;

#pragma mark -
#pragma mark Initialization and teardown

- (instancetype)initWithNode:(NKNode *)node paramBlock:(ShaderParamBlock)block {
    {
        float blurRadiusInPixels = 2.; // For now, only do integral sigmas
        
        // Calculate the number of pixels to sample from by setting a bottom limit for the contribution of the outermost pixel
        CGFloat minimumWeightToFindEdgeOfSamplingArea = 1.0/256.0;
        NSUInteger calculatedSampleRadius = floor(sqrt(-2.0 * pow(blurRadiusInPixels, 2.0f) * log(minimumWeightToFindEdgeOfSamplingArea * sqrt(2.0 * M_PI * pow(blurRadiusInPixels, 2.0f))) ));
        calculatedSampleRadius += calculatedSampleRadius % 2; // There's nothing to gain from handling odd radius sizes, due to the optimizations I use
        
                NSLog(@"Blur radius: %f, calculated sample radius: %d", _blurRadiusInPixels, calculatedSampleRadius);
        //

        NSString *newGaussianBlurVertexShader = [[self class] vertexShaderForOptimizedBlurOfRadius:calculatedSampleRadius sigma:blurRadiusInPixels];
        NSString *newGaussianBlurFragmentShader = [[self class] fragmentShaderForOptimizedBlurOfRadius:calculatedSampleRadius sigma:blurRadiusInPixels];
        
        
        self = [super initWithShaderStringArray:@[newGaussianBlurVertexShader, newGaussianBlurFragmentShader] node:node paramBlock:block];
        
        if (self) {
            
            self.texelSpacingMultiplier = 1.0;
            _blurRadiusInPixels = blurRadiusInPixels;
            shouldResizeBlurRadiusWithImageSize = NO;
            
            self.usesFbo = true;
            self.needsDepthBuffer = true;
            
        }
        
        return self;
        
    }
}

// DRAW CYCLE

#pragma mark -
#pragma mark Auto-generation of optimized Gaussian shaders

// "Implementation limit of 32 varying components exceeded" - Max number of varyings for these GPUs

//+ (NSString *)vertexShaderForStandardBlurOfRadius:(NSUInteger)blurRadius sigma:(CGFloat)sigma
//{
//    if (blurRadius < 1)
//    {
//        return nkImageVertexShaderString;
//    }
//    
//    //    NSLog(@"Max varyings: %d", [GPUImageContext maximumVaryingVectorsForThisDevice]);
//    NSMutableString *shaderString = [[NSMutableString alloc] init];
//    
//    // Header
//    [shaderString appendFormat:@"\
//     attribute vec4 position;\n\
//     attribute vec2 texcoord;\n\
//     \n\
//     uniform float step;\n\
//     \n\
//     varying vec2 blurCoordinates[%lu];\n\
//     \n\
//     void main()\n\
//     {\n\
//     gl_Position = position;\n\
//     \n\
//     //vec2 singleStepOffset = vec2(texelWidthOffset, texelHeightOffset);\n", (unsigned long)(blurRadius * 2 + 1) ];
//    
//    // Inner offset loop
//    for (NSUInteger currentBlurCoordinateIndex = 0; currentBlurCoordinateIndex < (blurRadius * 2 + 1); currentBlurCoordinateIndex++)
//    {
//        NSInteger offsetFromCenter = currentBlurCoordinateIndex - blurRadius;
//        if (offsetFromCenter < 0)
//        {
//            [shaderString appendFormat:@"blurCoordinates[%ld] = texcoord - vec2(step,0) * %f;\n", (unsigned long)currentBlurCoordinateIndex, (GLfloat)(-offsetFromCenter)];
//            [shaderString appendFormat:@"blurCoordinates[%ld] = texcoord - vec2(0,step)  * %f;\n", (unsigned long)currentBlurCoordinateIndex, (GLfloat)(-offsetFromCenter)];
//        }
//        else if (offsetFromCenter > 0)
//        {
//            [shaderString appendFormat:@"blurCoordinates[%ld] = texcoord + vec2(step,0) * %f;\n", (unsigned long)currentBlurCoordinateIndex, (GLfloat)(offsetFromCenter)];
//            [shaderString appendFormat:@"blurCoordinates[%ld] = texcoord + vec2(0,step) * %f;\n", (unsigned long)currentBlurCoordinateIndex, (GLfloat)(offsetFromCenter)];
//        }
//        else
//        {
//            [shaderString appendFormat:@"blurCoordinates[%ld] = texcoord;\n", (unsigned long)currentBlurCoordinateIndex];
//        }
//    }
//    
//    // Footer
//    [shaderString appendString:@"}\n"];
//    
//    return shaderString;
//}

//+ (NSString *)fragmentShaderForStandardBlurOfRadius:(NSUInteger)blurRadius sigma:(CGFloat)sigma;
//{
//    if (blurRadius < 1)
//    {
//        return nkImagePassthroughFragmentShaderString;
//    }
//    
//    // First, generate the normal Gaussian weights for a given sigma
//    GLfloat *standardGaussianWeights = (GLfloat *) calloc(blurRadius + 1, sizeof(GLfloat));
//    GLfloat sumOfWeights = 0.0;
//    for (NSUInteger currentGaussianWeightIndex = 0; currentGaussianWeightIndex < blurRadius + 1; currentGaussianWeightIndex++)
//    {
//        standardGaussianWeights[currentGaussianWeightIndex] = (1.0 / sqrt(2.0 * M_PI * pow(sigma, 2.0f))) * exp(-pow(currentGaussianWeightIndex, 2.0) / (2.0 * pow(sigma, 2.0f)));
//        
//        if (currentGaussianWeightIndex == 0)
//        {
//            sumOfWeights += standardGaussianWeights[currentGaussianWeightIndex];
//        }
//        else
//        {
//            sumOfWeights += 2.0 * standardGaussianWeights[currentGaussianWeightIndex];
//        }
//    }
//    
//    // Next, normalize these weights to prevent the clipping of the Gaussian curve at the end of the discrete samples from reducing luminance
//    for (NSUInteger currentGaussianWeightIndex = 0; currentGaussianWeightIndex < blurRadius + 1; currentGaussianWeightIndex++)
//    {
//        standardGaussianWeights[currentGaussianWeightIndex] = standardGaussianWeights[currentGaussianWeightIndex] / sumOfWeights;
//    }
//    
//    // Finally, generate the shader from these weights
//    NSMutableString *shaderString = [[NSMutableString alloc] init];
//    
//    // Header
//#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
//    [shaderString appendFormat:@"\
//     uniform sampler2D tex0;\n\
//     uniform sampler2D depthTexture;\n\
//     \n\
//     varying highp vec2 blurCoordinates[%lu];\n\
//     \n\
//     void main()\n\
//     {\n\
//     lowp vec4 sum = vec4(0.0);\n", (unsigned long)(blurRadius * 2 + 1) ];
//#else
//    [shaderString appendFormat:@"\
//     uniform sampler2D tex0;\n\
//     uniform sampler2D depthTexture;\n\
//     \n\
//     varying vec2 blurCoordinates[%lu];\n\
//     \n\
//     void main()\n\
//     {\n\
//     vec4 sum = vec4(0.0);\n", (blurRadius * 2 + 1) ];
//#endif
//    
//    // Inner texture loop
//    for (NSUInteger currentBlurCoordinateIndex = 0; currentBlurCoordinateIndex < (blurRadius * 2 + 1); currentBlurCoordinateIndex++)
//    {
//        NSInteger offsetFromCenter = currentBlurCoordinateIndex - blurRadius;
//        if (offsetFromCenter < 0)
//        {
//            [shaderString appendFormat:@"sum += texture2D(tex0, blurCoordinates[%lu]) * %f;\n", (unsigned long)currentBlurCoordinateIndex, standardGaussianWeights[-offsetFromCenter]];
//        }
//        else
//        {
//            [shaderString appendFormat:@"sum += texture2D(tex0, blurCoordinates[%lu]) * %f;\n", (unsigned long)currentBlurCoordinateIndex, standardGaussianWeights[offsetFromCenter]];
//        }
//    }
//    
//    // Footer
//    [shaderString appendString:@"\
//     gl_FragColor = sum;\n\
//     }\n"];
//    
//    free(standardGaussianWeights);
//    return shaderString;
//}

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
     uniform mat4 modelViewMatrix;\n\
     uniform mat4 projectionMatrix;\n\
     \n\
     uniform highp float pstep;\n\
     uniform sampler2D depthTexture;\n\
     \n\
     varying highp vec2 textureCoordinate;\n\
     varying vec2 blurCoordinates[%lu];\n\
     varying float numPos;\n\
     \n\
     void main()\n\
     {\n\
     gl_Position = projectionMatrix * modelViewMatrix * position;\n\
     textureCoordinate = texcoord;\n\
     float blurAlpha = texture2D(depthTexture, textureCoordinate).r;\n\
     vec2 singleStepOffset = vec2(pstep, pstep);\n", (unsigned long)(1 + (numberOfOptimizedOffsets * 4))];
    
    // Inner offset loop
    [shaderString appendString:@"blurCoordinates[0] = texcoord;\n"];

    
    for (NSUInteger currentOptimizedOffset = 0; currentOptimizedOffset < numberOfOptimizedOffsets; currentOptimizedOffset++)
    {
        [shaderString appendFormat:@"\
         blurCoordinates[%lu] = texcoord + (vec2(pstep,0) * %f);\n\
         blurCoordinates[%lu] = texcoord - (vec2(pstep,0) * %f);\n", (unsigned long)((currentOptimizedOffset * 4) + 1), optimizedGaussianOffsets[currentOptimizedOffset], (unsigned long)((currentOptimizedOffset * 4) + 2), optimizedGaussianOffsets[currentOptimizedOffset]];
        [shaderString appendFormat:@"\
         blurCoordinates[%lu] = texcoord + (vec2(0,pstep) * %f);\n\
         blurCoordinates[%lu] = texcoord - (vec2(0,pstep) * %f);\n", (unsigned long)((currentOptimizedOffset * 4) + 3), optimizedGaussianOffsets[currentOptimizedOffset], (unsigned long)((currentOptimizedOffset * 4) + 4), optimizedGaussianOffsets[currentOptimizedOffset]];
    }

    
    // Footer
    [shaderString appendString:@"}\n"];
    
    free(optimizedGaussianOffsets);
    free(standardGaussianWeights);
    return shaderString;
}

+ (NSString *)fragmentShaderForOptimizedBlurOfRadius:(NSUInteger)blurRadius sigma:(CGFloat)sigma;
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
     uniform sampler2D depthTexture;\n\
     uniform highp float pstep;\n\
     varying highp vec2 textureCoordinate;\n\
     varying highp vec2 blurCoordinates[%lu];\n\
     \n\
     void main()\n\
     {\n\
     highp float blurAlpha = texture2D(depthTexture, textureCoordinate).r;\n\
     highp vec4 sum = vec4(0.0);\n", (unsigned long)(1 + (numberOfOptimizedOffsets * 4)) ];
#else
    [shaderString appendFormat:@"\
     uniform sampler2D tex0;\n\
     uniform float texelWidthOffset;\n\
     uniform float texelHeightOffset;\n\
     uniform sampler2D depthTexture;\n\
     varying highp vec2 textureCoordinate;\n\
     varying vec2 blurCoordinates[%lu];\n\
     \n\
     void main()\n\
     {\n\
     float blurAlpha = texture2D(depthTexture, textureCoordinate).r;\n\
     vec4 sum = vec4(0.0);\n", 1 + (numberOfOptimizedOffsets * 4) ];
#endif
    
    // Inner texture loop
    //[shaderString appendString:@"\n float blurAlpha = texture2D(depthTexture, texcoord).a;"];
    //[shaderString appendString:@"\n if (blurAlpha > .01){ \n"];
    
    //[shaderString appendFormat:@"sum += (texture2D(tex0, blurCoordinates[0])); \n"];
     
    //[shaderString appendFormat:@"sum += (texture2D(tex0, blurCoordinates[0]) * (.75 - (blurAlpha*.25)));\n"]; //, standardGaussianWeights[0]];
    
    for (NSUInteger currentBlurCoordinateIndex = 0; currentBlurCoordinateIndex < numberOfOptimizedOffsets; currentBlurCoordinateIndex++)
    {
        GLfloat firstWeight = standardGaussianWeights[currentBlurCoordinateIndex * 2 + 1];
        GLfloat secondWeight = standardGaussianWeights[currentBlurCoordinateIndex * 2 + 2];
        GLfloat optimizedWeight = firstWeight + secondWeight;
        
        
        [shaderString appendFormat:@"sum += texture2D(tex0, blurCoordinates[%lu]) * %f * blurAlpha *2. ;\n", (unsigned long)((currentBlurCoordinateIndex * 4) + 1), optimizedWeight];
        [shaderString appendFormat:@"sum += texture2D(tex0, blurCoordinates[%lu]) * %f * blurAlpha *2.;\n", (unsigned long)((currentBlurCoordinateIndex * 4) + 1), optimizedWeight];
        [shaderString appendFormat:@"sum += texture2D(tex0, blurCoordinates[%lu]) * %f * blurAlpha *2. ;\n", (unsigned long)((currentBlurCoordinateIndex * 4) + 2), optimizedWeight];
        [shaderString appendFormat:@"sum += texture2D(tex0, blurCoordinates[%lu]) * %f * blurAlpha *2.;\n", (unsigned long)((currentBlurCoordinateIndex * 4) + 3), optimizedWeight];
    }
    
    // If the number of required samples exceeds the amount we can pass in via varyings, we have to do dependent texture reads in the fragment shader
    
    if (trueNumberOfOptimizedOffsets > numberOfOptimizedOffsets)
    {
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
        
        [shaderString appendString:@"vec2 singleStepOffset = vec2(texelWidthOffset, texelHeightOffset));\n"];
#else
         [shaderString appendString:@"vec2 singleStepOffset = vec2(texelWidthOffset, texelHeightOffset));\n"];
#endif
        
        for (NSUInteger currentOverlowTextureRead = numberOfOptimizedOffsets; currentOverlowTextureRead < trueNumberOfOptimizedOffsets; currentOverlowTextureRead++)
        {
            GLfloat firstWeight = standardGaussianWeights[currentOverlowTextureRead * 2 + 1];
            GLfloat secondWeight = standardGaussianWeights[currentOverlowTextureRead * 2 + 2];
            
            GLfloat optimizedWeight = firstWeight + secondWeight;
            GLfloat optimizedOffset = (firstWeight * (currentOverlowTextureRead * 2 + 1) + secondWeight * (currentOverlowTextureRead * 2 + 2)) / optimizedWeight;
            
            [shaderString appendFormat:@"sum += texture2D(tex0, blurCoordinates[0] + singleStepOffset * %f) * %f;\n", optimizedOffset, optimizedWeight];
            [shaderString appendFormat:@"sum += texture2D(tex0, blurCoordinates[0] - singleStepOffset * %f) * %f;\n", optimizedOffset, optimizedWeight];
            
        }
        //[shaderString appendString:@"}\n"]; // end of if blur
        
    }
    else {
       // [shaderString appendString:@"}\n"]; // non-ext end of if blur
    }
    
    //[shaderString appendFormat:@"else sum = texture2D(tex0, blurCoordinates[0]);\n"];
    
    // Footer
    [shaderString appendString:@"\
     //gl_FragColor = texture2D(depthTexture, textureCoordinate);\n\
     //sum.r += texture2D(depthTexture, textureCoordinate).r;\n\
     //gl_FragColor =  sum - texture2D(depthTexture, textureCoordinate);\n\
     gl_FragColor = sum;\n\
     }\n"];
    
    free(standardGaussianWeights);
    return shaderString;
}


// inputRadius for Core Image's CIGaussianBlur is really sigma in the Gaussian equation, so I'm using that for my blur radius, to be consistent
- (void)setBlurRadiusInPixels:(CGFloat)newValue;
{
    // 7.0 is the limit for blur size for hardcoded varying offsets
    
    if (round(newValue) != _blurRadiusInPixels)
    {
        _blurRadiusInPixels = round(newValue); // For now, only do integral sigmas
        
        // Calculate the number of pixels to sample from by setting a bottom limit for the contribution of the outermost pixel
        CGFloat minimumWeightToFindEdgeOfSamplingArea = 1.0/256.0;
        NSUInteger calculatedSampleRadius = floor(sqrt(-2.0 * pow(_blurRadiusInPixels, 2.0f) * log(minimumWeightToFindEdgeOfSamplingArea * sqrt(2.0 * M_PI * pow(_blurRadiusInPixels, 2.0f))) ));
        calculatedSampleRadius += calculatedSampleRadius % 2; // There's nothing to gain from handling odd radius sizes, due to the optimizations I use
        
        //        NSLog(@"Blur radius: %f, calculated sample radius: %d", _blurRadiusInPixels, calculatedSampleRadius);
        //
        NSString *newGaussianBlurVertexShader = [[self class] vertexShaderForOptimizedBlurOfRadius:calculatedSampleRadius sigma:_blurRadiusInPixels];
        NSString *newGaussianBlurFragmentShader = [[self class] fragmentShaderForOptimizedBlurOfRadius:calculatedSampleRadius sigma:_blurRadiusInPixels];
        
        //        NSLog(@"Optimized vertex shader: \n%@", newGaussianBlurVertexShader);
        //        NSLog(@"Optimized fragment shader: \n%@", newGaussianBlurFragmentShader);
        //
        //[self switchToVertexShader:newGaussianBlurVertexShader fragmentShader:newGaussianBlurFragmentShader];
        [self loadShaderFromStringArray:@[newGaussianBlurVertexShader,newGaussianBlurFragmentShader] paramBlock:nil];
        
    }
    shouldResizeBlurRadiusWithImageSize = NO;
}


@end

// NOTES:

// http://www.gamedev.net/topic/507009-fbo-with-color-and-depth-texture/
// http://stackoverflow.com/questions/2621013/how-to-create-a-fbo-with-stencil-buffer-in-opengl-es-2-0
// http://www.raspberrypi.org/forum/viewtopic.php?f=67&t=66247

//
// glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT0_EXT, GL_TEXTURE_2D, img, 0);
//

// MAKE FBO

//glGenFramebuffersEXT(1, &m_fbo);
//
//glGenTextures (1, &m_texID);
//glBindTexture (GL_TEXTURE_2D, m_texID);
//glTexImage2D (GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
//
//glGenTextures(1, &m_depthID);
//glBindTexture(GL_TEXTURE_2D, m_depthID);
//glTexImage2D (GL_TEXTURE_2D, 0, GL_DEPTH_COMPONENT, width, height, 0, GL_DEPTH_COMPONENT, GL_UNSIGNED_BYTE, NULL);
//
//glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, m_fbo);
//glBindTexture(GL_TEXTURE_2D, m_depthID);
//glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT, GL_DEPTH_ATTACHMENT_EXT, GL_TEXTURE_2D, m_depthID, 0);
//
//glBindTexture (GL_TEXTURE_2D, m_texID);
//glFramebufferTexture2DEXT( GL_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT0_EXT, GL_TEXTURE_2D, m_texID, 0 );
//
//use my depth textures as
//
//
//glBindTexture(GL_TEXTURE_2D, txDepth1);
//==>	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
//==>	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
//glTexImage2D(GL_TEXTURE_2D, 0, GL_DEPTH_COMPONENT32,
//             fbWidth, fbHeight, 0, GL_DEPTH_COMPONENT, GL_FLOAT, 0);
//
//
//glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, framebuffer1);
//glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT0_EXT,
//                          GL_TEXTURE_2D, txColor1, 0);
//glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT, GL_DEPTH_ATTACHMENT_EXT,
//                          GL_TEXTURE_2D, txDepth1, 0);
//
//Hmm okay I should have tried that before, switching the internal format to DEPTH_COMPONENT32 and type to GL_FLOAT did the trick. Thx for sharing your code!

