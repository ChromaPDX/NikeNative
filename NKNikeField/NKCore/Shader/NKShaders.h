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

// *****
// ofShader uses these default attributes
//COLOR_ATTRIBUTE="color";
//POSITION_ATTRIBUTE="position";
//NORMAL_ATTRIBUTE="normal";
//TEXCOORD_ATTRIBUTE="texcoord";
// *****

// BASE CLASS
#import "NKShaderNode.h"

// SUB CLASSES
#import "NKGaussianBlur.h"
#import "NKDrawDepthShader.h"
#import "NKZBlur.h"
#import "NKGaussianZ.h"
#import "NKBlendShader.h"

// TO DO

// GIVE NKShaderProperties to objects
// Allow Nodes to share shaders with children either same pass or separate pass
// Eventually figure out how to give ofNode's a proper depthStencilAsTexture

// ************* //
//   CONSTANTS   //
// ************* //

#pragma mark - SHADER CONST

#define STRINGIZE(x) #x
#define STRINGIZE2(x) STRINGIZE(x)
#define SHADER_STRING(text) @ STRINGIZE2(text)

//NSString *const nkImageVertexShaderString;
//NSString *const nkVertexHeader;
//NSString *const nkFragmentColorHeader;
//NSString *const nkFragmentTextureHeader;
//NSString *const nkImagePassthroughFragmentShaderString;

// ************* //
//   CONSTANTS   //
// ************* //

// Hardcode the vertex shader for standard filters, but this can be overridden
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

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE

static NSString *const nkVertexHeader = SHADER_STRING
(
 attribute vec4 position; \n
 attribute vec2 texcoord; \n
 attribute vec4 color; \n
 );

static NSString *const nkFragmentColorHeader = SHADER_STRING
(
 precision highp float;\n
 varying vec4 color_varying; \n
 );

static NSString *const nkFragmentTextureHeader = SHADER_STRING
(
 \n
 precision highp float;\n
 uniform sampler2D tex0;\n
 varying highp vec2 texCoord_varying;\n
 );

static NSString *const nkImagePassthroughFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 uniform sampler2D inputImageTexture;
 
 void main()
 {
     gl_FragColor = texture2D(inputImageTexture, textureCoordinate);
 }
 );

#else

static NSString *const nkVertexHeader = SHADER_STRING
(
 varying vec2 textureCoordinate; \n
 uniform sampler2D inputImageTexture; \n
 );

static NSString *const nkImagePassthroughFragmentShaderString = SHADER_STRING
(
 varying vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 
 void main()
 {
     gl_FragColor = texture2D(inputImageTexture, textureCoordinate);
 }
 );

#endif