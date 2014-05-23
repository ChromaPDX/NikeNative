//
//  NKCamera.h
//  nike3dField
//
//  Created by Chroma Developer on 4/1/14.
//
//
//test
#import "NKNode.h"

@class NKSceneNode;

@interface NKCamera : NKNode {
    M16t cachedMatrix;
}

@property F1t fovVertRadians;
@property F1t aspect;
@property F1t nearZ;
@property F1t farZ;

//@property (nonatomic, assign) V3t target;
@property (nonatomic, strong) NKNode *target;

- (M16t)projectionMatrix;

@property (nonatomic) M9t normalMatrix;

-(instancetype)initWithScene:(NKSceneNode*)scene;
-(P2t)screenToWorld:(P2t)p;

@end
