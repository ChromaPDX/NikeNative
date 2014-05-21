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

#import "NKMeshNode.h"

static inline float cblend(F1t col, F1t bl){
    return ((col * bl) + (1. - bl));
}

@class NKTexture;
@class NKVertexBuffer;

@interface NKSpriteNode : NKNode

// INIT

+ (instancetype)spriteNodeWithTexture:(NKTexture*)texture size:(S2t)size;
+ (instancetype)spriteNodeWithTexture:(NKTexture*)texture;
+ (instancetype)spriteNodeWithImageNamed:(NSString *)name;
+ (instancetype)spriteNodeWithColor:(NKByteColor *)color size:(S2t)size;

- (instancetype)initWithTexture:(NKTexture*)texture color:(NKByteColor *)color size:(S2t)size;
- (instancetype)initWithTexture:(NKTexture*)texture;
- (instancetype)initWithImageNamed:(NSString *)name;
- (instancetype)initWithColor:(NKByteColor *)color size:(S2t)size;

@property (nonatomic) R4t centerRect;


@property (nonatomic) float colorBlendFactor;
@property (nonatomic, strong) NKByteColor* color;
@property (nonatomic, strong) NKTexture *texture;
@property (nonatomic, strong) NKVertexBuffer *vert;
@property (nonatomic) GLenum drawMode;

@end
