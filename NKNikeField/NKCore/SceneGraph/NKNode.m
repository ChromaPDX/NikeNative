//
//  NKNode.m
//  example-ofxTableView
//
//  Created by Chroma Developer on 2/17/14.
//
//

#import "NodeKitten.h"

@implementation NKNode

#pragma mark - init

-(instancetype)init {
    self = [super init];
    if (self){
        
        self.name = @"NEW NODE";
        
        [self setSize3d:V3Make(1., 1., 1.)];
        [self setScale:1.];
        [self setOrientationEuler:V3Make(0, 0, 0)];
        [self setPosition3d:V3Make(0, 0, 0)];
        
        _upVector = V3Make(0, 1, 0);
        
        _anchorPoint3d = V3Make(.5, .5, .5);
        _hidden = false;
        intAlpha = 1.;
        _alpha = 1.;
        
        _blendMode = NKBlendModeAlpha;
        _cullFace = NKCullFaceFront;
        
        animationHandler = [[NodeAnimationHandler alloc]initWithNode:self];
        
        _userInteractionEnabled = false;
        _useShaderOnSelfOnly = false;
    }
    
    return self;
}

#pragma mark - Node Hierarchy

-(NSArray*)children {
    return intChildren;
}

-(void)setChildren:(NSArray *)children {
    intChildren = [[NSMutableArray alloc] initWithArray:children];
}

- (void)addChild:(NKNode *)child {
    
    
    if (!intChildren) {
        intChildren = [[NSMutableArray alloc]init];
    }
    

    NSMutableArray *temp = [intChildren mutableCopy];
    
    if (![temp containsObject:child]) {
        [temp addObject:child];
        [child setParent:self];
        

    }
    
    intChildren = temp;
    
}

-(NKSceneNode*)scene {

    if (!_scene) { // CACHE POINTER
        
        if ([self isKindOfClass:[NKSceneNode class]]) {
            _scene = (NKSceneNode*) self;
            return (NKSceneNode*) self;
        }
        
        _scene = _parent.scene;
        return _parent.scene;
    }
    
    return _scene;
    
}

- (void)fadeInChild:(NKNode*)child duration:(NSTimeInterval)seconds{
    [self fadeInChild:child duration:seconds withCompletion:nil];
}

- (void)fadeOutChild:(NKNode*)child duration:(NSTimeInterval)seconds{
    [self fadeOutChild:child duration:seconds withCompletion:nil];
}

- (void)fadeInChild:(NKNode*)child duration:(NSTimeInterval)seconds withCompletion:(void (^)())block{
    [self addChild:child];
    
    [child setAlpha:0];
    [child runAction:[NKAction fadeAlphaTo:1. duration:seconds] completion:^{
        if (block){
            block();
        }
    }];
}

- (void)fadeOutChild:(NKNode*)child duration:(NSTimeInterval)seconds withCompletion:(void (^)())block{
    
    [child runAction:[NKAction fadeAlphaTo:0. duration:seconds] completion:^{

        if (block){
            block();
        }
        
        [child removeFromParent];
        
    }];
    
}

-(void)setUserInteractionEnabled:(bool)userInteractionEnabled {
    
    _userInteractionEnabled = userInteractionEnabled;
    
    if (_userInteractionEnabled && _parent) {
        [_parent setUserInteractionEnabled:true];
    }
    
    
}
-(void)setParent:(NKNode *)parent {

    _parent = parent;
    
    if (self.userInteractionEnabled && _parent) {
        [_parent setUserInteractionEnabled:true];
    }
}

-(S2t)size {
    return CGSizeMake(_size3d.x, _size3d.y);
}

-(V3t)size3d {
    return _size3d;
}

-(void)setSize:(S2t)size {
    w = size.width;
    h = size.height;
    _size3d.x = w;
    _size3d.y = h;
}

-(void)setSize3d:(V3t)size3d {
    _size3d = size3d;
    w = _size3d.x;
    h = _size3d.y;
    d = _size3d.z;
}


