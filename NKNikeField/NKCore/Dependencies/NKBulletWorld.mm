//
//  NKBulletWorld.m
//  EMA Stage
//
//  Created by Leif Shackelford on 6/2/14.
//  Copyright (c) 2014 EMA. All rights reserved.
//

#import "NKBulletWorld.h"
#import "btBulletDynamicsCommon.h"
#import "NKNode.h"

static NKBulletWorld *sharedObject = nil;

static inline btVector3 btv(V3t v){
    return btVector3(v.x,v.y,v.z);
}

@interface NKBulletWorld()
{
    btDefaultCollisionConfiguration* collisionConfiguration;
    btCollisionDispatcher* dispatcher;
    btBroadphaseInterface* overlappingPairCache;
    btSequentialImpulseConstraintSolver* solver;
    btDiscreteDynamicsWorld* dynamicsWorld;
}
@end

@implementation NKBulletWorld

+ (NKBulletWorld *)sharedInstance
{
    static dispatch_once_t _singletonPredicate;
    
    dispatch_once(&_singletonPredicate, ^{
        sharedObject = [[super alloc] init];
    });
    
    return sharedObject;
}


-(instancetype)init {
    self = [super init];
    if (self) {
        ///-----initialization_start-----
        
        ///collision configuration contains default setup for memory, collision setup. Advanced users can create their own configuration.
        collisionConfiguration = new btDefaultCollisionConfiguration();
        
        ///use the default collision dispatcher. For parallel processing you can use a diffent dispatcher (see Extras/BulletMultiThreaded)
        dispatcher = new	btCollisionDispatcher(collisionConfiguration);
        
        ///btDbvtBroadphase is a good general purpose broadphase. You can also try out btAxis3Sweep.
        overlappingPairCache = new btDbvtBroadphase();
        
        ///the default constraint solver. For parallel processing you can use a different solver (see Extras/BulletMultiThreaded)
        solver = new btSequentialImpulseConstraintSolver;
        
        dynamicsWorld = new btDiscreteDynamicsWorld(dispatcher,overlappingPairCache,solver,collisionConfiguration);
        
        dynamicsWorld->setGravity(btVector3(0,-10,0));
        
        _collisionShapeCache = [[NSMutableSet alloc]init];
        
        NSLog(@"bullet dynamics loaded");
    }
    
    return self;
}

-(instancetype)initWithGravity:(V3t)gravity {
    if (self = [self init]){
        dynamicsWorld->setGravity(btVector3(gravity.x, gravity.y,gravity.z));
    }
    return self;
}

-(void)updateWithTimeSinceLast:(F1t)dt {
    dynamicsWorld->stepSimulation(dt);
    
    //NSLog(@"num objects: %d",dynamicsWorld->getNumCollisionObjects() );
    
//    for (int j=dynamicsWorld->getNumCollisionObjects()-1; j>=0 ;j--)
//    {
//        btCollisionObject* obj = dynamicsWorld->getCollisionObjectArray()[j];
//        btRigidBody* body = btRigidBody::upcast(obj);
//        if (body && body->getMotionState())
//        {
//            btTransform trans;
//            body->getMotionState()->getWorldTransform(trans);
//        }
//    }
}

-(void)addNode:(NKNode*)node {
    
    if (!_nodes) {
        _nodes = [[NSMutableSet alloc]init];
    }
    
    if (![_nodes containsObject:node]) {
        [_nodes addObject:node];
        dynamicsWorld->addRigidBody((btRigidBody*)node.body.btBody);
    }
    
}

-(void)removeNode:(NKNode*)node {

    if (![_nodes containsObject:node]) {
        dynamicsWorld->removeRigidBody((btRigidBody*)node.body.btBody);
        [_nodes removeObject:node];
    }
    
}

-(void)dealloc {
    //delete dynamics world
	delete dynamicsWorld;
    
	//delete solver
	delete solver;
    
	//delete broadphase
	delete overlappingPairCache;
    
	//delete dispatcher
	delete dispatcher;
    
	delete collisionConfiguration;
}

