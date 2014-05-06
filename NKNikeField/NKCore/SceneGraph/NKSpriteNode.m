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

+ (instancetype)spriteNodeWithTexture:(NKTexture*)texture size:(S2t)size {
    NKSpriteNode *node = [[NKSpriteNode alloc] initWithTexture:texture color:[UIColor colorWithWhite:1. alpha:1.] size:size];
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

+ (instancetype)spriteNodeWithColor:(UIColor*)color size:(S2t)size {
    NKSpriteNode *node = [[NKSpriteNode alloc] initWithColor:color size:size];
    return node;
}

- (instancetype)initWithTexture:(NKTexture*)texture color:(UIColor*)color size:(S2t)size {
    
    self = [super initWithPrimitive:NKPrimitiveRect texture:texture color:color size:V3Make(size.width, size.height, 1)];
    
    if (self) {
    }
    
    return self;
}

- (instancetype)initWithTexture:(NKTexture*)texture {
    return [self initWithTexture:texture color:NKWHITE size:texture.size];
}

- (instancetype)initWithImageNamed:(NSString *)name {
    NKTexture *newTex = [NKTexture textureWithImageNamed:name];
    return [self initWithTexture:newTex color:NKWHITE size:self.texture.size];
}

- (instancetype)initWithColor:(UIColor*)color size:(S2t)size {
    self = [super initWithPrimitive:NKPrimitiveRect texture:nil color:color size:V3Make(size.width, size.height, 1)];
    
    if (self) {
    }
    
    return self;

}



// DRAW


- (void)updateWithTimeSinceLast:(F1t) dt {
    [super updateWithTimeSinceLast:dt];
}


@end
