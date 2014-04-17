//
//  NKCamera.m
//  nike3dField
//
//  Created by Chroma Developer on 4/1/14.
//
//

#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

#import "NodeKitten.h"

@implementation NKCamera

-(instancetype) initWithScene:(NKSceneNode*)scene {
    self = [super init];
    if (self) {

        self.scene = scene;
        self.name = @"CAMERA";
        
        [self initGL];
  
        //[self setOrientationEuler:V3Make(0,180,0)];
        [self setPosition3d:V3Make(0,0,-1000.)];
        

    }
    return self;

}

-(void)initGL{

    _fieldOfView = 36;
    aspectRatio = (float)self.scene.size.width / (float)self.scene.size.height;
    
    if([UIApplication sharedApplication].statusBarOrientation > 2)
        aspectRatio = 1/aspectRatio;
    
    viewPort = R4Make(0,0,self.scene.size.width,self.scene.size.height);
    
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    
    zNear = 10;
    zFar = 10000;
    
    GLfloat frustum = zNear * tanf(DEGREES_TO_RADIANS(_fieldOfView) / 2.0);
    glFrustumf(-frustum, frustum, -frustum/aspectRatio, frustum/aspectRatio, zNear, zFar);
    
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    glViewport(viewPort.x, viewPort.y, viewPort.w, viewPort.h);
    
    glEnable(GL_DEPTH_TEST);
    
    glEnable(GL_ALPHA_TEST);
    glAlphaFunc(GL_GREATER, .1);
    
    glEnable(GL_BLEND);
    
    glShadeModel(GL_SMOOTH);
    //[self initLighting];
    
    glGetError(); // Clear error codes


}

-(void)setFieldOfView:(float)fieldOfView{
    _fieldOfView = fieldOfView;
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    GLfloat frustum = zNear * tanf(DEGREES_TO_RADIANS(_fieldOfView) / 2.0);
    glFrustumf(-frustum, frustum, -frustum/_aspectRatio, frustum/_aspectRatio, zNear, zFar);
    glMatrixMode(GL_MODELVIEW);
}

-(void)initLighting{
    GLfloat white[] = {.3f, .3f, .3f, 1.0f};
    GLfloat blue[] = {0.0f, 0.0f, 1.0f, 1.0f};
    GLfloat green[] = {0.0f, 1.0f, 0.0f, 1.0f};
    GLfloat red[] = {1.0f, 0.0f, 0.0f, 1.0f};
    
    GLfloat pos1[] = {0.0f, 100.0f, 0.0f, 1.0f};
    GLfloat pos2[] = {-100.0f, 0.0f, 0.0f, 1.0f};
    GLfloat pos3[] = {100.0f, 0.0f,  0.0f, 1.0f};
    
    glLightfv(GL_LIGHT0, GL_AMBIENT, white);
    glLightfv(GL_LIGHT1, GL_POSITION, pos1);
    glLightfv(GL_LIGHT1, GL_DIFFUSE, blue);
    glLightfv(GL_LIGHT2, GL_POSITION, pos2);
    glLightfv(GL_LIGHT2, GL_DIFFUSE, red);
    glLightfv(GL_LIGHT3, GL_POSITION, pos3);
    glLightfv(GL_LIGHT3, GL_DIFFUSE, green);
    
    //glMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT, white);
    //glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, blue);
    
    glShadeModel(GL_SMOOTH);
    glEnable(GL_LIGHTING);
    
    glEnable(GL_LIGHT0);
    glEnable(GL_LIGHT1);
    glEnable(GL_LIGHT2);
    glEnable(GL_LIGHT3);
}

#pragma mark UTIL

//----------------------------------------
-(M16t) getProjectionMatrix:(R4t)viewport {
//	if(isOrtho) {
//		return M16t::newOrthoMatrix(0, viewport.width, 0, viewport.height, nearClip, farClip);
//	}else{
    float aspect = forceAspectRatio ? aspectRatio : viewport.w/viewport.h;
    
    M16t matProjection = M16Multiply(M16MakePerspective(DEGREES_TO_RADIANS(_fieldOfView), aspect, zNear, zFar), M16MakeTranslate(-lensOffset.x, -lensOffset.y, 0));

    return matProjection;
//	}
}

//----------------------------------------
-(M16t)getModelViewMatrix {
	return M16InvertColumnMajor([self getGlobalTransformMatrix], NULL);
}

//convert from screen to camera
-(V3t)s2w:(CGPoint)ScreenXY {
    
    V3t CameraXYZ;
    CameraXYZ.x = 4.0f * (ScreenXY.x - viewPort.x) / viewPort.w - 1.0f;
    CameraXYZ.y = 1.0f - 4.0f*(ScreenXY.y - viewPort.y) / viewPort.h;
    //CameraXYZ.z = ScreenXYZ.z;
    
    //get inverse camera matrix
    M16t inverseCamera = M16InvertColumnMajor([self getProjectionMatrix:viewPort], NULL);
    
    //convert camera to world
    
    return V3MultiplyM16(inverseCamera, CameraXYZ);
}



-(CGPoint)screenToWorld:(CGPoint)p {

     V3t p2 = [self s2w:p];
    p2.x *= 1800.;
    p2.y *= 1800.;
     //NSLog(@"world i: %f %f o:%f %f", p.x, p.y, p2.x, p2.y);
    return CGPointMake(p2.x, p2.y);
    //return CGPointMake(10000, 10000);
}

@end