-(int)numNodes {
    
    int count = 0;
    
    for (NKNode* child in intChildren) {
        count += [child numNodes];
        count++;
    }
    
    return count;
    
}

-(int)numVisibleNodes {
    
    int count = 0;
    
    for (NKNode* child in intChildren) {
        if (!child.isHidden) {
            count += [child numVisibleNodes];
            count++;
        }
    }
    
    return count;
    
}

-(R4t)calculateAccumulatedFrame {
    
    R4t rect = [self getDrawFrame];
    
    for (NKNode* child in intChildren) {
        
        R4t childFrame = [child getDrawFrame];
        
        if (childFrame.x < rect.x) {
            rect.x = childFrame.x;
        }
        
        
        if (childFrame.x + childFrame.w > rect.x + rect.w) {
            rect.w = rect.x + childFrame.x + childFrame.w;
        }
        
        if (childFrame.y < rect.y) {
            rect.y = childFrame.y;
        }
        
        
        if (childFrame.y + childFrame.h > rect.y + rect.h) {
            rect.h = rect.y + childFrame.y + childFrame.h;
        }
        
    }
    
    return rect;
}


- (void)insertChild:(NKNode *)child atIndex:(NSInteger)index{
    if (!intChildren) {
        intChildren = [[NSMutableArray alloc]init];
    }
    [intChildren insertObject:child atIndex:index];
}

- (void)removeChildrenInArray:(NSArray *)nodes{
    NSMutableArray *childMut = [intChildren mutableCopy];
    [childMut removeObjectsInArray:nodes];
    intChildren = childMut;
}

- (void)removeAllChildren{
    [intChildren removeAllObjects];
}

-(void)removeChild:(NKNode *)node {
    [node removeFromParent];
}

-(void)removeChildNamed:(NSString *)name {
    for (NKNode *n in intChildren) {
        if ([n.name isEqualToString:name]) {
            [n removeFromParent];
            return;
        }
    }
}

-(NKNode*)childNodeWithName:(NSString *)name {
    for (NKNode *n in intChildren) {
        if ([n.name isEqualToString:name]) {
            return n;
        }
    }
    return nil;
}

- (void)removeFromParent{
    [_parent removeChildrenInArray:@[self]];
}

+(NKFbo*)customFbo:(CGSize)size {
    
    NKFbo* custom = [[NKFbo alloc]init];
//    
//    NKFbo::Settings settings;
//    settings.width = size.width;
//    settings.height = size.height;
//    settings.internalformat = GL_RGBA;
//    settings.numSamples = 0;
//    settings.useDepth = true;
//    settings.useStencil = true;
//    //settings.depthStencilAsTexture = true;
//    
//    custom->allocate(settings);
    
    return custom;
    
}

#pragma mark - SHADER

-(void)loadShaderNamed:(NSString *)name {
    if (!_shader) {
        _shader = [[NKShaderNode alloc] initWithShaderNamed:name node:self paramBlock:nil];
    }
    
    else {
        [_shader loadShaderNamed:name];
    }
    
    useShader = true;
}

-(void)loadShaderNamed:(NSString*)name paramBlock:(ShaderParamBlock)block{
    if (!_shader) {
        _shader = [[NKShaderNode alloc] initWithShaderNamed:name node:self paramBlock:block];
    }
    
    useShader = true;
}

-(void)loadShader:(NKShaderNode*)shader {
    if (!_shader) {
        _shader = shader;
    }
    
    useShader = true;
}

#pragma mark - Actions

-(int)hasActions {
    return [animationHandler hasActions];
}

- (void)runAction:(NKAction*)action {
    [animationHandler runAction:action];
}

-(void)repeatAction:(NKAction*)action {
    [animationHandler runAction:[NKAction repeatActionForever:action]];
}

- (void)runAction:(NKAction *)action completion:(void (^)())block {
    [animationHandler runAction:action completion:block];
}

