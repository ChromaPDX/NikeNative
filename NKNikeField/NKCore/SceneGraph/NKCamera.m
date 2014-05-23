//
//  NKCamera.m
//  nike3dField
//
//  Created by Chroma Developer on 4/1/14.
//
//

#import "NodeKitten.h"

@implementation NKCamera

-(instancetype) initWithScene:(NKSceneNode*)scene {
    self = [super init];
    if (self) {
        self.scene = scene;
        self.name = @"CAMERA";
        [self initGL2];

  
    }
    return self;
}

-(void)lookAtNode:(NKNode *)node {
    [_target removeAllActions];
    [_target runAction:[NKAction moveToFollowNode:node duration:.5] completion:^{
        [_target repeatAction:[NKAction followNode:node duration:1.]];
    }];
}

- (M16t)projectionMatrix
{
    if (self.dirty) {
        
        M16t projectionMat = M16MakePerspective(self.fovVertRadians,
                                                self.aspect,
                                                self.nearZ,
                                                self.farZ);
        
        M16t camMat = [self getLookMatrix:_target.getGlobalPosition];
        
//        M16t camMat = M16MakeLookAt(self.position3d.x, self.position3d.y, self.position3d.z,
//                                    _target.x, _target.y, _target.z,
//                                    _up.x, _up.y, _up.z);
        
        self.dirty = false;
        
        return cachedMatrix = M16Multiply(projectionMat, camMat);
        
    }
    
    return cachedMatrix;
    
}

-(void)initGL2 {
    
    self.aspect = self.scene.size.width / self.scene.size.height; // Use screen bounds as default
    //self.fovVertRadians = DEGREES_TO_RADIANS(82.0f * self.aspect);
    //self.fovVertRadians = DEGREES_TO_RADIANS(30 / self.aspect);
    
#if NK_USE_GLES
    if (self.scene.size.height == 1136) {
        self.fovVertRadians = DEGREES_TO_RADIANS(53);
    }
    else {
        self.fovVertRadians = DEGREES_TO_RADIANS(54);
    }
#else
    self.fovVertRadians = DEGREES_TO_RADIANS(54);
#endif
    
    self.nearZ = 10.f;
    self.farZ = 10000.0f;
    
    
    self.position3d = V3Make(0,0, self.scene.size.height);
    self.upVector = V3Make(0, 1, 0);
    
    _normalMatrix = M9IdentityMake();
    
    _target = [[NKNode alloc]init];
    
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_BLEND);
    
    glLineWidth(1.0f);
    
    glGetError(); // Clear error codes
    
}


-(void)begin {
    [super begin];
    
    //[[self.scene activeShader] setMatrix3:_normalMatrix forUniform:UNIFORM_NORMAL_MATRIX];
}


#pragma mark UTIL

//convert from screen to camera
-(V3t)s2w:(P2t)ScreenXY {
    V3t CameraXYZ;
    
    CameraXYZ.x = ((ScreenXY.x * 2.) / self.scene.size.width) - 1.;
    CameraXYZ.y = ((ScreenXY.y * 2.) / self.scene.size.height)- 1.;
    CameraXYZ.z = self.position3d.z;
    
    //CameraXYZ.z = ScreenXYZ.z;
    NSLog(@"noralized screen coords %f %f %f", CameraXYZ.x, CameraXYZ.y, CameraXYZ.z);
    //get inverse camera matrix
    M16t inverseCamera = M16InvertColumnMajor([self projectionMatrix], NULL);
    
    //convert camera to world
    V3t p = V3MultiplyM16(inverseCamera, CameraXYZ);
    
    NSLog(@"camera coords %f %f %f", p.x, p.y, p.z);
    return p;
}

-(P2t)screenToWorld:(P2t)p {

    V3t p2 = [self s2w:p];
        p2.x *= 1000.;
        p2.y *= 1000.;

     //NSLog(@"world i: %f %f o:%f %f", p.x, p.y, p2.x, p2.y);
    return P2Make(p2.x, p2.y);
    //return P2Make(10000, 10000);
}

-(P2t)screenPoint:(P2t)p InNode:(NKNode*)node {
    
    V3t CameraXYZ;
    CameraXYZ.x = p.x / self.scene.size.width - 1.0f;
    CameraXYZ.y = p.y / self.scene.size.height;
    //CameraXYZ.z = ScreenXYZ.z;
    
    //get inverse camera matrix
    M16t inverseCamera = M16InvertColumnMajor([node getGlobalTransformMatrix], NULL);
    
    //convert camera to world
    
    V3t p2 = V3MultiplyM16(inverseCamera, CameraXYZ);

    p2.x *= 1820.;
    p2.y *= 1820.;
    
    //NSLog(@"world i: %f %f o:%f %f", p.x, p.y, p2.x, p2.y);
    return P2Make(p2.x, p2.y);
    
}

-(void)updateWithTimeSinceLast:(F1t)dt {
    [super updateWithTimeSinceLast:dt];
    [_target updateWithTimeSinceLast:dt];
}

@end
