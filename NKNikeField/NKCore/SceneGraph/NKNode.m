//
//  NKNode.m
//  example-ofxTableView
//
//  Created by Chroma Developer on 2/17/14.
//
//

#import "NodeKitten.h"

@implementation NKNode

#define TEST_IGNORE 1
#pragma mark - init

-(instancetype)init {
    return [self initWithSize:V3Make(1., 1., 1.)];
}

-(instancetype)initWithSize:(V3t)size {
    self = [super init];
    
    if (self){
        
        self.name = @"NEW NODE";
        
        [self setSize3d:size];
        [self setScale:1.];
        [self setOrientationEuler:V3Make(0, 0, 0)];
        [self setPosition3d:V3Make(0, 0, 0)];
        
        _upVector = V3Make(0, 1, 0);
        
        _hidden = false;
        intAlpha = 1.;
        _alpha = 1.;
        
        _blendMode = NKBlendModeAlpha;
        _cullFace = NKCullFaceFront;
        
        _userInteractionEnabled = false;
        
    }
    
    return self;
}

//-(instancetype)initWithSize:(V3t)size {
//    
//    self = [super init];
//    
//    if (self) {
//        _size3d = size;
//    }
//    
//    return self;
//}

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
        
        if (_parent) {
            _scene = _parent.scene;
            return _parent.scene;
        }
        
        if ([self isKindOfClass:[NKSceneNode class]]) {
            _scene = (NKSceneNode*) self;
            return (NKSceneNode*) self;
        }
        
        return nil;
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
        if (!_uidColor) {
            [NKShaderManager newUIDColorForNode:self];
        }
        [_parent setUserInteractionEnabled:true];
    }
    
}


-(void)setParent:(NKNode *)parent {
    
    if (_parent) {
        V3t p = self.getGlobalPosition;
        //NKLogV3(@"global position", p);
        [_parent removeChild:self];
        _parent = parent;
        [self setGlobalPosition:p];
    }
    else {
        _parent = parent;
    }
    
    self.scene;
    
    if (self.userInteractionEnabled && _parent) {
        if (!_uidColor) {
            [NKShaderManager newUIDColorForNode:self];
        }
        [_parent setUserInteractionEnabled:true];
    }
}

