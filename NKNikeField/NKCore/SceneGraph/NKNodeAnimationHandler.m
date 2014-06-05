//
//  ofxBlockAnimationHandler.cpp
//  example-ofxTableView
//
//  Created by Chroma Developer on 2/11/14.
//
//

#import "NodeKitten.h"

@implementation NKAction




inline F1t logAverage (F1t src, F1t dst, F1t d){
    
    return src == dst ? src : ((src * (1.- d*d) + dst * d * d));
    
}


-(instancetype) initWithDuration:(F1t)duration {
    
    if (!duration) {
        return nil;
    }
    
    self = [super init];
    if(self){
        _progress = 0.;
        _duration = duration * 1000.;
        _speed = 1.;
        _repeats = 0;
    }
    
    return self;
}

#pragma mark - INIT / REMOVE / GROUP


-(void)stop {
    for (NKAction *a in _children) {
        [a stop];
    }
    _children = nil;
    _actions = nil;
    _repeats = 0;
    _completionBlock = nil;
    _actionBlock = nil;
    
}

-(void)removeAction:(NKAction*)action {
    if (_actions.count) {
        [_actions removeObject:action];
        if (!_actions.count) {
            [self completeOrRepeat];
        }
    }
}

-(void)sharedReset {

    _progress = 0.;
    _reset = true;
    
    if (_children.count) {
        _actions = [_children mutableCopy];
        for (NKAction *c in _actions) {
            [c sharedReset];
        }
    }
    
}

-(bool)completeOrRepeat {
    if (_repeats == 0) {
        if (_completionBlock) {
            [self.handler runCompletionBlockForAction:self];
        }
        [_parentAction removeAction:self];
        return 0;
    }
    
    else {
        if (_repeats > 0){
            _repeats -= 1;
        }
        [self sharedReset];
        return 1;
    }
}

-(void)completeWithTimeSinceLast:(F1t)dt forNode:(NKNode*)node {
    
    if ([self completeOrRepeat]) {
        [self updateWithTimeSinceLast:dt forNode:node];
    }
    
}

#pragma mark - Grouping

+ (NKAction *)group:(NSArray *)actions {
    
    NKAction * newAction = [[NKAction alloc] init];
    
    newAction.children = [actions mutableCopy];
    
    for (NKAction *a in newAction.children) {
        a.parentAction = newAction;
        a.reset = true;
    }
    
    return newAction;
    
}

+ (NKAction *)sequence:(NSArray *)actions {
    
    NKAction * newAction = [NKAction group:actions];
    newAction.serial = true;
    return newAction;
    
}

+ (NKAction *)delayFor:(F1t)sec {
    NKAction * newAction = [[NKAction alloc] initWithDuration:sec];
    
    newAction.actionBlock = (ActionBlock)^(NKAction *action, NKNode* node, F1t completion){
        if (action.reset) {
            action.reset = false;
        }
    };
    return newAction;
}

+ (NKAction *)repeatAction:(NKAction *)action count:(NSUInteger)count{
    
    action.repeats = count;
    return action;
    
}

+ (NKAction *)repeatActionForever:(NKAction *)action {
    action.repeats = -1;
    return action;
}


#pragma mark - MOVE BY

+ (NKAction *)moveByX:(CGFloat)deltaX y:(CGFloat)deltaY duration:(F1t)sec {
    
    return [NKAction move3dByX:deltaX Y:deltaY Z:0 duration:sec];
    
}

+ (NKAction *)moveBy:(CGVector)delta duration:(F1t)sec {
    
    return [NKAction moveByX:delta.dx y:delta.dy duration:sec];
    
}

+ (NKAction *)move3dBy:(V3t)delta duration:(F1t)sec {
    
    return [NKAction move3dByX:delta.x Y:delta.y Z:delta.z duration:sec];
    
}

+ (NKAction *)move3dByX:(CGFloat)x Y:(CGFloat)y Z:(CGFloat)z duration:(F1t)sec {
    
    NKAction * newAction = [[NKAction alloc] initWithDuration:sec];
    
    newAction.actionBlock = (ActionBlock)^(NKAction *action, NKNode* node, F1t completion){
        
        if (action.reset) {
            action.startPos = node.position3d;
            V3t p = action.startPos;
            action.endPos = V3Make(p.x + x, p.y+y, p.z + z);
            action.reset = false;
            //NSLog(@"action end %f %f %f",action.endPos.x,action.endPos.y,action.endPos.z);
        }

        V3t np = getTweenPoint(action.startPos, action.endPos, completion );
       // NSLog(@"action dst %f %f %f, comp: %f",np.x,np.y,np.z, completion);
        [node setPosition3d:np];
        
    };
    
    return newAction;
    
}

