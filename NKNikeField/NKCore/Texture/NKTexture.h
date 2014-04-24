//
//  NKTexture.h
//  NodeKittenExample
//
//  Created by Chroma Developer on 3/5/14.
//  Copyright (c) 2014 Chroma. All rights reserved.
//

#import "NKpch.h"

#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

@class NKLabelNode;

typedef NS_OPTIONS(UInt8, NKTextureMapStyle) {
    NKTextureMapStyleNone = 0,
    NKTextureMapStyleRepeatX = 1 << 0,
    NKTextureMapStyleRepeatY = 1 << 1,
    NKTextureMapStyleClampX = 1 << 2,
    NKTextureMapStyleClampY = 1 << 3,
    NKTextureMapStyleRepeat = NKTextureMapStyleRepeatX | NKTextureMapStyleRepeatY,
    NKTextureMapStyleClamp = NKTextureMapStyleClampX | NKTextureMapStyleClampY,
    NKTextureMapStyleUV = 1 << 7
};

@interface NKTexture : NSObject
{
    GLuint		texture[1];
}

@property (nonatomic) CGSize size;
@property (nonatomic) bool shouldResizeToTexture;
@property (nonatomic) NKTextureMapStyle textureMapStyle;

+(instancetype) textureWithImageNamed:(NSString*)name;
+(instancetype) textureWithImage:(NKImage*)image;

+(instancetype) textureWithString:(NSString *)string ForLabelNode:(NKLabelNode*)node;
+(instancetype) textureWithString:(NSString *)string ForLabelNode:(NKLabelNode *)node inBackGroundWithCompletionBlock:(void (^)())block;

//+(instancetype) textureWithString:(NSString *)text fontNamed:(NSString*)name color:(NKColor*)textColor Size:(CGSize)size fontSize:(CGFloat)fontSize completion:(void (^)())block;


+(instancetype) textureWithPVRNamed:(NSString*)name size:(CGSize)size;

-(void)updateWithTimeSinceLast:(F1t) dt;
-(void)bind;
-(void)unbind;

+(NKTexture*)blankTexture;

-(GLuint)glTexLocation;
-(void)setGlTexLocation:(GLuint)loc;

@end