-(S2t)size {
    return S2Make(_size3d.x, _size3d.y);
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
        
        
        if (childFrame.x + childFrame.size.width > rect.x + rect.size.width) {
            rect.size.width = rect.x + childFrame.x + childFrame.size.width;
        }
        
        if (childFrame.y < rect.y) {
            rect.y = childFrame.y;
        }
        
        
        if (childFrame.y + childFrame.size.height > rect.y + rect.size.height) {
            rect.size.height = rect.y + childFrame.y + childFrame.size.height;
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

-(NKNode*)randomChild {
    if (!intChildren.count) {
        return self;
    }
    return intChildren[arc4random() % intChildren.count];
}

-(NKNode*)randomLeaf {
    
    if (intChildren.count) {
        return [[self randomChild] randomLeaf];
    }
    
    return self;
    
}

- (void)removeFromParent{
    [_parent removeChildrenInArray:@[self]];
}

#pragma mark - Actions

-(int)hasActions {
    return [animationHandler hasActions];
}

- (void)runAction:(NKAction*)action {
    if (!animationHandler) {
        animationHandler = [[NodeAnimationHandler alloc]initWithNode:self];
    }
    [animationHandler runAction:action];
}

-(void)repeatAction:(NKAction*)action {
    if (!animationHandler) {
        animationHandler = [[NodeAnimationHandler alloc]initWithNode:self];
    }
    [animationHandler runAction:[NKAction repeatActionForever:action]];
}

- (void)runAction:(NKAction *)action completion:(void (^)())block {
    if (!animationHandler) {
        animationHandler = [[NodeAnimationHandler alloc]initWithNode:self];
    }
    [animationHandler runAction:action completion:block];
}

#pragma mark - UPDATE / DRAW

- (void)updateWithTimeSinceLast:(F1t) dt {
    // IF OVERRIDE, CALL SUPER
    
    if (_body){
        [_body getPhysicsMatrix:&localTransformMatrix];
    }
    
    [animationHandler updateWithTimeSinceLast:dt];
    
    for (NKNode *child in intChildren) {
        [child updateWithTimeSinceLast:dt];
    }
    
    _dirty = false;
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
    //return;
    // CULL
    
    if (self.scene.cullFace != _cullFace) {
        
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
        
        
        self.scene.scene.cullFace = _cullFace;
        
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
    
    [self.scene pushMultiplyMatrix:localTransformMatrix];
    
}

-(void)draw {
    [self begin];
    
    [self pushStyle];
    
    [self customDraw];
    
    for (NKNode *child in intChildren) {
        [child draw];
    }
    
    [self end];
}

-(void)drawWithHitShader {
    
    [self begin];
    
    if (_userInteractionEnabled) {
         [self customdrawWithHitShader];
    }
    
    for (NKNode *child in intChildren) {
        [child drawWithHitShader];
    }
    
    [self end];
}

-(void)customDraw {
    // OVERRIDE IN SUB CLASS
}

-(void)customdrawWithHitShader {
    // OVERRIDE IN SUB CLASS
}

-(void)end {
    [self.scene popMatrix];
}

//+(void)drawRectangle:(S2t)size {
//
//    NKMeshNode *node = [[NKStaticDraw meshesCache]objectForKey:[NKStaticDraw stringForPrimitive:NKPrimitiveRect]];
//
//    if (!node) {
//        node = [[NKMeshNode alloc] initWithPrimitive:NKPrimitiveRect texture:nil color:NKWHITE size:V3Make(size.width, size.height, 0)];
//    }
//
//    if (NK_GL_VERSION == 2) {
//        [node customDraw];
//    }
//    else {
//
//        glPushMatrix();
//        glScalef(size.width, size.height, 0);
//        [node customDraw];
//        glPopMatrix();
//
//    }
//
//}

#pragma mark - GEOMETRY

// this sucks, needs work
//-(P2t)transformedPoint:(P2t)location {
//
//    M16t inverse = M16InvertColumnMajor([self getGlobalTransformMatrix], NULL);
//    //M16t inverse = [self getGlobalTransformMatrix];
//
//    V3t transformed = V3MultiplyM16(inverse, V3Make(location.x, location.y, V3GetM16Translation(inverse).z));
//
//    P2tp = P2Make(transformed.x / 100., transformed.y / 100.);
//
//    NSLog(@"%f %f node transformed %f, %f", location.x, location.y, p.x, p.y);
//
//    return p;
//}

-(P2t)inverseProjectedPoint:(P2t)location {
    
    M16t globalTransform = [self getGlobalTransformMatrix];
    
    //    bool isInvertible;
    
    V3t transformed = V3MultiplyM16(globalTransform, V3Make(location.x, location.y, 0));
    
    //    if (!isInvertible) {
    //        NSLog(@"node inversion failed");
    //    }
    
    P2t p = P2Make(transformed.x, transformed.y);
    
    return p;
    
}
-(bool)containsPoint:(P2t)location {
    
    // OLD METHOD
    // ADDING LOCAL TRANSFORMATION
    
    P2t p = location;
    //P2tp = [self transformedPoint:location];
    
    //NSLog(@"world coords: %f %f %f", p.x, p.y, p.z);
    
    R4t r = [self getWorldFrame];
    
    //bool withinArea = false;
    if ( p.x > r.x && p.x < r.x + r.size.width && p.y > r.y && p.y < r.y + r.size.height)
    {
        // [self logCoords];
        return true;
    }
    return false;
    
    //    P2t p = [self inverseProjectedPoint:location];
    //
    //    V3t globalPos = [self getGlobalPosition];
    //
    //    R4t r = R4Make(globalPos.x - _size3d.x * _anchorPoint3d.x, globalPos.y - _size3d.y *_anchorPoint3d.y, _size3d.x, _size3d.y);
    //
    //    //bool withinArea = false;
    //    if ( p.x > r.x && p.x < r.x + r.size.width && p.y > r.y && p.y < r.y + r.size.height)
    //    {
    //        // [self logCoords];
    //        return true;
    //    }
    //    return false;
    
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

-(P2t)childLocationIncludingRotation:(NKNode*)child {
    
    P2t polar = carToPol(child.position);
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
    M16SetV3Translation(&localTransformMatrix, position);
    if (!_dirty) {
        [self setDirty:true];
    }
}

-(void)setDirty:(bool)dirty {
    _dirty = dirty;
    
    if (dirty) {
        for (NKNode *n in intChildren) {
            [n setDirty:dirty];
        }
    }
}
// convenience >>

-(void)setZPosition:(int)zPosition {
    [self setPosition3d:V3Make(position.x,position.y, zPosition)];
}

-(void) setGlobalPosition:(const V3t)p {
	if(_parent == NULL) {
		[self setPosition3d:p];
	} else {
        M16t global = [_parent getGlobalTransformMatrix];
        M16Invert(&global);
        [self setPosition3d:V3MultiplyM16WithTranslation(global, p)];
        NKLogV3(@"new global position", self.getGlobalPosition);
        //[self setPosition3d:V3Subtract(p, _parent.getGlobalPosition)];
	}
}

-(void)setPosition:(P2t)p {
    [self setPosition3d:V3Make(p.x, p.y, position.z)];
}

-(P2t)position {
    return P2Make(position.x, position.y);
}

-(P2t)positionInNode:(NKNode *)n {
    //    V3t p = self.node->getGlobalPosition() - n.node->getGlobalPosition();
    //
    V3t p = [self convertPoint3d:V3Make(0,0,0) toNode:n];
    return P2Make(p.x, p.y);
}

-(V3t)positionInNode3d:(NKNode *)n {
    return V3GetM16Translation([self tranformMatrixInNode:n]);
}

#pragma mark - ANCHOR

-(void)setAnchorPoint:(P2t)anchorPoint {
    _anchorPoint3d.x = anchorPoint.x;
    _anchorPoint3d.y = anchorPoint.y;
}

-(P2t)anchorPoint {
    return P2Make(_anchorPoint3d.x, _anchorPoint3d.y);
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
    //localTransformMatrix = M16TranslateWithV3(localTransformMatrix, position);
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

-(void)setOrbit:(V3t)orbit {
    _longitude = orbit.x;
    _latitude = orbit.y;
    _radius = orbit.z;
    
    if (_latitude >= 360) _latitude-=360.;
    else if (_latitude <= -360) _latitude+=360.;
    if (_longitude >= 360) _longitude-=360.;
    else if (_longitude <= -360) _longitude+=360.;
}

-(V3t)currentOrbit {
    return [self orbitForLongitude:_longitude latitude:_latitude radius:_radius];
}

-(V3t)orbitForLongitude:(float)longitude latitude:(float)latitude radius:(float)radius { //centerPoint:(V3t)centerPoint {
    V3t p = V3RotatePoint(V3Make(0, 0, radius), latitude, V3Make(1, 0, 0));
    return V3RotatePoint(p, longitude, V3Make(0, 1, 0));
}

-(void)rotateMatrix:(M16t)M16 {
    M16t m = M16MakeScale(scale);
    localTransformMatrix = M16Multiply(m,M16);
    M16SetV3Translation(&localTransformMatrix, position);
}

//-(void)globalRotateMatrix:(M16t)M16 {
//    M16t m = M16MakeScale(scale);
//    //localTransformMatrix = M16TranslateWithV3(localTransformMatrix, position);
//    M16SetV3Translation(&m, position);
//    m = M16Multiply(m, M16);
//    localTransformMatrix = M16Multiply(m, M16InvertColumnMajor([_parent getGlobalTransformMatrix], 0));
//}

-(void)lookAtNode:(NKNode*)node {
    [self lookAtPoint:[node getGlobalPosition]];
}

-(void)lookAtPoint:(V3t)point {

    M16t new = [self getLookMatrix:point];

    [self rotateMatrix:new];
}

-(M16t)getLookMatrix:(V3t)lookAtPosition {

   return M16MakeLookAt(self.getGlobalPosition, lookAtPosition, [self upVector]);
    
}

-(V3t)upVector {
    if (!_parent){
        return _upVector;
    }
    return V3MultiplyM16([_parent getGlobalTransformMatrix], _upVector);
}

#pragma mark - SCALE


-(void)setScale:(F1t)s {
    [self setScale3d:V3Make(s,s,s)];
}

- (void)setXScale:(F1t)s {
    V3t nScale = scale;
    nScale.x = s;
    [self setScale3d:nScale];
}

- (void)setYScale:(F1t)s {
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

-(P2t)scale {
    return P2Make(scale.x, scale.y);
}

#pragma mark - ALPHA / BLEND

-(void)setTransparency:(F1t)transparency { // just node
    intAlpha = transparency;
    _alpha = transparency;
}

-(void)setAlpha:(F1t)alpha {
    intAlpha = alpha;
    [self recursiveAlpha:1.];
}

-(void)recursiveAlpha:(F1t)alpha{
    _alpha = intAlpha * alpha;
    
    for (NKNode* n in intChildren) {
        [n recursiveAlpha:(_alpha)];
    }
}

-(void)setColor:(NKByteColor*)color {
    _color = color;
}

-(NKByteColor*)color {
    return _color;
}

#pragma mark - ACTIONS

-(void)removeAllActions {
    [animationHandler removeAllActions];
}

#pragma mark - EVENT HANDLING

-(void)handleEventWithType:(NKEventType)event forLocation:(P2t)location {
    if (_eventBlock) {
        _eventBlock(event, location);
    }
}

#pragma mark - TOUCH
-(NKTouchState)touchDown:(P2t)location id:(int)touchId {
    // OVERRIDE, CALL SUPER
    
    //    NKTouchState hit = NKTouchNone;
    //
    //    if (_userInteractionEnabled){
    //
    //        if ([self containsPoint:location]) {
    //            hit = NKTouchIsFirstResponder;
    //        }
    //
    //        for (int i = intChildren.count-1; i >= 0; i--){
    //            if ([intChildren[i] touchDown:location id:touchId] > 0) {
    //                return NKTouchContainsFirstResponder;
    //            }
    //        }
    //
    //        if (hit == NKTouchIsFirstResponder){
    //               NSLog(@"touch down %@ %f, %f",self.name, location.x, location.y);
    //        }
    //    }
    //
    //    return hit;
    return false;
}

-(NKTouchState)touchMoved:(P2t)location id:(int)touchId {
    // OVERRIDE, CALL SUPER
    
    //    NKTouchState hit = NKTouchNone;
    //
    //    if (_userInteractionEnabled){
    //
    //        if ([self containsPoint:location]) {
    //            hit = NKTouchIsFirstResponder;
    //        }
    //
    //        for (int i = intChildren.count-1; i >= 0; i--){
    //            if ([intChildren[i] touchMoved:location id:touchId] > 0) {
    //                return NKTouchContainsFirstResponder;
    //            }
    //        }
    //
    //    }
    //
    //    return hit;
    return false;
}

-(NKTouchState)touchUp:(P2t)location id:(int)touchId {
    // OVERRIDE, CALL SUPER
    
    //    NKTouchState hit = NKTouchNone;
    //
    //    if (_userInteractionEnabled){
    //
    //        if ([self containsPoint:location]) {
    //            hit = NKTouchIsFirstResponder;
    //        }
    //        
    //        for (int i = intChildren.count-1; i >= 0; i--){
    //            if ([intChildren[i] touchUp:location id:touchId] > 0) {
    //                return NKTouchContainsFirstResponder;
    //            }
    //        }
    //        
    //    }
    //    
    //    if (hit >= NKTouchIsFirstResponder){
    //        V2t p2 = [self inverseProjectedPoint:location];
    //        NSLog(@"touch up %@ %f, %f", self.name, p2.x, p2.y);
    //    }
    //    
    //    return hit;
    return false;
}



#pragma mark - DEALLOC C++ Objectes

-(void)dealloc {
    if (self.uidColor) {
        [[NKShaderManager uidColors] removeObjectForKey:self.uidColor];
    }
    [animationHandler removeAllActions];
    animationHandler = NULL;
}

@end
