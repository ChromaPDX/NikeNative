//
//  NKCamera.h
//  nike3dField
//
//  Created by Chroma Developer on 4/1/14.
//
//
//test
#import "NKNode.h"
#import <GLKit/GLKit.h>

@class NKSceneNode;

@interface NKCamera : NKNode {
    M16t viewMatrix;
    M16t projectionMatrix;
    M16t viewProjectionMatrix;
    
    bool vDirty;
    bool pDirty;
    bool vpDirty;
}

@property F1t fovVertRadians;
@property F1t aspect;
@property F1t nearZ;
@property F1t farZ;

@property (nonatomic, strong) NKNode *target;

- (M16t)viewMatrix;
- (M16t)projectionMatrix;
- (M16t)viewProjectionMatrix;

- (V3t)eyeDirection;

-(instancetype)initWithScene:(NKSceneNode*)scene;
-(P2t)screenToWorld:(P2t)p;

@end
