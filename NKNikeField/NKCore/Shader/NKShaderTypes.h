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



//// BASE CLASS
#import "NKShaderNode.h"
//
//// SUB CLASSES
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
 attribute vec4 position;
 attribute vec4 inputTextureCoordinate;
 attribute vec4 color;
 
 varying vec2 textureCoordinate;
 
 uniform mat4 modelViewProjMatrix;
 );

static NSString *const nkFragmentColorHeader = SHADER_STRING
(
 precision highp float;
 varying vec4 color_varying;
 );

static NSString *const nkFragmentTextureHeader = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 uniform sampler2D texture;
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
    vec3 lightPosition = vec3(0.5, 1.5, -1.0);
    vec4 diffuseColor;
    
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

#endif