#pragma mark - MOVE TO

+ (NKAction *)move3dTo:(V3t)location duration:(F1t)sec {
    
    NKAction * newAction = [[NKAction alloc] initWithDuration:sec];
    
    newAction.actionBlock = (ActionBlock)^(NKAction *action, NKNode* node, F1t completion){
        
        if (action.reset) {
            action.startPos = node.position3d;
            action.endPos = V3Make(location.x, location.y, location.z);
            action.reset = false;
        }
        
         [node setPosition3d:getTweenPoint(action.startPos, action.endPos, completion )];
        
    };
    
    return newAction;
    
}

+ (NKAction *)moveToX:(CGFloat)x y:(CGFloat)y duration:(F1t)sec {
    
    NKAction * newAction = [[NKAction alloc] initWithDuration:sec];
    
    newAction.actionBlock = (ActionBlock)^(NKAction *action, NKNode* node, F1t completion){
        
        if (action.reset) {
            action.startPos = node.position3d;
            V3t p = node.position3d;
            action.endPos = V3Make(x, y, p.z);
            action.reset = false;
        }

        
        [node setPosition3d:getTweenPoint(action.startPos, action.endPos, completion )];

    };
    
    return newAction;
}

+ (NKAction *)moveTo:(P2t)location duration:(F1t)sec {
    
    return [NKAction moveToX:location.x y:location.y duration:sec];
    
}

+ (NKAction *)moveToX:(CGFloat)x duration:(F1t)sec {
    NKAction * newAction = [[NKAction alloc] initWithDuration:sec];
    
    newAction.actionBlock = (ActionBlock)^(NKAction *action, NKNode* node, F1t completion){
        
        if (action.reset) {
            action.startPos = node.position3d;
            V3t p = node.position3d;
            action.endPos = V3Make(x, p.y, p.z);
            action.reset = false;
        }
        
        [node setPosition3d:getTweenPoint(action.startPos, action.endPos, completion )];

    };
    
    return newAction;
}

+ (NKAction *)moveToY:(CGFloat)y duration:(F1t)sec {
    NKAction * newAction = [[NKAction alloc] initWithDuration:sec];
    
    newAction.actionBlock = (ActionBlock)^(NKAction *action, NKNode* node, F1t completion){
        
        if (action.reset) {
            action.startPos = node.position3d;
            V3t p = node.position3d;
            action.endPos = V3Make(p.x, y, p.z);
            action.reset = false;

        }
        
        [node setPosition3d:getTweenPoint(action.startPos, action.endPos, completion )];

        
    };
    
    return newAction;
    
}

+ (NKAction *)moveToFollowNode:(NKNode*)target duration:(F1t)sec {
    
    NKAction * newAction = [[NKAction alloc] initWithDuration:sec];
    
    newAction.actionBlock = (ActionBlock)^(NKAction *action, NKNode* node, F1t completion){
        
        if (action.reset) {
            action.startPos = node.position3d;
            //action.endPos = V3Make(location.x, location.y, location.z);
            action.reset = false;
        }
        
        [node setPosition3d:getTweenPoint(action.startPos, target.getGlobalPosition, completion )];
        
    };
    
    return newAction;
    
}

+ (NKAction *)followNode:(NKNode*)target duration:(F1t)sec {
    
    NKAction * newAction = [[NKAction alloc] initWithDuration:sec];
    
    newAction.actionBlock = (ActionBlock)^(NKAction *action, NKNode* node, F1t completion){
        
        if (action.reset) {
            action.reset = false;
        }
        
        [node setPosition3d:target.getGlobalPosition];
        //[node setPosition3d:getTweenPoint(action.startPos, target.getGlobalPosition, completion )];
    };
    
    return newAction;
    
}

#pragma mark - ROTATE