#pragma mark - UPDATE / DRAW

- (void)updateWithTimeSinceLast:(F1t) dt {
    // IF OVERRIDE, CALL SUPER
    
    [animationHandler updateWithTimeSinceLast:dt];
    
    for (NKNode *child in intChildren) {
        [child updateWithTimeSinceLast:dt];
    }
}



-(void)drawToDepthBuffer {
    
//    if (!_depthFbo){
//        _depthFbo = [NKNode customFbo:self.size];
//        
//    }
//    if (!depthShader){
//        NSLog(@"init drawDepth shader");
//        depthShader = [[NKDrawDepthShader alloc] initWithNode:self paramBlock:nil];
//    }
//    
//     [_scene.camera end];
//    
// //   _depthFbo->begin();
//    
//    ofClear(0,0,0,255);
//    glPushMatrix();
//    ofTranslate(_depthFbo->getWidth()*.5, _depthFbo->getHeight()*.5);
//    
//    [_scene.camera begin];
//    //_scene.camera.node->transformGL();
//    
//    [depthShader begin];
//
//    [self customDraw];
//    
//    for (NKNode *child in intChildren) {
//        if (!child.isHidden) {
//            [child draw];
//        }
//    }
//    
//    [depthShader end];
//    
//
//    
//   // _scene.camera.node->restoreTransformGL();
//    
//    
//    [_scene.camera end];
//    
//    glPopMatrix();
//    
// //   _depthFbo->end();
//    
//    [_scene.camera begin];
    
    
}

-(void)pushStyle{
    
    // CULL
    
    if (_cullFace != self.scene.cullFace) {
        
        switch (_cullFace) {
                
            case NKCullFaceNone:
                glDisable(GL_CULL_FACE);
                break;
                
            case NKCullFaceFront:
                if (_scene.cullFace == NKCullFaceNone) {
                    glEnable(GL_CULL_FACE);
                }
                glCullFace(GL_FRONT);
                break;
                
            case NKCullFaceBack:
                if (_scene.cullFace == NKCullFaceNone) {
                    glEnable(GL_CULL_FACE);
                }
                glCullFace(GL_BACK);
                break;
                
            case NKCullFaceBoth:
                if (_scene.cullFace == NKCullFaceNone) {
                    glEnable(GL_CULL_FACE);
                }
                glCullFace(GL_FRONT_AND_BACK);
                break;
                
            default:
                break;
        }
        
      
        _scene.cullFace = _cullFace;
        
    }
    
    // SMOOTHING
    
    // BLEND MODE
    
    if (_blendMode != self.scene.blendMode) {

        switch (_blendMode){
            case NKBlendModeNone:
                glDisable(GL_BLEND);
                break;
                
            case NKBlendModeAlpha:{
                glEnable(GL_BLEND);
//#ifndef TARGET_OPENGLES
//				glBlendEquation(GL_FUNC_ADD);
//#endif
                glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                break;
            }
                
            case NKBlendModeAdd:{
                glEnable(GL_BLEND);
//#ifndef TARGET_OPENGLES
//				glBlendEquation(GL_FUNC_ADD);
//#endif
                glBlendFunc(GL_SRC_ALPHA, GL_ONE);
                break;
            }
                
            case NKBlendModeMultiply:{
                glEnable(GL_BLEND);
//#ifndef TARGET_OPENGLES
//				glBlendEquation(GL_FUNC_ADD);
//#endif
                glBlendFunc(GL_DST_COLOR, GL_ONE_MINUS_SRC_ALPHA /* GL_ZERO or GL_ONE_MINUS_SRC_ALPHA */);
                break;
            }
                
            case NKBlendModeScreen:{
                glEnable(GL_BLEND);
//#ifndef TARGET_OPENGLES
//				glBlendEquation(GL_FUNC_ADD);
//#endif
                glBlendFunc(GL_ONE_MINUS_DST_COLOR, GL_ONE);
                break;
            }
                
            case NKBlendModeSubtract:{
                glEnable(GL_BLEND);
//#ifndef TARGET_OPENGLES
//                glBlendEquation(GL_FUNC_REVERSE_SUBTRACT);
//#else
//                NSLog(@"OF_BLENDMODE_SUBTRACT not currently supported on OpenGL ES");
//#endif
                glBlendFunc(GL_SRC_ALPHA, GL_ONE);
                break;
            }
                
            default:
                break;
        }
        
        _scene.blendMode = _blendMode;
    }
}



