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
    
    bool isOrtho;
	float zNear;
	float zFar;
	P2t lensOffset;
	bool forceAspectRatio;
	float aspectRatio; // only used when forceAspect=true, = w / h
	bool isActive;
	bool vFlip;
    float s2w;
    R4t viewPort;
    float _aspectRatio;
    
    M16t frustrum;
    
}

@property (nonatomic) float fieldOfView;
@property (nonatomic) M16t projectionMatrix;
@property (nonatomic) M9t normalMatrix;

-(instancetype)initWithScene:(NKSceneNode*)scene;
-(P2t)screenToWorld:(P2t)p;

@end
