//
//  ofxGameNode.m
//  example-ofxTableView
//
//  Created by Chroma Developer on 2/13/14.
//
//

#import "NodeKitten.h"
#import <CoreText/CoreText.h>

@implementation NKSpriteNode

-(instancetype)initWithTexture:(NKTexture *)texture color:(NKByteColor *)color size:(S2t)size {
    
    self = [super initWithPrimitive:NKPrimitiveRect texture:texture color:color size:V3Make(size.x,size.y,1)];
    
    if (self) {
        
    }
    
    return self;

}

+ (instancetype)spriteNodeWithTexture:(NKTexture*)texture size:(S2t)size {
    NKSpriteNode *node = [[NKSpriteNode alloc] initWithTexture:texture color:NKWHITE size:size];
    return node;
}

+ (instancetype)spriteNodeWithTexture:(NKTexture*)texture {
    NKSpriteNode *node = [[NKSpriteNode alloc] initWithTexture:texture];
    return node;
}

+ (instancetype)spriteNodeWithImageNamed:(NSString *)name {
    NKSpriteNode *node = [[NKSpriteNode alloc] initWithImageNamed:name];
    return node;
}

+ (instancetype)spriteNodeWithColor:(NKByteColor*)color size:(S2t)size {
    NKSpriteNode *node = [[NKSpriteNode alloc] initWithColor:color size:size];
    return node;
}


- (instancetype)initWithTexture:(NKTexture*)texture {
    return [self initWithTexture:texture color:NKWHITE size:texture.size];
}

- (instancetype)initWithImageNamed:(NSString *)name {
    NKTexture *newTex = [NKTexture textureWithImageNamed:name];
    return [self initWithTexture:newTex color:NKWHITE size:self.texture.size];
}

- (instancetype)initWithColor:(NKByteColor*)color size:(S2t)size {
    self = [self initWithTexture:nil color:color size:S2Make(size.width, size.height)];
    
    if (self) {
    }
    
    return self;

}

@end
