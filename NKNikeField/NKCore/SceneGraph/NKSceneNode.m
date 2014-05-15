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
 //       [self logCoords];
        
        self.backgroundColor = [UIColor colorWithRed:.25 green:.25 blue:.25 alpha:1.];
        self.shouldRasterize = false;
        useShader = false;
        self.userInteractionEnabled = true;
        
        self.blendMode = -1;
        self.cullFace = -1;

        _camera = [[NKCamera alloc]initWithScene:self];
        
        self.scene = self;
        
        if (NK_GL_VERSION == 2) {
            
            matrixStack = malloc(sizeof(M16t)*32);
            matrixBlockSize = 32;
            matrixCount = 0;
            
            modelMatrix = M16IdentityMake();
            
            memcpy(matrixStack+matrixCount, modelMatrix.m, sizeof(M16t));
            
            axes = [NKVertexBuffer axes];
            self.shader = [NKShaderProgram defaultShader];
            [self.shader load];
            
            _hitDetectBuffer = [[NKFrameBuffer alloc] initWithWidth:self.size.width height:self.size.height];
            
            _hitDetectShader = [[NKShaderProgram alloc]initWithVertexSource:nkHitDetectVertexShader fragmentSource:nkHitDetectFragmentShader];
            [_hitDetectShader load];
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

-(void)pushMatrix{
    
    matrixCount++;
    
    if (matrixBlockSize <= matrixCount) {
        NSLog(@"Expanding MATRIX STACK allocation size");
        M16t* copyBlock = malloc(sizeof(M16t) * (matrixCount*2));
        memcpy(copyBlock, matrixStack, sizeof(M16t) * (matrixCount));
        free(matrixStack);
        matrixStack = copyBlock;
    }

    
}
-(void)pushMultiplyMatrix:(M16t)matrix {
    
    [self pushMatrix];
    
    modelMatrix = M16Multiply(modelMatrix, matrix);
    
    memcpy(matrixStack+matrixCount, modelMatrix.m, sizeof(M16t));
    
    //NSLog(@"push M %lu", matrixCount);
    
    [_activeShader setMatrix4:M16Multiply(_camera.projectionMatrix,modelMatrix) forUniform:UNIFORM_MODELVIEWPROJECTION_MATRIX];
    //[_activeShader setMatrix4:modelMatrix forUniform:UNIFORM_MODELVIEWPROJECTION_MATRIX];
   
}

-(void)pushScale:(V3t)nscale {
    
    [self pushMatrix];
    
    modelMatrix = M16ScaleWithV3(modelMatrix, nscale);
    
    memcpy(matrixStack+matrixCount, modelMatrix.m, sizeof(M16t));
    
    //NSLog(@"push M %lu", matrixCount);
    
    [_activeShader setMatrix4:M16Multiply(_camera.projectionMatrix,modelMatrix) forUniform:UNIFORM_MODELVIEWPROJECTION_MATRIX];
    
}

-(void)popMatrix {
    if (matrixCount > 0) {
        matrixCount--;
        
        memcpy(modelMatrix.m, matrixStack+matrixCount, sizeof(M16t));
        
        //NSLog(@"pop M %lu", matrixCount);
    }
    else {
        NSLog(@"MATRIX STACK UNDERFLOW");
    }
    
    //[_activeShader setMatrix4:modelMatrix forUniform:UNIFORM_MODELVIEWPROJECTION_MATRIX];
    [_activeShader setMatrix4:M16Multiply(_camera.projectionMatrix,modelMatrix) forUniform:UNIFORM_MODELVIEWPROJECTION_MATRIX];
}

-(void)drawForHitDetection {
    
    [_hitDetectBuffer bind];
    
    self.blendMode = NKBlendModeNone;
    glDisable(GL_BLEND);
    
    _activeShader = _hitDetectShader;
    [_activeShader use];
    
    glViewport(0, 0, self.size.width, self.size.height);
    
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    
    [super drawForHitDetection];
    
    [_hitDetectBuffer unbind];
    
}

-(void)draw {


    if (NK_GL_VERSION == 2) {

        [_activeShader use];
        
//        [_activeShader setMatrix4:M16IdentityMake() forUniform:UNIFORM_MODELVIEWPROJECTION_MATRIX];
//        [_activeShader setMatrix3:M9IdentityMake() forUniform:UNIFORM_NORMAL_MATRIX];
        
        // 1
        glViewport(0, 0, self.size.width, self.size.height);
        
        if (_backgroundColor) {
            C4t c;
            [_backgroundColor getRed:&c.r green:&c.g blue:&c.b alpha:&c.a];
            glClearColor(c.r, c.g, c.b, c.a);
        }
        
//        [_activeShader setInt:1 forUniform:USE_UNIFORM_COLOR];
//        [_activeShader setVec4:C4Make(1., 1., 1., 1.) forUniform:UNIFORM_COLOR];

       // [self drawAxes];
        // 2
       
#ifdef SHOW_HIT_DETECTION
        self.blendMode = NKBlendModeNone;
        glDisable(GL_BLEND);
        
        _activeShader = _hitDetectShader;
        [_activeShader use];
        
         [super drawForHitDetection];
#else
        [super draw];
#endif

    }
    
    else {
        
        if (_backgroundColor) {
            C4t c;
            [_backgroundColor getRed:&c.r green:&c.g blue:&c.b alpha:&c.a];
            glClearColor(c.r, c.g, c.b, c.a);
        }
        
        if (!self.parent) {
            [_camera begin];
        }
        
        //[self drawAxes];
        
        [super draw];
        
        if (!self.parent) {
            [_camera end];
        }
        
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
    
-(void)drawAxes {
    
    if (NK_GL_VERSION == 2) {
        [self.activeShader setInt:0 forUniform:UNIFORM_NUM_TEXTURES];
        [axes bind:^{
            glLineWidth(4.0);
            glDrawArrays(GL_LINES, 0, axes.numberOfElements);
        }];
    }
    else {
        static const GLfloat XAxis[] = {-1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f};
        static const GLfloat YAxis[] = {0.0f, -1.0f, 0.0f, 0.0f, 1.0f, 0.0f};
        static const GLfloat ZAxis[] = {0.0f, 0.0f, -1.0f, 0.0f, 0.0f, 1.0f};
        
        glPushMatrix();
        
        glColor4f(1.0, 1.0, 1.0, 1.0);
        
        glEnableClientState(GL_VERTEX_ARRAY);
        
        glScalef(self.scene.size.width, self.scene.size.height, 1000.);
        glLineWidth(2.0);
        glColor4f(1.0, 0., 0., 1.0);
        glVertexPointer(3, GL_FLOAT, 0, XAxis);
        glDrawArrays(GL_LINE_LOOP, 0, 2);
        glColor4f(0, 1., 0., 1.0);
        glVertexPointer(3, GL_FLOAT, 0, YAxis);
        glDrawArrays(GL_LINE_LOOP, 0, 2);
        glColor4f(0., 0., 1.0, 1.0);
        glVertexPointer(3, GL_FLOAT, 0, ZAxis);
        glDrawArrays(GL_LINE_LOOP, 0, 2);
        
        glDisableClientState(GL_VERTEX_ARRAY);
        
        glPopMatrix();
    }
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

-(void)alertDidSelectOption:(int)option {
    if (option == 0) {
        [self alertDidCancel];
    }
    // OVERRIDE IN SUBCLASS FOR OTHER OPTIONS
}

-(void)alertDidCancel {
    [self dismissAlertAnimated:true];
}

-(void)presentAlert:(NKAlertSprite*)alert animated:(BOOL)animated {
    
    _alertSprite = alert;
    
    if (animated) {
        [_alertSprite setPosition:P2Make(0, -self.size.height)];
    }
    else {
        [_alertSprite runAction:[NKAction moveTo:P2Make(0, 0) duration:.3]];
        [self addChild:alert];
    }
}

-(void)dismissAlertAnimated:(BOOL)animated{
    if (animated) {
        [_alertSprite runAction:[NKAction moveTo:P2Make(0, -self.size.height) duration:.3] completion:^{
            [self removeChild:_alertSprite];
            _alertSprite = nil;
        }];
    }
    else {
        [self removeChild:_alertSprite];
        _alertSprite = nil;
    }
}

-(void)getUidColorForNode:(NKNode*)node {
    
    float min = (10./255.);
    float max = (254./255.);
    
    if (!hitColorMap) {
        hitColorMap = [[NSMutableDictionary alloc]init];
        uidR = min;
        uidG = min;
        uidB = min;
    }
    
    node.uidColor = [NKColor colorWithRed:uidR green:uidG blue:uidB alpha:1.];
    [hitColorMap setObject:node forKey:node.uidColor];
    
    float inc = (1./255.);
    
    if (uidB < max) {
        uidB+=inc;
    }
    else {
        if (uidG < max) {
            uidG+=inc;
            uidB = min+inc;
        }
        else {
            if (uidR < max) {
                uidR += inc;
                uidG = min+inc;;
                uidB = min+inc;;
            }
            else {
                NSLog(@"**ERROR** out of uid colors");
            }
        }
    }
    
}

-(NKNode*)hitNodeAtPoint:(P2t)location {

    NKNode *hit = [hitColorMap objectForKey:[_hitDetectBuffer colorAtPoint:location]];
    
    return hit;
}

-(NKTouchState)touchDown:(P2t)location id:(int)touchId {
    
    if (_alertSprite) {
        return [_alertSprite touchDown:location id:touchId];
    }
    else {
        
        NKNode *hit = [self hitNodeAtPoint:location];
        
        if (hit) {
            NSLog(@"touch down node: %@", hit);
            [hit touchDown:location id:touchId];
        }
        
        return NKTouchIsFirstResponder;
    }
}

//
-(NKTouchState)touchMoved:(P2t)location id:(int)touchId {
    
    if (_alertSprite) {
        return [_alertSprite touchMoved:location id:touchId];
    }
    else {
        NKNode *hit = [self hitNodeAtPoint:location];
        
        if (hit) {
            NSLog(@"touch moved node: %@", hit);
            [hit touchMoved:location id:touchId];
        }
        
        return NKTouchIsFirstResponder;
        
    }
}
//
-(NKTouchState)touchUp:(P2t)location id:(int)touchId {

   NKNode *hit = [self hitNodeAtPoint:location];
    
    if (hit) {
        NSLog(@"touch up node: %@", hit);
        [hit touchUp:location id:touchId];
    }
    
    return false;
}
//
-(void)dealloc {
    if (matrixStack) {
        free(matrixStack);
    }
    
}

@end