@end

@interface NKBulletShape(){
    btCollisionShape* collisionShape;
}

@end

@implementation NKBulletShape


-(instancetype)initWithType:(NKBulletShapes)shape size:(V3t)size {
    if (self = [super init]){
        switch (shape) {
            case NKBulletShapeBox:
                collisionShape = new btBoxShape(btv(size));
                break;
                
            case NKBulletShapeSphere:
                collisionShape = new btSphereShape(size.x);
                break;
                
            default:
                break;
        }
    }
    return self;
}

-(void)calculateLocalInertia:(F1t)mass inertia:(V3t)localInertia {
    btVector3 li(localInertia.x,localInertia.y,localInertia.z);
    collisionShape->calculateLocalInertia(mass,li);
}

-(BOOL)isEqual:(id)object {
    
    if (self.shape != ((NKBulletShape*)object).shape) {
        return false;
    }
    if (V3Equal(self.size, ((NKBulletShape*)object).size)) {
        return false;
    }
    
    return true;
}


-(void*)btShape {
    return collisionShape;
}

-(void)dealloc {
    delete collisionShape;
}

@end

@interface NKBulletBody(){
    btRigidBody* body;
}

@end

@implementation NKBulletBody

-(instancetype)initWithType:(NKBulletShapes)shape Size:(V3t)size transform:(M16t)m16 mass:(F1t)mass {
    if (self = [super init]){
        
        _shape = [[NKBulletShape alloc]initWithType:shape size:size];
        
        btTransform transform;
        transform.setIdentity();
        //transform.setOrigin(btVector3(position.x,position.y,position.z));
        transform.setFromOpenGLMatrix(m16.m);
        //rigidbody is dynamic if and only if mass is non zero, otherwise static
        bool isDynamic = (mass != 0.f);
        
        btVector3 localInertia(0,0,0);
        
        if (isDynamic)
            ((btCollisionShape*)_shape.btShape)->calculateLocalInertia(mass,localInertia);
        
        //using motionstate is recommended, it provides interpolation capabilities, and only synchronizes 'active' objects
        btDefaultMotionState* myMotionState = new btDefaultMotionState(transform);
        btRigidBody::btRigidBodyConstructionInfo rbInfo(mass,myMotionState,(btCollisionShape*)_shape.btShape,localInertia);
        
        body = new btRigidBody(rbInfo);
        
        //add the body to the dynamics world
        
        //[[NKBulletWorld sharedInstance] addBody:self];
        
    }

    return self;
}

-(void*)btBody {
    return body;
}

// PROPERTIES

-(void)setMass:(F1t)mass inertia:(V3t)inertia {
    body->setMassProps(mass, btv(inertia));
}

-(void)setSleepingThresholds:(F1t)linear angular:(F1t)angular {
    body->setSleepingThresholds(linear, angular);
}

-(void)setDamping:(F1t)linear angular:(F1t)angular {
    body->setDamping(linear, angular);
}

-(void)setFriction:(F1t)friction {
    body->setFriction(friction);
}

-(void)setRestitution:(F1t)restitution {
    body->setRestitution(restitution);
}

// FORCE

-(void)applyTorque:(V3t)torque {
    body->applyTorque(btv(torque));
}

-(void)applyTorqueImpulse:(V3t)torque {
    body->applyTorqueImpulse(btv(torque));
}

-(void)applyCentralForce:(V3t)force {
    body->applyCentralForce(btv(force));
}

-(void)applyCentralImpulse:(V3t)force {
    body->applyCentralForce(btv(force));
}

-(void)applyDamping:(F1t)timeStep {
    body->applyDamping(timeStep);
}

-(void)getPhysicsMatrix:(M16t *)m {
    btTransform trans;
    body->getMotionState()->getWorldTransform(trans);
    trans.getOpenGLMatrix(m->m);
}

-(void)dealloc {
    delete body->getMotionState();
    delete body;
}

@end