+(NKAction *)rotate3dByAngle:(V3t)angles duration:(F1t)sec {
    
    NKAction * newAction = [[NKAction alloc] initWithDuration:sec];
    
    newAction.actionBlock = (ActionBlock)^(NKAction *action, NKNode* node, F1t completion){
        
        if (action.reset) {
            action.reset = false;
            Q4t start = node.orientation;
            action.startOrientation = start;
            Q4t xRot = Q4FromAngleAndV3(angles.x, V3Make(1,0,0));
            Q4t yRot = Q4FromAngleAndV3(angles.y, V3Make(0,1,0));
            Q4t zRot = Q4FromAngleAndV3(angles.z, V3Make(0,0,1));
            action.endOrientation = QuatMul(xRot, QuatMul(yRot, QuatMul(zRot, start)));
        }
        
      [node setOrientation:QuatSlerp(action.startOrientation, action.endOrientation,completion)];

        
    };
    
    return newAction;
    
}

+(NKAction *)rotate3dToAngle:(V3t)angles duration:(F1t)sec {
    
    NKAction * newAction = [[NKAction alloc] initWithDuration:sec];
    
    newAction.actionBlock = (ActionBlock)^(NKAction *action, NKNode* node, F1t completion){
        
        if (action.reset) {
            action.reset = false;
            Q4t start = node.orientation;
            action.startOrientation = start;
            Q4t xRot = Q4FromAngleAndV3(angles.x, V3Make(1,0,0));
            Q4t yRot = Q4FromAngleAndV3(angles.y, V3Make(0,1,0));
            Q4t zRot = Q4FromAngleAndV3(angles.z, V3Make(0,0,1));
            action.endOrientation = QuatMul(xRot, QuatMul(yRot, QuatMul(zRot, start)));
        }
        
    [node setOrientation:QuatSlerp(action.startOrientation, action.endOrientation,completion)];
    };
    
    return newAction;
    
}

+(NKAction *)rotateXByAngle:(CGFloat)radians duration:(F1t)sec {
    
    return [NKAction rotateAxis:V3Make(1,0,0) byAngle:radians duration:sec];
    
}

+(NKAction *)rotateYByAngle:(CGFloat)radians duration:(F1t)sec {
    
    return [NKAction rotateAxis:V3Make(0,1,0) byAngle:radians duration:sec];
    
}


+(NKAction *)rotateByAngle:(CGFloat)radians duration:(F1t)sec {
    
    return [NKAction rotateAxis:V3Make(0,0,1) byAngle:radians duration:sec];
    
}

+(NKAction *)rotateAxis:(V3t)axis byAngle:(CGFloat)radians duration:(F1t)sec {
    
    NKAction * newAction = [[NKAction alloc] initWithDuration:sec];
    
    newAction.actionBlock = (ActionBlock)^(NKAction *action, NKNode* node, F1t completion){
        
        if (action.reset) {
            action.reset = false;
            Q4t start = node.orientation;
            action.startOrientation = start;
            Q4t rot = Q4FromAngleAndV3(radians, axis);
            action.endOrientation = QuatMul(start, rot);
        }
        
        [node setOrientation:QuatSlerp(action.startOrientation, action.endOrientation,completion)];
        
    };
    
    return newAction;
    
}

+ (NKAction *)rotateToAngle:(CGFloat)radians duration:(F1t)sec {
    
    NKAction * newAction = [[NKAction alloc] initWithDuration:sec];
    
    newAction.actionBlock = (ActionBlock)^(NKAction *action, NKNode* node, F1t completion){
        
        if (action.reset) {

            action.reset = false;
            Q4t start = node.orientation;
            action.startOrientation = start;
            Q4t zRot = Q4FromAngleAndV3(radians, V3Make(0,0,1));
            action.endOrientation = zRot;

        }
        
        [node setOrientation:QuatSlerp(action.startOrientation, action.endOrientation,completion)];
        
    };
    
    return newAction;
    
}

#pragma mark - GL LOOK AT

+ (NKAction *)enterOrbitAtLongitude:(float)longitude latitude:(float)latitude radius:(float)radius duration:(F1t)sec {
    return [NKAction enterOrbitAtLongitude:longitude latitude:latitude radius:radius offset:V3MakeF(0) duration:sec];
}