-(void)begin {
    glPushMatrix();
    nkMultMatrix(localTransformMatrix);
    
    if (_shader.needsDepthBuffer) {
        [self drawToDepthBuffer];
    }
    
    if(useShader) {
        [_shader begin];
    }
}

-(void)draw {
    [self begin];

    [self pushStyle];
    
    [self customDraw];
    
    if(useShader) {
        if (_useShaderOnSelfOnly){
            [_shader end];
        }
    }
    
    for (NKNode *child in intChildren) {
        if (!child.isHidden) {
            [child draw];
        }
    }
    
    if(useShader) {
        if (!_useShaderOnSelfOnly){
            [_shader end];
        }
    }

    [self end];
}

-(void)customDraw {
    // OVERRIDE IN SUB CLASS
}

-(void)end {
    
    glPopMatrix();
}

+(void)drawRectangle:(CGSize)size {
    
    NKMeshNode *node = [[NKStaticDraw meshesCache]objectForKey:[NKStaticDraw stringForPrimitive:NKPrimitiveRect]];
    
    if (!node) {
        node = [[NKMeshNode alloc] initWithPrimitive:NKPrimitiveRect texture:nil color:NKWHITE size:V3Make(size.width, size.height, 0)];
    }
    
    glPushMatrix();
    glScalef(size.width, size.height, 0);
    [node customDraw];
    glPopMatrix();
    
}

#pragma mark - GEOMETRY

-(bool)containsPoint:(CGPoint)location {
    
    CGPoint p = location;
    
    //NSLog(@"world coords: %f %f %f", p.x, p.y, p.z);
    
    R4t r = [self getWorldFrame];
    
    //bool withinArea = false;
    if ( p.x > r.x && p.x < r.x + r.w && p.y > r.y && p.y < r.y + r.h)
    {
       // [self logCoords];
        return true;
    }
    return false;
    
}

-(V3t)getGlobalPosition{
    return V3GetM16Translation([self getGlobalTransformMatrix]);
}

-(R4t)getWorldFrame{
    V3t g = [self getGlobalPosition];
    return R4Make(g.x - _size3d.x * _anchorPoint3d.x, g.y - _size3d.y *_anchorPoint3d.y, _size3d.x, _size3d.y);

}


-(R4t)getDrawFrame {
    //[self logCoords];
    //V3t g = node->getPosition();
    //return R4Make(g.x - _size.width * _anchorPoint.x, g.y - _size.height *_anchorPoint.y, _size.width, _size.height);
    return R4Make(-_size3d.x * _anchorPoint3d.x, -_size3d.y *_anchorPoint3d.y, _size3d.x, _size3d.y);
}


-(void)logPosition {
    V3t p = [self getGlobalPosition];
    NSLog(@"name:%@ global coords %f, %f, %f :: position %f %f %f",self.name, p.x, p.y, p.z,position.x, position.y, position.z);
}
-(void)logCoords{
    V3t p = [self getGlobalPosition];
    NSLog(@"%@ coords %f, %f, %f :: size %f %f",self.name, p.x, p.y, p.z, w, h);
}

-(void)logMatrix:(M16t)M16 {
    NSLog(@"MATRIX for %@ \n %f %f %f %f \n %f %f %f %f \n %f %f %f %f \n %f %f %f %f",self.name,
            M16.m00, M16.m01, M16.m02, M16.m03,
            M16.m10, M16.m11, M16.m12, M16.m13,
            M16.m20, M16.m21, M16.m22, M16.m23,
            M16.m30, M16.m31, M16.m32, M16.m33);
}

