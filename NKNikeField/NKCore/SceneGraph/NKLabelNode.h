//
//  NKLabelNode.h
//  NodeKittenExample
//
//  Created by Chroma Developer on 2/28/14.
//  Copyright (c) 2014 Chroma. All rights reserved.
//

#import "NKSpriteNode.h"
#import <CoreText/CoreText.h>

@class MarkupParser;

typedef NS_ENUM(NSInteger, NKLabelVerticalAlignmentMode) {
    NKLabelVerticalAlignmentModeBaseline    = 0,
    NKLabelVerticalAlignmentModeCenter      = 1,
    NKLabelVerticalAlignmentModeTop         = 2,
    NKLabelVerticalAlignmentModeBottom      = 3,
} NS_ENUM_AVAILABLE(10_9, 7_0);

typedef NS_ENUM(NSInteger, NKLabelHorizontalAlignmentMode) {
    NKLabelHorizontalAlignmentModeCenter    = 0,
    NKLabelHorizontalAlignmentModeLeft      = 1,
    NKLabelHorizontalAlignmentModeRight     = 2,
} NS_ENUM_AVAILABLE(10_9, 7_0);

@interface NKLabelNode : NKSpriteNode

//+ (instancetype)labelNodeWithFontNamed:(NSString *)fontName;

+ (instancetype)labelNodeWithFontNamed:(NSString *)fontName;

- (instancetype)initWithFontNamed:(NSString *)fontName;

- (instancetype)initWithSize:(S2t)size FontNamed:(NSString *)fontName;

- (void)loadAsyncText:(NSString*)text completion:(void (^)())block;

@property (nonatomic) NKLabelHorizontalAlignmentMode horizontalAlignmentMode;
@property (nonatomic) NKLabelVerticalAlignmentMode verticalAlignmentMode;

@property (nonatomic, strong) MarkupParser *markupParser;

@property (NK_NONATOMIC_IOSONLY, copy) NSString *fontName;
@property (NK_NONATOMIC_IOSONLY, copy) NSString *text;
@property (NK_NONATOMIC_IOSONLY) CGFloat fontSize;
@property (NK_NONATOMIC_IOSONLY, strong) NKByteColor *fontColor;

@end

