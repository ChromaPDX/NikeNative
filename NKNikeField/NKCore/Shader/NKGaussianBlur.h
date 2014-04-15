/***********************************************************************
 
 Written by Leif Shackelford
 Copyright (c) 2014 Chroma.io
 All rights reserved. *
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met: *
 * Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 * Neither the name of CHROMA GAMES nor the names of its contributors
 may be used to endorse or promote products derived from this software
 without specific prior written permission. *
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS
 OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 OF THE POSSIBILITY OF SUCH DAMAGE. *
 ***********************************************************************/

#import "NKShaderNode.h"
@class NKNode;

/** A Gaussian blur filter
 Interpolated optimization based on Daniel Rákos' work at http://rastergrid.com/blog/2010/09/efficient-gaussian-blur-with-linear-sampling/
 */

// Obj-C Shader Generators based on code by Brad Larson from https://github.com/BradLarson/GPUImage

@interface NKGaussianBlur : NKShaderNode {
    BOOL shouldResizeBlurRadiusWithImageSize;
    CGFloat _blurRadiusInPixels;
    NKFbo *passBuffer[2];
}

/** A multiplier for the spacing between texels, ranging from 0.0 on up, with a default of 1.0. Adjusting this may slightly increase the blur strength, but will introduce artifacts in the result.
 */
@property (readwrite, nonatomic) CGFloat texelSpacingMultiplier;

/** A radius in pixels to use for the blur, with a default of 2.0. This adjusts the sigma variable in the Gaussian distribution function.
 */
@property (readwrite, nonatomic) CGFloat blurRadiusInPixels;

/** Setting these properties will allow the blur radius to scale with the size of the image
 */
@property (readwrite, nonatomic) CGFloat blurRadiusAsFractionOfImageWidth;
@property (readwrite, nonatomic) CGFloat blurRadiusAsFractionOfImageHeight;

/// The number of times to sequentially blur the incoming image. The more passes, the slower the filter.
@property(readwrite, nonatomic) NSUInteger blurPasses;

- (instancetype)initWithNode:(NKNode *)node blurSize:(float)blurRadiusInPixels numPasses:(NSUInteger)blurPasses;
    
+ (NSString *)vertexShaderForStandardBlurOfRadius:(NSUInteger)blurRadius sigma:(CGFloat)sigma;
+ (NSString *)fragmentShaderForStandardBlurOfRadius:(NSUInteger)blurRadius sigma:(CGFloat)sigma;
+ (NSString *)vertexShaderForOptimizedBlurOfRadius:(NSUInteger)blurRadius sigma:(CGFloat)sigma;
+ (NSString *)fragmentShaderForOptimizedBlurOfRadius:(NSUInteger)blurRadius sigma:(CGFloat)sigma;

@end