-(bool)shouldCull {
    return 0;
}

-(CGPoint)childLocationIncludingRotation:(NKNode*)child {
    
    CGPoint polar = carToPol(child.position);
    polar.y += self.zRotation;
    
    //NSLog(@"zRotation: %f", self.zRotation);
    return polToCar(polar);
    
}

#pragma mark - MATH



#pragma mark - PROPERTIES

#pragma mark - MATRIX

-(void) setTransformMatrix:(const M16t) m44 {
	localTransformMatrix = m44;
    
    orientation = Q4GetM16Rotate(localTransformMatrix);
    position = V3GetM16Translation(localTransformMatrix);
    scale = V3GetM16Scale(localTransformMatrix);
    
	//Q4t so;
   // M16Decompose(m44, position, orientation, scale, so);
    
}

-(M16t)tranformMatrixInNode:(NKNode*)n{
    
    if (_parent == n || !_parent) {
        return localTransformMatrix;
    }
    else {
        // recursive add
        return M16Multiply([_parent tranformMatrixInNode:n],localTransformMatrix);
    }
    
}

-(M16t)getGlobalTransformMatrix {
    
    if (!_parent) {
        return localTransformMatrix;
    }
    else {
        // recursive add
        return M16Multiply([_parent getGlobalTransformMatrix],localTransformMatrix);
    }
    
}

#pragma mark - POSITION

// BASE, all should refer to this:

-(V3t)position3d {
    return position;
}

-(void)setPosition3d:(V3t)position3d {
    position = position3d;
    M16SetV3Translation(&localTransformMatrix, position3d);
}

// convenience >>

-(void)setZPosition:(int)zPosition {
    [self setPosition3d:V3Make(position.x,position.y, zPosition)];
}

-(void) setGlobalPosition:(const V3t)p {
	if(_parent == NULL) {
		[self setPosition3d:p];
	} else {
        [self setPosition3d:
         V3MultiplyM16(M16InvertColumnMajor([_parent getGlobalTransformMatrix], 0), p)];
	}
}

-(void)setPosition:(CGPoint)p {
    [self setPosition3d:V3Make(p.x, p.y, position.z)];
}

-(CGPoint)position {
    return CGPointMake(position.x, position.y);
}

-(CGPoint)positionInNode:(NKNode *)n {
//    V3t p = self.node->getGlobalPosition() - n.node->getGlobalPosition();
//
    V3t p = [self convertPoint3d:V3Make(0,0,0) toNode:n];
    return CGPointMake(p.x, p.y);
}

-(V3t)positionInNode3d:(NKNode *)n {
    return V3GetM16Translation([self tranformMatrixInNode:n]);
}

#pragma mark - ANCHOR

-(void)setAnchorPoint:(CGPoint)anchorPoint {
    _anchorPoint3d.x = anchorPoint.x;
    _anchorPoint3d.y = anchorPoint.y;
}

-(CGPoint)anchorPoint {
    return CGPointMake(_anchorPoint3d.x, _anchorPoint3d.y);
}

#pragma mark - Orientation

-(M16t)localTransformMatrix {
    return localTransformMatrix;
}

-(void) createMatrix {
	//if(isMatrixDirty) {
	//	isMatrixDirty = false;
 
    // Make identity, scale it, rotate it
    localTransformMatrix = M16Multiply(M16MakeScale(scale), M16MakeRotate(orientation));
    // Set Translation
    M16SetV3Translation(&(localTransformMatrix), position);
    
//	if(scale[0]>0) axis[0] = localTransformMatrix.getRowAsVec3f(0)/scale[0];
//	if(scale[1]>0) axis[1] = localTransformMatrix.getRowAsVec3f(1)/scale[1];
//	if(scale[2]>0) axis[2] = localTransformMatrix.getRowAsVec3f(2)/scale[2];
    
   // [self logMatrix:localTransformMatrix];
}

