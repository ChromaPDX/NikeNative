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
        self.position3d = V3Make(scene.position3d.x, scene.position3d.y, scene.position3d.z - 1);
        self.name = @"CAMERA";
         pDirty = true;
        
        self.aspect = self.scene.size.width / self.scene.size.height; // Use screen bounds as default
        _nearZ = .01f;
        _farZ = 1000.0f;
        _fovVertRadians = DEGREES_TO_RADIANS(54);
        
        self.upVector = V3Make(0, 1, 0);
        
        _target = [[NKNode alloc]init];
        
        [self initGL];
       
    }
    return self;
}

-(void)setTarget:(NKNode *)target {
    [self lookAtNode:target];
}

-(void)lookAtNode:(NKNode *)node {
    [_target removeAllActions];
    [_target runAction:[NKAction moveToFollowNode:node duration:1.] completion:^{
        [_target repeatAction:[NKAction followNode:node duration:1.]];
    }];
}


-(void)setDirty:(bool)dirty {
    [super setDirty:dirty];
    vpDirty = dirty;
    vDirty = dirty;
}

- (M16t)viewProjectionMatrix
{
    if (vpDirty) {
        vpDirty = false;
        return viewProjectionMatrix = M16Multiply([self projectionMatrix], [self viewMatrix]);
    }
    
    return viewProjectionMatrix;
}

- (M16t)viewMatrix {
    if (vDirty) {
        localTransformMatrix = viewMatrix = [self getLookMatrix:_target.getGlobalPosition];
        M16SetV3Translation(&localTransformMatrix, position);
        vDirty = false;
        return viewMatrix;
    }
    return viewMatrix;
}


-(M16t)projectionMatrix {
    if (pDirty) {
        pDirty = false;
        return projectionMatrix = M16MakePerspective(self.fovVertRadians,
                                                     self.aspect,
                                                     self.nearZ,
                                                     self.farZ);
    }
    return projectionMatrix;
}

-(void)initGL {
    
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_BLEND);
    
    glLineWidth(1.0f);
    
    glGetError(); // Clear error codes
    
}


-(void)begin {
   // [self.scene pushMultiplyMatrix:self.viewMatrix];
}

-(void)end {
   // [self.scene popMatrix];
}

-(void)draw {
    // TO DO: if draw camera, also draw children if parented?
}


#pragma mark UTIL

-(V3t)eyeDirection {
    V3t eye = V3MultiplyM16(self.viewMatrix,V3Subtract(self.getGlobalPosition,_target.position3d));
    //V3t eye = V3Subtract(self.getGlobalPosition,_target.getGlobalPosition);
    //V3t eye = V3Make(0, 0, -1);
    //NSLog(@"eye vec: %f, %f, %f", eye.x, eye.y, eye.z);
    return eye;
}

////convert from screen to camera
//-(V3t)s2w:(P2t)ScreenXY {
//    V3t CameraXYZ;
//    
//    CameraXYZ.x = ((ScreenXY.x * 2.) / self.scene.size.width) - 1.;
//    CameraXYZ.y = ((ScreenXY.y * 2.) / self.scene.size.height)- 1.;
//    CameraXYZ.z = self.position3d.z;
//    
//    //CameraXYZ.z = ScreenXYZ.z;
//    NSLog(@"noralized screen coords %f %f %f", CameraXYZ.x, CameraXYZ.y, CameraXYZ.z);
//    //get inverse camera matrix
//    M16t inverseCamera = M16InvertColumnMajor([self projectionMatrix], NULL);
//    
//    //convert camera to world
//    V3t p = V3MultiplyM16(inverseCamera, CameraXYZ);
//    
//    NSLog(@"camera coords %f %f %f", p.x, p.y, p.z);
//    return p;
//}
//
//-(P2t)screenToWorld:(P2t)p {
//
//    V3t p2 = [self s2w:p];
//        p2.x *= 1000.;
//        p2.y *= 1000.;
//
//     //NSLog(@"world i: %f %f o:%f %f", p.x, p.y, p2.x, p2.y);
//    return P2Make(p2.x, p2.y);
//    //return P2Make(10000, 10000);
//}
//
//-(P2t)screenPoint:(P2t)p InNode:(NKNode*)node {
//    
//    V3t CameraXYZ;
//    CameraXYZ.x = p.x / self.scene.size.width - 1.0f;
//    CameraXYZ.y = p.y / self.scene.size.height;
//    //CameraXYZ.z = ScreenXYZ.z;
//    
//    //get inverse camera matrix
//    M16t inverseCamera = M16InvertColumnMajor([node getGlobalTransformMatrix], NULL);
//    
//    //convert camera to world
//    
//    V3t p2 = V3MultiplyM16(inverseCamera, CameraXYZ);
//
//    p2.x *= 1820.;
//    p2.y *= 1820.;
//    
//    //NSLog(@"world i: %f %f o:%f %f", p.x, p.y, p2.x, p2.y);
//    return P2Make(p2.x, p2.y);
//    
//}

-(void)updateWithTimeSinceLast:(F1t)dt {
    [_target updateWithTimeSinceLast:dt];
    [super updateWithTimeSinceLast:dt];
}

@end
