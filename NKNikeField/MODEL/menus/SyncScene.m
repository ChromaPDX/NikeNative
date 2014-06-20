//
//  SyncScene.m
//  NKNikeField
//
//  Created by Leif Shackelford on 4/25/14.
//  Copyright (c) 2014 Chroma Developer. All rights reserved.
//

#import "SyncScene.h"
#import "NodeKitten.h"
#import "NikeNodeHeaders.h"

@implementation SyncScene

-(instancetype)initWithSize:(S2t)size {
    self = [super initWithSize:size];
    
    if (self) {
        
         NKMeshNode *ballSprite = [[NKMeshNode alloc]initWithPrimitive:NKPrimitiveSphere texture: [NKTexture textureWithImageNamed:@"ball_Texture.png"] color:V2BLUE size:V3MakeF(200)];
        
        [self addChild:ballSprite];
        
        [ballSprite setPosition2d:P2Make(0, 400)];
        
        [ballSprite repeatAction:[NKAction rotateYByAngle:180 duration:10.]];
        
        NKMeshNode *cubeSprite = [[NKMeshNode alloc]initWithPrimitive:NKPrimitiveCube texture:[NKTexture textureWithImageNamed:@"ball_Texture.png"] color:NKWHITE size:V3Make(250,250,250)];
        
        [cubeSprite setPosition2d:P2Make(0, 0)];
        
        [self addChild:cubeSprite];
        
        [cubeSprite repeatAction:[NKAction rotateXByAngle:180 duration:10.]];
        
        NKSpriteNode *testSprite = [[NKSpriteNode alloc] initWithTexture:[NKTexture textureWithImageNamed:@"ball_Texture.png"] color:NKWHITE size:P2Make(250,250)];
        
        [testSprite setPosition2d:P2Make(0, -400)];
        
        [self addChild:testSprite];
        
        [testSprite repeatAction:[NKAction rotateZByAngle:180 duration:10.]];
        
    }
    
    return self;
}
@end
