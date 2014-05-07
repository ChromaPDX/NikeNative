//
//  NKSceneNode.m
//  example-ofxTableView
//
//  Created by Chroma Developer on 2/17/14.
//
//

#import "NodeKitten.h"

@implementation NKSceneNode


-(instancetype)initWithSize:(S2t)size {
    
    self = [super init];
    
    if (self){
        
        self.size3d = V3Make(size.width, size.height, 1);
        
        self.name = @"SCENE";
        [self logCoords];
        
        self.backgroundColor = [UIColor colorWithRed:.25 green:.25 blue:.25 alpha:1.];
        self.shouldRasterize = false;
        useShader = false;
        self.userInteractionEnabled = true;
        self.blendMode = -1;
        self.cullFace = -1;
        
        matrixStack = [[NSMutableData alloc]initWithCapacity:(sizeof(M16t)*32)];
        modelMatrix = M16IdentityMake();
        stackP = 0;
        
        _camera = [[NKCamera alloc]initWithScene:self];

        self.scene = self;
        
        if (NK_GL_VERSION == 2) {
            self.shader = [NKShaderProgram defaultShader];
            [self.shader load];
        }
        
    }
    
    return self;
}

-(void)updateWithTimeSinceLast:(F1t)dt {
    fps = (int)(1000./dt);
    
    [_camera updateWithTimeSinceLast:dt];
    [NKSoundManager updateWithTimeSinceLast:dt];
    
    [super updateWithTimeSinceLast:dt];
}

-(void)pushMultiplyMatrix:(M16t)matrix {
    
//    M16t new;
//
//    new = M16Multiply(modelMatrix, matrix);
//    
//    if (matrixStack.length <= stackP) {
//        [matrixStack appendBytes:new.m length:sizeof(M16t)];
//    }
//    else {
//        char * p = [matrixStack bytes];
//        p+= stackP;
//        memcpy(p, new.m, sizeof(M16t));
//    }
//
//    stackP+=sizeof(M16t);
//   
//    //[_activeShader setMatrix4:M16Multiply(new, _camera.projectionMatrix) forUniform:UNIFORM_MODELVIEWPROJECTION_MATRIX];
//    [_activeShader setMatrix4:new forUniform:UNIFORM_MODELVIEWPROJECTION_MATRIX];
   
}

-(void)popMatrix {
//    if (stackP > 0) {
//    stackP-=sizeof(M16t);
//    
//    char * p = [matrixStack bytes];
//    p += stackP;
//    memcpy(modelMatrix.m, p, sizeof(M16t));
//        
//    //NSLog(@"matrix stack %d",stackP/sizeof(M16t));
//    }
//    else {
//        NSLog(@"MATRIX STACK UNDERFLOW");
//    }
//    
//    [_activeShader setMatrix4:M16Multiply(modelMatrix, _camera.projectionMatrix) forUniform:UNIFORM_MODELVIEWPROJECTION_MATRIX];
}

-(void)draw {

    if (NK_GL_VERSION == 2) {
        
        [_activeShader use];
        
        [_activeShader setMatrix4:M16IdentityMake() forUniform:UNIFORM_MODELVIEWPROJECTION_MATRIX];
        [_activeShader setMatrix3:M9IdentityMake() forUniform:UNIFORM_NORMAL_MATRIX];
        
        // 1
        glViewport(0, 0, self.size.width, self.size.height);
        
        // 2
        [_activeShader setInt:1 forUniform:USE_UNIFORM_COLOR];
        [_activeShader setVec4:C4Make(1., 1., 1., 1.) forUniform:UNIFORM_COLOR];
    }
    
    if (_backgroundColor) {
        C4t c;
        [_backgroundColor getRed:&c.r green:&c.g blue:&c.b alpha:&c.a];
        glClearColor(c.r, c.g, c.b, c.a);
    }
    
   
    
    if (!self.parent) {
        [_camera begin];
    }
    
    [super draw];

    if (!self.parent) {
        [_camera end];
    }
    
    // UNCOMMENT TO DEBUG / DRAW DEPTH BUFFER
//    if (self.depthFbo){
//        // NSLog(@"draw depth fbo");
//        ofClear(0, 0, 0, 255);
//        glPushMatrix();
//        ofSetColor(255);
//        //ofTranslate(self.size.width*.5, self.size.height*.5);
//        //ofMultMatrix(self.node->getGlobalTransformMatrix().getInverse());
//        self.depthFbo->draw(0,0);
//        glPopMatrix();
//        
//    }
    
}
    


//-(void)end {
//    
//    if (!self.isHidden && (!_shouldRasterize || (_shouldRasterize && dirty)))
//    {
//        
//        if (useShader){
//            [self.shader end];
//        }
//        
//        if (_shouldRasterize) {
//            
//            if (!self.parent) {
//                [_camera end];
//            }
//            
//            fbo->end();
//            dirty = false;
//            
//        }
//        
//        else {
//            glPopMatrix();
//            //self.node->restoreTransformGL();
//            
//            if (!self.parent) {
//                [_camera end];
//            }
//         
//        }
//        
//    }
//    
//    else if (_shouldRasterize && !dirty) {
//        
//        R4t d = [self getDrawFrame];
//        
//        glPushMatrix();
//        ofMultMatrix( self.node->getLocalTransformMatrix() );
//        
//        fbo->draw(d.x, d.y);
//        
//        glPopMatrix();
//    }
//    
//    if  (debugUI){
//        string stats = "nodes :" + ofToString([self numNodes]) + " draws: " + ofToString([self numVisibleNodes]) + " fps: " + ofToString(fps);
//        ofDrawBitmapStringHighlight(stats, V3Makeself.size.width - 230, self.size.height - 7, _camera.get3dPosition.z));
//    }
//    
//    
//}


-(int)touchDown:(P2t)location id:(int)touchId {

    P2t p = [_camera screenToWorld:location];
    
    return [super touchDown:p id:touchId];
}
//
-(int)touchMoved:(P2t)location id:(int)touchId {
    P2t p = [_camera screenToWorld:location];
    
    return [super touchMoved:p id:touchId];
}
//
-(int)touchUp:(P2t)location id:(int)touchId {

    P2t p = [_camera screenToWorld:location];
    
    NSLog(@"touch : %f %f", p.x, p.y);
    
    return [super touchUp:p id:touchId];
}
//


@end
