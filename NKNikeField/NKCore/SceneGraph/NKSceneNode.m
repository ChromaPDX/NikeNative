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
        
        self.backgroundColor = [NKByteColor colorWithRed:50 green:50 blue:50 alpha:255];
        self.shouldRasterize = false;
        useShader = false;
        self.userInteractionEnabled = true;
        
        _hitQueue = [NSMutableArray array];
        
        self.blendMode = 0;
        self.cullFace = 0;
        
        _camera = [[NKCamera alloc]initWithScene:self];
        self.scene = self;
        
      
            
            matrixStack = malloc(sizeof(M16t)*32);
            matrixBlockSize = 32;
            matrixCount = 0;
            
            modelMatrix = M16IdentityMake();
            
            memcpy(matrixStack+matrixCount, modelMatrix.m, sizeof(M16t));
            
            self.shader = [NKShaderProgram defaultShader];
            [self.shader load];
            
            _hitDetectBuffer = [[NKFrameBuffer alloc] initWithWidth:self.size.width height:self.size.height];
            
            _hitDetectShader = [[NKShaderProgram alloc]initWithVertexSource:nkHitDetectVertexShader fragmentSource:nkHitDetectFragmentShader];
            [_hitDetectShader load];
    
        
        
        NSLog(@"init scene with size, %f %f", size.width, size.height);
        
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
        matrixBlockSize = matrixCount * 2;
    }

    
}
-(void)pushMultiplyMatrix:(M16t)matrix {
    
    [self pushMatrix];
    
    modelMatrix = M16Multiply(modelMatrix, matrix);
    
    memcpy(matrixStack+matrixCount, modelMatrix.m, sizeof(M16t));
    
    //NSLog(@"push M %lu", matrixCount);
    
    //[_activeShader setMatrix4:M16Multiply(_camera.projectionMatrix,modelMatrix) forUniform:UNIFORM_MODELVIEWPROJECTION_MATRIX];
    
    [_activeShader setMatrix4:modelMatrix forUniform:NKS_UNIFORM_MODELVIEWPROJECTION_MATRIX];
   
}

-(void)pushScale:(V3t)nscale {
    
    [self pushMatrix];
    
    modelMatrix = M16ScaleWithV3(modelMatrix, nscale);
    
    memcpy(matrixStack+matrixCount, modelMatrix.m, sizeof(M16t));
    
    //NSLog(@"push M %lu", matrixCount);
    
    //[_activeShader setMatrix4:modelMatrix forUniform:UNIFORM_MODELVIEWPROJECTION_MATRIX];
    [_activeShader setMatrix4:M16Multiply(_camera.projectionMatrix,modelMatrix) forUniform:NKS_UNIFORM_MODELVIEWPROJECTION_MATRIX];
    
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
    
    //[_activeShader setMatrix4:M16Multiply(_camera.projectionMatrix,modelMatrix) forUniform:UNIFORM_MODELVIEWPROJECTION_MATRIX];
}

-(void)drawHitBuffer {
    
    self.blendMode = NKBlendModeNone;
    glDisable(GL_BLEND);
    
    _activeShader = _hitDetectShader;
    [_activeShader use];
    
    [super drawWithHitShader];

}

-(void)processHitBuffer {
    
    [_hitDetectBuffer bind];
    
    glViewport(0, 0, self.size.width, self.size.height);
    
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    
    [self drawHitBuffer];

    NSArray* queue = [_hitQueue copy];
    
    for (CallBack b in queue) {
        b();
        //NSLog(@"process hit block");
    }
    
    [_hitQueue removeAllObjects];
    
    [_hitDetectBuffer unbind];
    
}

-(void)draw {
        
        [_activeShader use];

        _camera.dirty = true;
        //[_camera begin];
#ifdef DRAW_HIT_BUFFER
        [self drawHitBuffer];
#else
        [super draw];
#endif
        //[_camera end];
    
        [_boundTexture unbind];
        _boundTexture = nil;
        [_boundVertexBuffer unbind];
        _boundVertexBuffer = nil;

}

