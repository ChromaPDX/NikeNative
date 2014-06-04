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
    
    self = [super initWithSize:V3Make(size.x, size.y, 1.)];
    
    if (self){
        
#ifdef NK_GL_DEBUG
        
        // Obtain iOS version
		int OSVersion_ = 0;
#if TARGET_OS_IPHONE
		NSString *OSVer = [[UIDevice currentDevice] systemVersion];
#else
        SInt32 versionMajor, versionMinor, versionBugFix;
        Gestalt(gestaltSystemVersionMajor, &versionMajor);
        Gestalt(gestaltSystemVersionMinor, &versionMinor);
        Gestalt(gestaltSystemVersionBugFix, &versionBugFix);
        
        NSString *OSVer = [NSString stringWithFormat:@"%d.%d.%d", versionMajor, versionMinor, versionBugFix];
#endif
        
		NSArray *arr = [OSVer componentsSeparatedByString:@"."];
		int idx = 0x01000000;
		for( NSString *str in arr ) {
			int value = [str intValue];
			OSVersion_ += value * idx;
			idx = idx >> 8;
		}
        
        NSLog(@"OS version: %@ (0x%08x)", OSVer, OSVersion_);
        
		 NSLog(@"GL_VENDOR:   %s", glGetString(GL_VENDOR) );
		 NSLog(@"GL_RENDERER: %s", glGetString ( GL_RENDERER   ) );
		 NSLog(@"GL_VERSION:  %s", glGetString ( GL_VERSION    ) );
        
		char* glExtensions = (char*)glGetString(GL_EXTENSIONS);
        
        NSLog(@"GL EXT: %@",[NSString stringWithCString:glExtensions encoding: NSASCIIStringEncoding]);

#endif
        self.name = @"SCENE";
        
        self.backgroundColor = [NKByteColor colorWithRed:50 green:50 blue:50 alpha:255];
        self.shouldRasterize = false;
        self.userInteractionEnabled = true;
        
        _hitQueue = [NSMutableArray array];
        _lights = [NSMutableArray array];
        
        self.blendMode = NKBlendModeNone;
        self.cullFace = NKCullFaceNone;
        
        _camera = [[NKCamera alloc]initWithScene:self];
        
        self.scene = self;
        
        _stack = [[NKMatrixStack alloc]init];
        
        _hitDetectBuffer = [[NKFrameBuffer alloc] initWithWidth:self.size.width height:self.size.height];
            
        _hitDetectShader = [NKShaderProgram newShaderNamed:@"hitShaderSingle" colorMode:NKS_COLOR_MODE_UNIFORM numTextures:0 lightNodes:nil withBatchSize:0];
        
        NSLog(@"init scene with size, %f %f", size.width, size.height);
        
    }
    
    return self;
}

-(void)updateWithTimeSinceLast:(F1t)dt {
    _camera.dirty = true;
    
    fps = (int)(1000./dt);
    
    [NKSoundManager updateWithTimeSinceLast:dt];
    
    [[NKBulletWorld sharedInstance] updateWithTimeSinceLast:dt];
    //[_world updateWithTimeSinceLast:dt];
    
    [_camera updateWithTimeSinceLast:dt];
    
    [super updateWithTimeSinceLast:dt];
    
    
    
//    for (NKLightNode* light in _lights) {
//        [light updateWithTimeSinceLast:dt];
//    }
    
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
    
    for (CallBack b in _hitQueue) {
        b();
    }
    
    [_hitQueue removeAllObjects];
    
    [_hitDetectBuffer unbind];
    
}

-(void)setActiveShader:(NKShaderProgram *)activeShader {
 
    if (!activeShader) {
        _activeShader = activeShader;
        glUseProgram(0);
    }
    
    else if (![_activeShader isEqual:activeShader]) {
        
        _activeShader = activeShader;
        [_activeShader use];
        
        // prep globals
        
        if ([_activeShader uniformNamed:NKS_LIGHT]){
            [[_activeShader uniformNamed:NKS_LIGHT] bindLightProperties:[(NKLightNode*)_lights[0] pointer] count:1];
        }
        
        if ([_activeShader uniformNamed:NKS_V3_EYE_DIRECTION]){
            [[_activeShader uniformNamed:NKS_V3_EYE_DIRECTION] bindV3:self.scene.camera.eyeDirection];
        }
       
    }
    
}

