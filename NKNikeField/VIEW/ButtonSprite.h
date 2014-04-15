//
//  ButtonSprite.h
//  nike3dField
//
//  Created by Chroma Developer on 3/18/14.
//
//

#import "NKSpriteNode.h"

@class NKTexture;
@class NKLabelNode;


typedef NS_ENUM(NSInteger, ButtonType) {
    ButtonTypePush,
    ButtonTypeToggle
} NS_ENUM_AVAILABLE(10_9, 7_0);


typedef NS_ENUM(NSInteger, ButtonState) {
    ButtonStateOff,
    ButtonStateOn,
    ButtonStateRelease
} NS_ENUM_AVAILABLE(10_9, 7_0);

@interface ButtonSprite : NKSpriteNode

@property int tag;
@property (nonatomic) ButtonType type;
@property (nonatomic) ButtonState state;
@property (nonatomic) BOOL border;
@property (nonatomic,strong) NKTexture *onTexture;
@property (nonatomic,strong) NKTexture *offTexture;


@property (nonatomic, strong) NKLabelNode *label;
@property (nonatomic, strong) NSArray *stateLabels;
@property (nonatomic, strong) NSArray *stateColors;
@property (nonatomic) CGFloat fontSize;

@property (nonatomic, weak) id delegate;
@property (nonatomic) SEL method;

+ (instancetype) buttonWithNames:(NSArray*)names color:(NSArray*)colors type:(ButtonType)type size:(CGSize) size;
+ (instancetype) buttonWithTextureOn:(NKTexture*)textureOn TextureOff:(NKTexture*)textureOff type:(ButtonType)type size:(CGSize) size;

@end