-(void)setUniformIdentity {
    [self.activeShader setInt:0 forUniform:NKS_UNIFORM_NUM_TEXTURES];
    [self.activeShader setMatrix4:M16IdentityMake() forUniform:NKS_UNIFORM_MODELVIEWPROJECTION_MATRIX];
    [self.activeShader setMatrix3:M9IdentityMake() forUniform:NKS_UNIFORM_NORMAL_MATRIX];
}

-(void)drawAxes {
    
        if (!axes) {
             axes = [NKVertexBuffer axes];
        }
        
//        if (!sphere) {
//            sphere = [NKVertexBuffer sphereWithStacks:20 slices:20 squash:2.];
//        }
        
        [axes bind:^{
            [self pushScale:V3MakeF(_camera.position3d.z)];
            glLineWidth(2.0);
            glDrawArrays(GL_LINES, 0, axes.numberOfElements);
            [self popMatrix];
        }];
        

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
    alert.delegate = self;
    [self addChild:alert];
    
    if (animated) {
      
        [_alertSprite setPosition:P2Make(0, -self.size.height)];
        [_alertSprite runAction:[NKAction moveTo:P2Make(0, 0) duration:.3]];
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
    
    if (!_hitColorMap) {
        _hitColorMap = [[NSMutableDictionary alloc]init];
    }
    
    NKByteColor *color;
    
    while (!color) {
        NKByteColor *test = [NKByteColor colorWithRed:arc4random() % 255 green:arc4random() % 255 blue:arc4random() % 255 alpha:255];
        
        if (![_hitColorMap objectForKey:test]) {
            color = test;
            node.uidColor = test;
            [_hitColorMap setObject:node forKey:node.uidColor];
            //[color log];
        }
    }
    
}

-(void)dispatchTouchRequestForLocation:(P2t)location type:(NKEventType)eventType{
    
    CallBack callBack = ^{
        
        NKByteColor *hc = [[NKByteColor alloc]init];
        glReadPixels(location.x, location.y,
                     1, 1,
                     GL_RGBA, GL_UNSIGNED_BYTE, hc.bytes);
        NKNode *hit = [_hitColorMap objectForKey:hc];
        //[hc log];
        if (!hit){
            hit = self;
        }
        
        [hit handleEventWithType:eventType forLocation:location];
        
        //NSLog(@"%f:%f hit node: %@", location.x, location.y, hit.name);
        switch (eventType) {
            case NKEventTypeBegin:
                [hit touchDown:location id:0];
                break;
                
            case NKEventTypeMove:
                [hit touchMoved:location id:0];
                break;
                
            case NKEventTypeEnd:
                [hit touchUp:location id:0];
                break;
                
            default:
                break;
        }
    };
    
    [_hitQueue addObject:callBack];

}

-(NKTouchState)touchDown:(P2t)location id:(int)touchId {
    
    if (_alertSprite) {
        return [_alertSprite touchDown:location id:touchId];
    }
    else {
        
        //[self dispatchTouchRequestForLocation:location type:NKEventTypeBegin];
        
        return NKTouchIsFirstResponder;
    }
}

//
-(NKTouchState)touchMoved:(P2t)location id:(int)touchId {
    
    if (_alertSprite) {
        return [_alertSprite touchMoved:location id:touchId];
    }
    else {
        
        //[self dispatchTouchRequestForLocation:location type:NKEventTypeMove];
        
        return NKTouchIsFirstResponder;
        
    }
}
//
-(NKTouchState)touchUp:(P2t)location id:(int)touchId {

    if (_alertSprite) {
        return [_alertSprite touchUp:location id:touchId];
    }
    
    [self dispatchTouchRequestForLocation:location type:NKEventTypeEnd];
    
    return false;
}
//
-(void)dealloc {
    if (matrixStack) {
        free(matrixStack);
    }
    
}

@end