//----------------------------------------
-(void) setOrientation:(const Q4t)q {
	orientation = q;
	[self createMatrix];
}

//----------------------------------------
-(void) setOrientationEuler:(const V3t)eulerAngles {
    [self setOrientation:Q4FromV3(eulerAngles)];
    //[self rotateMatrix:M16MakeEuler(eulerAngles)];
}

-(void) setGlobalOrientation:(const Q4t) q {
	if(!_parent) {
		[self setOrientation:q];
	} else {
		M16t invParent = M16InvertColumnMajor(([_parent getGlobalTransformMatrix]), 0);
       [self setOrientation:Q4MultiplyM16(invParent,q)];
	}
}

-(Q4t) orientation{
	return orientation;
}

-(Q4t)getGlobalOrientation {
    return Q4GetM16Rotate([self getGlobalTransformMatrix]);
}

-(V3t) getOrientationEuler {
    return V3FromQ4(orientation);
}

-(void)setZRotation:(F1t)rotation {

    Q4t zRot = Q4FromAngleAndV3(rotation, V3Make(0,0,1));
    [self setOrientation:zRot];
    
}

/*
//----------------------------------------
void ofNode::orbit(float longitude, float latitude, float radius, const ofVec3f& centerPoint) {
	M16t m;
    
	// find position
	V3t p(0, 0, radius);
	p.rotate(ofClamp(latitude, -89, 89), V3Make(1, 0, 0));
	p.rotate(longitude, V3Make(0, 1, 0));
	p += centerPoint;
	setPosition(p);
	
	lookAt(centerPoint);//, v - centerPoint);
}

//----------------------------------------
void ofNode::orbit(float longitude, float latitude, float radius, ofNode& centerNode) {
	orbit(longitude, latitude, radius, centerNode.getGlobalPosition());
}

//----------------------------------------
void ofNode::resetTransform() {
	setPosition(V3Make());
	setOrientation(V3Make());
}
 

 void ofNode::lookAt(const ofNode& lookAtNode, const ofVec3f& upVector) {
 lookAt(lookAtNode.getGlobalPosition(), upVector);
 }
 
*/

-(void)rotateMatrix:(M16t)M16 {
    M16t m = M16MakeScale(scale);
    localTransformMatrix = M16Multiply(m,M16);
    M16SetV3Translation(&localTransformMatrix, position);
}

-(void)globalRotateMatrix:(M16t)M16 {
    M16t m = M16MakeScale(scale);
    M16SetV3Translation(&m, position);
    m = M16Multiply(m, M16);
    localTransformMatrix = M16Multiply(m, M16InvertColumnMajor([_parent getGlobalTransformMatrix], 0));
}

-(void)lookAtNode:(NKNode*)node {
    V3t them = [node getGlobalPosition];
    
    NSLog(@"look at: %f %f %f,", them.x,them.y,them.z);
    //Q4t newRotation = Q4FromMatrix([self getLookMatrix:[node getGlobalPosition]]);
    
    //NSLog(@"look at: %f %f %f, %f", newRotation.x, newRotation.y,newRotation.z,newRotation.w);
    M16t new = [self getLookMatrix:[node getGlobalPosition]];
    
    //            [self logMatrix:new];
    [self rotateMatrix:new];
}

-(M16t)getLookMatrix:(V3t)lookAtPosition {
    V3t forward = V3Normalize(V3Subtract(lookAtPosition,[self getGlobalPosition]));

    if (V3Length(forward)> 0.) {
        V3t side = V3Normalize(V3CrossProduct(forward,[self upVector]));
        V3t up = V3CrossProduct(forward,side);
        
        M16t m = M16IdentityMake();
        
        m.m00 = side.x;
        m.m01 = side.y;
        m.m02 = side.z;
        m.m10 = up.x;
        m.m11 = up.y;
        m.m12 = up.z;
        m.m20 = -forward.x;
        m.m21 = -forward.y;
        m.m22 = -forward.z;

        //[self logMatrix:m];
        
        return m;
    }
    return M16IdentityMake();
}

