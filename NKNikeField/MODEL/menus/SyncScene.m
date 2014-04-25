//
//  SyncScene.m
//  NKNikeField
//
//  Created by Leif Shackelford on 4/25/14.
//  Copyright (c) 2014 Chroma Developer. All rights reserved.
//

#import "SyncScene.h"
#import "NodeKitten.h"

@implementation SyncScene

-(instancetype)initWithSize:(CGSize)size {
    self = [super initWithSize:size];
    
    if (self) {
        
         NKMeshNode *ballSprite = [[NKMeshNode alloc]initWithPrimitive:NKPrimitiveSphere texture:[NKTexture textureWithImageNamed:@"ball_Texture.png"] color:nil size:V3Make(250,250,250)];
        
        [self addChild:ballSprite];
        
        [ballSprite repeatAction:[NKAction rotateYByAngle:180 duration:1.]];
        
    }
    
    return self;
}
@end
