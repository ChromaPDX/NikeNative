//
//  NKColor.h
//  NKNikeField
//
//  Created by Leif Shackelford on 5/19/14.
//  Copyright (c) 2014 Chroma Developer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NKByteColor : NSObject <NSCopying, NSCoding>

{
    UB4t color;
}

+(instancetype)colorWithRed:(U1t)red green:(U1t)green blue:(U1t)blue alpha:(U1t)alpha;
+(instancetype)colorWithColor:(NKColor*)color;

-(BOOL)isEqual:(id)object;

-(void)setAlpha:(GLubyte)alpha;
-(GLubyte)alpha;

-(UB4t)UB4Color;
-(NKColor*)NKColor;
-(C4t)C4Color;
-(V3t)RGBColor;

-(C4t)colorWithBlendFactor:(F1t)blendFactor;
-(C4t)colorWithBlendFactor:(F1t)blendFactor alpha:(F1t)alpha;

-(void)log;

-(GLubyte*)bytes;

@end