-(V3t)upVector {
    if (!_parent){
        return _upVector;
    }
    return V3MultiplyM16([_parent getGlobalTransformMatrix], _upVector);
}

#pragma mark - SCALE


-(void)setScale:(CGFloat)s {
    [self setScale3d:V3Make(s,s,s)];
}

- (void)setXScale:(CGFloat)s {
    V3t nScale = scale;
    nScale.x = s;
    [self setScale3d:nScale];
}

- (void)setYScale:(CGFloat)s {
    V3t nScale = scale;
    nScale.y = s;
 [self setScale3d:nScale];
}

-(void)setScale3d:(V3t)s{
    scale = s;
	[self createMatrix];
}

-(V3t)scale3d {
    return scale;
}

-(CGPoint)scale {
    return CGPointMake(scale.x, scale.y);
}

#pragma mark - ALPHA / BLEND

-(void)setAlpha:(F1t)alpha {
    intAlpha = alpha;
    [self setRecursiveAlpha];
}

-(void)setRecursiveAlpha {
    _alpha = [self recursiveParentAlpha];
    
    for (NKNode* n in intChildren) {
        [n setRecursiveAlpha];
    }
}

-(F1t)recursiveParentAlpha{
    if (!_parent) {
        return intAlpha;
    }
    else {
        return intAlpha * [_parent recursiveParentAlpha];
    }
}

#pragma mark - ACTIONS

-(void)removeAllActions {
        [animationHandler removeAllActions];
}

#pragma mark - TOUCH
-(NKTouchState)touchDown:(CGPoint)location id:(int)touchId {
    // OVERRIDE, CALL SUPER
    
    NKTouchState hit = NKTouchNone;

    if (_userInteractionEnabled){
        
        if ([self containsPoint:location]) {
            hit = NKTouchIsFirstResponder;
        }
        
        for (int i = intChildren.count-1; i >= 0; i--){
            if ([intChildren[i] touchDown:location id:touchId] > 0) {
                return NKTouchContainsFirstResponder;
            }
        }
        
        if (hit == NKTouchIsFirstResponder){
               NSLog(@"touch down %@ %f, %f",self.name, location.x, location.y);
        }
    }
    
    return hit;
}

-(NKTouchState)touchMoved:(CGPoint)location id:(int)touchId {
    // OVERRIDE, CALL SUPER
    
    NKTouchState hit = NKTouchNone;
    
    if (_userInteractionEnabled){
        
        if ([self containsPoint:location]) {
            hit = NKTouchIsFirstResponder;
        }
        
        for (int i = intChildren.count-1; i >= 0; i--){
            if ([intChildren[i] touchMoved:location id:touchId] > 0) {
                return NKTouchContainsFirstResponder;
            }
        }
        
    }
    
    return hit;
}

-(NKTouchState)touchUp:(CGPoint)location id:(int)touchId {
    // OVERRIDE, CALL SUPER
    
    NKTouchState hit = NKTouchNone;
    
    if (_userInteractionEnabled){
        
        if ([self containsPoint:location]) {
            hit = NKTouchIsFirstResponder;
        }
        
        for (int i = intChildren.count-1; i >= 0; i--){
            if ([intChildren[i] touchUp:location id:touchId] > 0) {
                return NKTouchContainsFirstResponder;
            }
        }
        
    }
    
    if (hit >= NKTouchIsFirstResponder){
        NSLog(@"touch up %@ %f, %f", self.name, location.x, location.y);
    }
    
    return hit;
}



#pragma mark - DEALLOC C++ Objectes

-(void)dealloc {
    [animationHandler removeAllActions];
    animationHandler = NULL;
}

@end
