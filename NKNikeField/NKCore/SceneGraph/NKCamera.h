//
//  NKCamera.h
//  nike3dField
//
//  Created by Chroma Developer on 4/1/14.
//
//

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
}

@property (nonatomic) float fieldOfView;

-(instancetype)initWithScene:(NKSceneNode*)scene;
-(CGPoint)screenToWorld:(CGPoint)p;

@end