+ (NKAction *)enterOrbitAtLongitude:(float)longitude latitude:(float)latitude radius:(float)radius offset:(V3t)offset duration:(F1t)sec {
    
    NKAction * newAction = [[NKAction alloc] initWithDuration:sec];
    
    newAction.actionBlock = (ActionBlock)^(NKAction *action, NKNode* node, F1t completion){
        
        if (action.reset) {
            action.reset = false;
            action.startPos = [node position3d];
            [node setOrbit:V3Make(longitude,latitude,radius)];
            action.endPos = V3Add([node currentOrbit],offset);
           
//            if ([node.name isEqualToString:@"CAMERA"]) {
//                NKLogV3(@"enter orbit from" , action.startPos);
//                NKLogV3(@"enter orbit to" , action.endPos);
//            }
        }
       
        [node setPosition3d:getTweenPoint(action.startPos, action.endPos, completion)];
        
    };
    
    return newAction;
}

+(NKAction *)maintainOrbitDeltaLongitude:(float)deltaLongitude latitude:(float)deltaLatitude radius:(float)deltaRadius duration:(F1t)sec {
    return [NKAction maintainOrbitDeltaLongitude:deltaLongitude latitude:deltaLatitude radius:deltaRadius offset:V3MakeF(0) duration:sec];
}

+ (NKAction *)maintainOrbitDeltaLongitude:(float)deltaLongitude latitude:(float)deltaLatitude radius:(float)deltaRadius offset:(V3t)offset duration:(F1t)sec {
    
    NKAction * newAction = [[NKAction alloc] initWithDuration:sec];
    
    newAction.actionBlock = (ActionBlock)^(NKAction *action, NKNode* node, F1t completion){
        
        if (action.reset) {
            action.reset = false;

            action.startPos = V3Make(node.longitude, node.latitude, node.radius);
            action.endPos = V3Add(action.startPos, V3Make(deltaLongitude, deltaLatitude, deltaRadius));
            
            [node setOrbit:action.endPos];
        }
        [node setOrbit:getTweenPoint(action.startPos, action.endPos, completion)];
        [node setPosition3d:V3Add(offset, [node currentOrbit])];
    };
    
    return newAction;
}

+ (NKAction*)panTolookAtNode:(NKNode*)target duration:(F1t)sec {
    
    NKAction * newAction = [[NKAction alloc] initWithDuration:sec];
    newAction.target = target;
    
    newAction.actionBlock = (ActionBlock)^(NKAction *action, NKNode* node, F1t completion){
        
        if (action.reset) {
            action.reset = false;
        }
        
        action.startOrientation = Q4GetM16Rotate([node getGlobalTransformMatrix]);
        action.endOrientation = Q4GetM16Rotate([node getLookMatrix:[target getGlobalPosition]]);
        
        [node setOrientation:QuatSlerp(action.startOrientation, action.endOrientation,completion)];
        
    };
    
    return newAction;
    
}

+ (NKAction*)snapLookToNode:(NKNode*)target forDuration:(F1t)sec {
    
    NKAction * newAction = [[NKAction alloc] initWithDuration:sec];
    newAction.target = target;
    
    newAction.actionBlock = (ActionBlock)^(NKAction *action, NKNode* node, F1t completion){
        if (action.reset) {
            action.reset = false;
        }
        
        [node lookAtNode:target];
        
    };
    
    return newAction;
    
}


#pragma mark - SCALE

+(NKAction *)scaleBy:(CGFloat)scale duration:(F1t)sec {
    NKAction * newAction = [[NKAction alloc] initWithDuration:sec];
    newAction.actionBlock = (ActionBlock)^(NKAction *action, NKNode* node, F1t completion){
        if (action.reset) {
            action.reset = false;
            action.startPos = node.scale3d;
            action.endPos = V3Make(action.startPos.x * scale, action.startPos.y * scale, action.startPos.z * scale);
        }
        [node setScale3d:getTweenPoint(action.startPos, action.endPos, completion)];
    };
    return newAction;
}

+ (NKAction *)scaleXBy:(CGFloat)xScale y:(CGFloat)yScale duration:(F1t)sec {
    NKAction * newAction = [[NKAction alloc] initWithDuration:sec];
    newAction.actionBlock = (ActionBlock)^(NKAction *action, NKNode* node, F1t completion){
        if (action.reset) {
            action.reset = false;
            action.startPos = node.scale3d;
            action.endPos = V3Make(action.startPos.x * xScale, action.startPos.y * yScale, action.startPos.z);
        }
       [node setScale3d:getTweenPoint(action.startPos, action.endPos, completion)];
    };
    return newAction;
}

