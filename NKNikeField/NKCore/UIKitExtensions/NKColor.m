//
//  NKColor.m
//  NKNikeField
//
//  Created by Leif Shackelford on 5/19/14.
//  Copyright (c) 2014 Chroma Developer. All rights reserved.
//

#import "NodeKitten.h"

#define div255 *.003921568

@implementation NKByteColor

+(instancetype)colorWithRed:(U1t)red green:(U1t)green blue:(U1t)blue alpha:(U1t)alpha {
    NKByteColor *color = [[NKByteColor alloc]initWithRed:red green:green blue:blue alpha:alpha];
    return color;
}

+(instancetype)colorWithColor:(NKColor*)color {
    CGFloat c[4];
    [color getRed:&c[0] green:&c[1] blue:&c[2] alpha:&c[3]];
    C4t col;
    col.r = c[0];
    col.g = c[1];
    col.b = c[2];
    col.a = c[3];
    
    return [NKByteColor colorWithC4Color:col];
}

+(instancetype)colorWithC4Color:(C4t)color {
    return [NKByteColor colorWithRed:color.r*255 green:color.g*255 blue:color.b*255 alpha:color.a*255];
}

-(instancetype)initWithRed:(U1t)red green:(U1t)green blue:(U1t)blue alpha:(U1t)alpha {
    
    self = [super init];
    if (self) {
        color.r = red;
        color.g = green;
        color.b = blue;
        color.a = alpha;
    }
    return self;
}

-(BOOL)isEqual:(id)object {
    return UB4Equal(color, ((NKByteColor*)object).UB4Color);
}

-(NSUInteger) hash;{
    return 1;
}

-(instancetype)copyWithZone:(NSZone *)zone {
    return [NKByteColor colorWithRed:color.r green:color.g blue:color.b alpha:color.a];
}

-(void)setAlpha:(GLubyte)alpha {
    color.a = alpha;
}

-(GLubyte)alpha {
    return color.a;
}

-(UB4t)UB4Color{
    return color;
}

-(GLubyte*)bytes{
    return &color.r;
}

-(C4t)colorWithBlendFactor:(F1t)blendFactor alpha:(F1t)alpha {
    C4t col = [self colorWithBlendFactor:blendFactor];
    col.a *= alpha;
    return col;
}

-(C4t)C4Color {
    C4t col;
    
    col.r = color.r div255;
    col.g = color.g div255;
    col.b = color.b div255;
    col.a = color.a div255;
    
    return col;
}

-(V3t)RGBColor {
    V3t col;
    col.r = color.r div255;
    col.g = color.g div255;
    col.b = color.b div255;
    return col;
}

-(NKColor*)NKColor {
    return [NKColor colorWithRed:color.r div255 green:color.g div255 blue:color.b div255 alpha:color.a div255];
}

-(C4t)colorWithBlendFactor:(F1t)blendFactor {

    if (blendFactor > 0.) {
        C4t col;
        
        col.r = cblend(color.r div255, blendFactor);
        col.g = cblend(color.g div255, blendFactor);
        col.b = cblend(color.b div255, blendFactor);
        col.a = color.a div255;
        
        return col;
    }
    else {
        return [self C4Color];
    }

}

-(void)log {
    NSLog(@"%@ : R:%d, G:%d, B:%d, A:%d", self, color.r, color.g, color.b, color.a);
}

- (id)initWithCoder:(NSCoder *)decoder {
    
    self = [super init];
    
    if (self) {
        
        memcpy(&color, [decoder decodeBytesForKey:@"color" returnedLength:(void*)sizeof(UB4t)], sizeof(UB4t));
        
        
    }
    
    return self;
    
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    
    [encoder encodeBytes:&color.r length:sizeof(UB4t) forKey:@"color"];

}

@end