//-(M16t)getGlobalTransformMatrix {
//    return M16IdentityMake();
//}

-(void)begin {
    //[_camera begin];
    [super begin];
}

-(void)end {
    //[_camera end];
    [super end];
}

-(void)draw {


#ifdef DRAW_HIT_BUFFER
    
        [self drawHitBuffer];
#else
        [super draw];
#endif
        _activeShader = nil;
        glUseProgram(0);
        [_boundTexture unbind];
        _boundTexture = nil;
        [_boundVertexBuffer unbind];
        _boundVertexBuffer = nil;

}

-(void)setUniformIdentity {
    NKS_SCALAR s;
    
    s.I1[0] = 0;
    [[self.activeShader uniformNamed:NKS_INT_NUM_TEXTURES] pushValue:s];
    
   // [self.activeShader setInt:0 forUniform:[nksf:@"u_%@",nks(NKS_INT_NUM_TEXTURES)]];
    
    s.M16 = M16IdentityMake();
    [[self.activeShader uniformNamed:NKS_INT_NUM_TEXTURES] pushValue:s];
    
    //[self.activeShader setMatrix4:M16IdentityMake() forUniform:[nksf:@"u_%@",nks(NKS_M16_MVP)]];
    //[self.activeShader setMatrix3:M9IdentityMake() forUniform:[nksf:@"u_%@",nks(NKS_M9_NORMAL)]];
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

-(void)pushMultiplyMatrix:(M16t)matrix {
    [_stack pushMultiplyMatrix:matrix];
}

-(void)pushScale:(V3t)scale {
    [_stack pushScale:scale];
}

-(void)popMatrix {
    [_stack popMatrix];
}

-(void)keyPressed:(NSUInteger)key {

    NSLog(@"key down %d", key);
    
    V3t p = position;
    
    switch (key) {
            
        case 123:
            
            [self setPosition3d:V3Make(p.x-1, p.y, p.z)];
            break;
        case 124:
            
            [self setPosition3d:V3Make(p.x+1, p.y, p.z)];
            break;
            
        case 126: //up arrow
        
            [self setPosition3d:V3Make(p.x, p.y, p.z+1)];
            break;
            
        case 125: // down arrow
            [self setPosition3d:V3Make(p.x, p.y, p.z-1)];
            break;
            
        default:
            break;
    }
}
-(void)dispatchTouchRequestForLocation:(P2t)location type:(NKEventType)eventType{
    
    CallBack callBack = ^{
        NKByteColor *hc = [[NKByteColor alloc]init];
        glReadPixels(location.x, location.y,
                     1, 1,
                     GL_RGBA, GL_UNSIGNED_BYTE, hc.bytes);
        NKNode *hit = [NKShaderManager nodeForColor:hc];

        if (!hit){
            hit = self;
        }
        
        [hit handleEventWithType:eventType forLocation:location];

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
    
    //[self dispatchTouchRequestForLocation:location type:NKEventTypeEnd];
    
    return false;
}

@end

@implementation NKMatrixStack

-(instancetype)init {
    self = [super init];
    if (self) {
        matrixStack = malloc(sizeof(M16t)*NK_BATCH_SIZE);
        matrixBlockSize = NK_BATCH_SIZE;
        matrixCount = 0;
        
        //memcpy(matrixStack+matrixCount, _currentMatrix.m, sizeof(M16t));
    }
    
    return self;
}

-(M16t*)data {
    return matrixStack;
}

-(void)pushMatrix{
   
    if (matrixBlockSize <= matrixCount) {
        NSLog(@"Expanding MATRIX STACK allocation size");
        M16t* copyBlock = malloc(sizeof(M16t) * (matrixCount*2));
        memcpy(copyBlock, matrixStack, sizeof(M16t) * (matrixCount));
        free(matrixStack);
        matrixStack = copyBlock;
        matrixBlockSize = matrixCount * 2;
    }
     matrixCount++;
}

-(void)pushMultiplyMatrix:(M16t)matrix {
    if (matrixCount > 0) {
         *(matrixStack+matrixCount) = M16Multiply(*(matrixStack+matrixCount-1), matrix);
    }
    else {
        *(matrixStack+matrixCount) = matrix;
    }
    
    //memcpy(matrixStack+matrixCount, _currentMatrix.m, sizeof(M16t));
    [self pushMatrix];
}

-(void)pushMatrix:(M16t)matrix {
    *(matrixStack+matrixCount) = matrix;
    //memcpy(matrixStack+matrixCount, matrix.m, sizeof(M16t));
    [self pushMatrix];
}

-(void)pushScale:(V3t)nscale {
    //_currentMatrix = M16ScaleWithV3(_currentMatrix, nscale);
    if (matrixCount > 0) {
    *(matrixStack+matrixCount) = M16ScaleWithV3(*(matrixStack+matrixCount-1), nscale);
    }
    //memcpy(matrixStack+matrixCount, _currentMatrix.m, sizeof(M16t));
    [self pushMatrix];
}

-(M16t)currentMatrix {
    return *(matrixStack+matrixCount-1);
}

-(void)popMatrix {
    if (matrixCount > 0) {
        matrixCount--;
        //_currentMatrix = *(matrixStack+matrixCount-1);
        //memcpy(_currentMatrix.m, matrixStack+matrixCount, sizeof(M16t));
        //NSLog(@"pop M %lu", matrixCount);
    }
    // else _currentMatrix = M16IdentityMake();
    else {
        NSLog(@"MATRIX STACK UNDERFLOW");
    }
    
    //[_activeShader setMatrix4:modelMatrix forUniform:UNIFORM_MODELVIEWPROJECTION_MATRIX];
    
    //[_activeShader setMatrix4:M16Multiply(_camera.projectionMatrix,modelMatrix) forUniform:UNIFORM_MODELVIEWPROJECTION_MATRIX];
}

-(void)reset {
    matrixCount = 0;
}

-(void)dealloc {
    if (matrixStack) {
        free(matrixStack);
    }
}

@end

@implementation NKM9Stack

-(instancetype)init {
    self = [super init];
    if (self) {
        matrixStack = malloc(sizeof(M9t)*NK_BATCH_SIZE);
        matrixBlockSize = NK_BATCH_SIZE;
        matrixCount = 0;
    }
    
    return self;
}

-(M9t*)data {
    return matrixStack;
}

-(void)pushMatrix{
    matrixCount++;
    
    if (matrixBlockSize <= matrixCount) {
        NSLog(@"Expanding MATRIX STACK allocation size");
        M9t* copyBlock = malloc(sizeof(M9t) * (matrixCount*2));
        memcpy(copyBlock, matrixStack, sizeof(M9t) * (matrixCount));
        free(matrixStack);
        matrixStack = copyBlock;
        matrixBlockSize = matrixCount * 2;
    }
}

-(void)pushMatrix:(M9t)matrix {
    memcpy(matrixStack+matrixCount, matrix.m, sizeof(M9t));
     [self pushMatrix];
}

-(void)reset {
    matrixCount = 0;
}

-(void)dealloc {
    if (matrixStack) {
        free(matrixStack);
    }
}

@end

@implementation NKVector4Stack

-(instancetype)init {
    self = [super init];
    if (self) {
        vectorStack = malloc(sizeof(V4t)*NK_BATCH_SIZE);
        vectorBlockSize = NK_BATCH_SIZE;
        vectorCount = 0;
    }
    
    return self;
}

-(V4t*)data {
    return vectorStack;
}

-(void)pushVector{
    if (vectorBlockSize <= vectorCount) {
        NSLog(@"Expanding MATRIX STACK allocation size");
        V4t* copyBlock = malloc(sizeof(V4t) * (vectorCount*2));
        memcpy(copyBlock, vectorStack, sizeof(V4t) * (vectorCount));
        free(vectorStack);
        vectorStack = copyBlock;
        vectorBlockSize = vectorCount * 2;
    }
    vectorCount++;
}

-(void)pushVector:(V4t)vector {
    memcpy(vectorStack+vectorCount, vector.v, sizeof(V4t));
     [self pushVector];
}

-(void)reset {
    vectorCount = 0;
}

-(void)dealloc {
    if (vectorStack) {
        free(vectorStack);
    }
}

@end