+ (NKAction *)scaleTo:(CGFloat)scale duration:(F1t)sec {
    NKAction * newAction = [[NKAction alloc] initWithDuration:sec];
    newAction.actionBlock = (ActionBlock)^(NKAction *action, NKNode* node, F1t completion){
        if (action.reset) {
            action.reset = false;
            action.startPos = node.scale3d;
            action.endPos = V3Make(scale, scale, scale);
        }
       [node setScale3d:getTweenPoint(action.startPos, action.endPos, completion)];
    };
    return newAction;
}

+ (NKAction *)scaleXTo:(CGFloat)xScale y:(CGFloat)yScale duration:(F1t)sec {
    NKAction * newAction = [[NKAction alloc] initWithDuration:sec];
    newAction.actionBlock = (ActionBlock)^(NKAction *action, NKNode* node, F1t completion){
        if (action.reset) {
            action.reset = false;
            action.startPos = node.scale3d;
            action.endPos = V3Make(xScale, yScale, action.startPos.z);
        }
        [node setScale3d:getTweenPoint(action.startPos, action.endPos, completion)];
    };
    return newAction;

}

+ (NKAction *)scaleXTo:(CGFloat)scale duration:(F1t)sec {
    NKAction * newAction = [[NKAction alloc] initWithDuration:sec];
    newAction.actionBlock = (ActionBlock)^(NKAction *action, NKNode* node, F1t completion){
        if (action.reset) {
            action.reset = false;
            action.startPos = node.scale3d;
            action.endPos = V3Make(scale, action.startPos.y, action.startPos.z);
        }
        [node setScale3d:getTweenPoint(action.startPos, action.endPos, completion)];
    };
    return newAction;
}

+ (NKAction *)scaleYTo:(CGFloat)scale duration:(F1t)sec {
    NKAction * newAction = [[NKAction alloc] initWithDuration:sec];
    newAction.actionBlock = (ActionBlock)^(NKAction *action, NKNode* node, F1t completion){
        if (action.reset) {
            action.reset = false;
            action.startPos = node.scale3d;
            action.endPos = V3Make(action.startPos.x, scale, action.startPos.z);
        }
       [node setScale3d:getTweenPoint(action.startPos, action.endPos, completion)];
    };
    return newAction;
}


+ (NKAction *)resizeToWidth:(CGFloat)width height:(CGFloat)height duration:(F1t)duration {
    
    NKAction * newAction = [[NKAction alloc] initWithDuration:duration];
    
    newAction.actionBlock = (ActionBlock)^(NKAction *action, NKNode* node, F1t completion){
        
        if (action.reset) {
            action.reset = false;
            action.startPos = node.size3d;
            action.endPos = V3Make(width, height, node.size3d.z);
        }
        
        
        node.size3d = getTweenPoint(action.startPos, action.endPos, completion);
    };
    
    return newAction;

    
}

+ (NKAction *)resize3d:(V3t)newSize duration:(F1t)duration {
    
    NKAction * newAction = [[NKAction alloc] initWithDuration:duration];
    
    newAction.actionBlock = (ActionBlock)^(NKAction *action, NKNode* node, F1t completion){
        
        if (action.reset) {
            action.reset = false;
            action.startPos = node.size3d;
            action.endPos = newSize;
        }
        
        
        node.size3d = getTweenPoint(action.startPos, action.endPos, completion);
    };
    
    return newAction;
    
    
}

#pragma mark - ALPHA

+ (NKAction *)fadeAlphaTo:(F1t)alpha duration:(F1t)sec {
    
    NKAction * newAction = [[NKAction alloc] initWithDuration:sec];
    
    newAction.actionBlock = (ActionBlock)^(NKAction *action, NKNode* node, F1t completion){
        
        if (action.reset) {
            action.reset = false;
            action.startFloat = node.alpha;
            action.endFloat = alpha;
        }
        
        [node setAlpha:weightedAverage(action.startFloat, action.endFloat, completion)];

    };
    
    return newAction;

    
}

#pragma mark - SCROLL ACTIONS

+(NKAction*)scrollToPoint:(P2t)point duration:(F1t)sec {
    
    NKAction * newAction = [[NKAction alloc] initWithDuration:sec];
    
    newAction.actionBlock = (ActionBlock)^(NKAction *action, NKNode* node, F1t completion){
        
        if (action.reset) {
            P2t p2 = [(NKScrollNode*)node scrollPosition];
            action.startPos = V3Make(p2.x,p2.y,0);
            action.endPos = V3Make(point.x, point.y, 0);
            action.reset = false;
        }
        
        V3t p = getTweenPoint(action.startPos, action.endPos, completion );
        [(NKScrollNode*)node setScrollPosition:P2Make(p.x,p.y)];
        
    };
    
    return newAction;
    
}

