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
        
        if (NK_GL_VERSION == 2) {
            [self initGL2];
            //[self setPosition3d:V3Make(0,0,1.)];
        }
        else {
            [self initGL1];
        }
        //[self setOrientationEuler:V3Make(0,180,0)];
       
    }
    return self;
}

- (M16t)projectionMatrix
{
    if (self.dirty) {
        
        M16t projectionMat = M16MakePerspective(self.fovVertRadians,
                                                self.aspect,
                                                self.nearZ,
                                                self.farZ);
        
        M16t camMat = M16MakeLookAt(self.position3d.x, self.position3d.y, self.position3d.z,
                                    _target.x, _target.y, _target.z,
                                    _up.x, _up.y, _up.z);
        
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
    self.target = V3Make(0, 0, 0);
    self.position3d = V3Make(0,0, self.scene.size.height);
    self.up = V3Make(0, 1, 0);
    
    _normalMatrix = M9IdentityMake();
    
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_BLEND);
    
    glLineWidth(1.0f);
    
    glGetError(); // Clear error codes
    
}

-(void)initGL1{
  
    self.fovVertRadians = DEGREES_TO_RADIANS(36.0f);
    
    self.aspect = self.scene.size.width / self.scene.size.height; // Use screen bounds as default
    self.nearZ = 10.f;
    self.farZ = 10000.0f;
    [self setPosition3d:V3Make(0,0,-1000.)];
    self.target = V3Make(0, 0, 0);
    self.up = V3Make(0, 1, 0);
    
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    F1t frustum = _nearZ * tanf(_fovVertRadians / 2.0);
    
#if NK_USE_GLES
    glFrustumf(-frustum, frustum, -frustum/_aspect, frustum/_aspect, _nearZ, _farZ);
#else
    glFrustum(-frustum, frustum, -frustum/_aspect, frustum/_aspect, _nearZ, _farZ);
#endif
    
    //glTranslatef(0, 0, -1000);
    //glMultMatrixf([self projectionMatrix].m);
    
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    glViewport(0, 0, self.scene.size.width, self.scene.size.height);
    
    glEnable(GL_DEPTH_TEST);
    
    glEnable(GL_ALPHA_TEST);
    glAlphaFunc(GL_GREATER, .1);
    
    glEnable(GL_BLEND);
    
    glShadeModel(GL_SMOOTH);
    //[self initLighting];
    
    glGetError(); // Clear error codes
}

-(void)begin {
    [super begin];
    
    if (NK_GL_VERSION == 2) {
        [[self.scene activeShader] setMatrix3:_normalMatrix forUniform:UNIFORM_NORMAL_MATRIX];
    }
}

//-(void)setFieldOfView:(float)fieldOfView{
//    _fieldOfView = fieldOfView;
//    glMatrixMode(GL_PROJECTION);
//    glLoadIdentity();
//    GLfloat frustum = zNear * tanf(DEGREES_TO_RADIANS(_fieldOfView) / 2.0);
//    
//    if (NK_GL_VERSION == 2) {
//        frustrum = M16MakeFrustum(-frustum, frustum, -frustum/_aspectRatio, frustum/_aspectRatio, zNear, zFar);
//    }
//    else {
//        glFrustumf(-frustum, frustum, -frustum/_aspectRatio, frustum/_aspectRatio, zNear, zFar);
//        glMatrixMode(GL_MODELVIEW);
//    }
//}

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
    if (NK_GL_VERSION == 2) {
        p2.x *= 1000.;
        p2.y *= 1000.;
    }
    else {
        p2.x *= -1800.;
        p2.y *= 1800.;
    }
    
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

@end
