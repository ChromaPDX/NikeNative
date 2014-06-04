//
//  NKBulletWorld.h
//  EMA Stage
//
//  Created by Leif Shackelford on 6/2/14.
//  Copyright (c) 2014 EMA. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NKNode;

typedef NS_ENUM(GLint, NKBulletShapes)
{
    NKBulletShapeNone,
    NKBulletShapeBox,
    NKBulletShapeSphere,
    NKBulletShapeCylinder
} NS_ENUM_AVAILABLE(10_8, 5_0);

@interface NKBulletWorld : NSObject

@property (nonatomic, strong) NSMutableSet *collisionShapeCache;
@property (nonatomic, strong) NSMutableSet *nodes;

+ (NKBulletWorld *)sharedInstance;
-(instancetype)initWithGravity:(V3t)gravity;

-(void)updateWithTimeSinceLast:(F1t)dt;

-(void)addNode:(NKNode*)node;
-(void)removeNode:(NKNode*)node;

@end

@interface NKBulletShape : NSObject

@property (nonatomic) NKBulletShapes shape;
@property (nonatomic) V3t size;

-(BOOL)isEqual:(id)object;
-(void*)btShape;

@end

@interface NKBulletBody : NSObject

@property (nonatomic, strong) NKBulletShape *shape;

-(void*)btBody;

-(instancetype)initWithType:(NKBulletShapes)shape Size:(V3t)size transform:(M16t)m16 mass:(F1t)mass;

-(void)getPhysicsMatrix:(M16t *)m;

// PROPERTIES
-(void)setMass:(F1t)mass;
-(void)setDamping:(F1t)linear angular:(F1t)angular;
-(void)setFriction:(F1t)friction;
-(void)setRestitution:(F1t)restitution;
-(void)setSleepingThresholds:(F1t)linear angular:(F1t)angular;
// FORCES
-(void)applyTorque:(V3t)torque;
-(void)applyTorqueImpulse:(V3t)torque;
-(void)applyCentralForce:(V3t)force;
-(void)applyCentralImpulse:(V3t)force;
-(void)applyDamping:(F1t)timeStep;

@end