+(NKAction*)scrollToChild:(NKNode*)child duration:(F1t)sec {
    
    NKAction * newAction = [[NKAction alloc] initWithDuration:sec];
    
    newAction.actionBlock = (ActionBlock)^(NKAction *action, NKNode* node, F1t completion){
        
        if (action.reset) {
            P2t p2 = [(NKScrollNode*)node scrollPosition];
            action.startPos = V3Make(p2.x,p2.y,0);
            action.endPos = V3Make(child.position.x, child.position.y, 0);
            action.reset = false;
        }
        
        V3t p = getTweenPoint(action.startPos, action.endPos, completion );
        [(NKScrollNode*)node setScrollPosition:P2Make(p.x,p.y)];
        
    };
    
    return newAction;
    
}

#pragma mark - CUSTOM ACTIONS

+(NKAction*)customActionWithDuration:(F1t)seconds actionBlock:(ActionBlock)block {
    
    NKAction * newAction = [[NKAction alloc] initWithDuration:seconds];
    
    newAction.actionBlock = block;
    
    return newAction;
    
    
}

#pragma mark - UPDATE

- (bool)updateWithTimeSinceLast:(F1t)dt forNode:(NKNode*)node{

    F1t completion = _progress / _duration;
    
    if (completion < 1.) {
        
        if (_actionBlock){
            _actionBlock(self, node, completion);
        }
        
        _progress += (F1t)dt;
        
        return 0;
        
    }
    
    else {
        _actionBlock(self, node, 1);
        return 1;
    }

}

-(NodeAnimationHandler*)handler {
    if (_parentAction){
        return _parentAction.handler;
    }
    return nil;
}

@end

#pragma mark - ANIMATION HANDLER


void excecuteAction(NKAction *action, NKNode* node, F1t dt){

    if (action.children) { // GROUPS
        
        if (action.children.count) {
            
            if (action.reset) {
                action.actions = [action.children mutableCopy];
                
                for (NKAction *a in action.actions) {
                    a.reset = true;
                }
                
                action.reset = false;
            }
            
            if (action.serial) {
                excecuteAction(action.actions[0],node,  dt);
                //[self executeAction:action.actions[0] dt:dt];
            }
            
            else { // parallel
                for (NKAction* ac in action.children) {
                    excecuteAction(ac, node, dt);
                    //[self executeAction:ac dt:dt];
                }
            }
            
            if (!action.actions.count) {
                
                [action completeWithTimeSinceLast:dt forNode:node];
            }
            
        }
        
    }
    
    else {

        if ([action updateWithTimeSinceLast:dt forNode:node]){
            [action completeWithTimeSinceLast:dt forNode:node];
        }
        
    }
}

@implementation NodeAnimationHandler

- (instancetype) initWithNode:(NKNode*)node {
    
    self = [super init];
    
    if (self){
        _node = node;
        actions = [[NSMutableArray alloc]init];
    }
    
    return self;
    
}



- (void)updateWithTimeSinceLast:(F1t) dt{
    
    if (actions.count) {
        for (int i = 0; i < actions.count; i++){
            excecuteAction(actions[i], _node, dt);
        }
    }
    
}




-(void)removeAction:(NKAction*)action {
    
    if (actions.count) {
        [actions removeObject:action];
    }
    
}

-(void)runCompletionBlockForAction:(NKAction*)action {
    void (^block)(void) = action.completionBlock;
    block();
}

- (void)runAction:(NKAction *)action { // MASTER
    if (action) {
        NSMutableArray* mut = actions.mutableCopy;
        [mut addObject:action];
        actions = mut;
        
        action.parentAction = (NKAction*)self;
        [action sharedReset];
    }
}

- (void)runAction:(NKAction *)action completion:(void (^)())block {
    action.completionBlock = block;
    [self runAction:action];
}

- (int)hasActions {
    return actions.count;
}

-(void)removeAllActions{
    for (NKAction* action in actions) {
        [action stop];
    }
    
    [actions removeAllObjects];
}

-(NodeAnimationHandler*)handler {
    return self;
}

-(void)stop {
    
}

@end
