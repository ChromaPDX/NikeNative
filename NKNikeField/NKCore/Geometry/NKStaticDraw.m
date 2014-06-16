//
//  NKStaticDraw.m
//  NKNative
//
//  Created by Leif Shackelford on 4/6/14.
//  Copyright (c) 2014 Chroma Developer. All rights reserved.
//

#import "NodeKitten.h"

@implementation NKStaticDraw

static NKStaticDraw *sharedObject = nil;

-(instancetype)init {
    self = [super init];
    if (self) {
        meshesCache = [NSMutableDictionary dictionary];
        vertexCache = [NSMutableDictionary dictionary];
    }
    return self;
}

+ (NKStaticDraw *)sharedInstance
{
    static dispatch_once_t _singletonPredicate;
    
    dispatch_once(&_singletonPredicate, ^{
        sharedObject = [[super alloc] init];
    });
    
    return sharedObject;
}

+(NSMutableDictionary*)meshesCache {
    return [[NKStaticDraw sharedInstance] meshesCache];
}


-(NSMutableDictionary*)meshesCache {
    return meshesCache;
}

+(NSMutableDictionary*)vertexCache {
    return [[NKStaticDraw sharedInstance] vertexCache];
}


-(NSMutableDictionary*)vertexCache {
    return vertexCache;
}

+(NSString*)stringForPrimitive:(NKPrimitive)primitive {
    
    switch (primitive) {
        case NKPrimitiveRect:
            return @"NKPrimitiveRect";
            break;
            
        case NKPrimitiveSphere:
            return @"NKPrimitiveSphere";
            break;
            
        case NKPrimitiveLODSphere:
            return @"NKPrimitiveLODSphere";
            break;
        
        case NKPrimitiveCube:
            return @"NKPrimitiveCube";
            break;
            
        case NKPrimitiveAxes:
            return @"NKPrimitiveAxes";
            break;
            
        default:
            return @"NKPrimitiveNone";
            break;
    }
    
}

+(NKVertexBuffer*)cachedPrimitive:(NKPrimitive)primitive {
    return [[NKStaticDraw sharedInstance] cachedPrimitive:primitive];
}

-(NKVertexBuffer*)cachedPrimitive:(NKPrimitive)primitive {
    if (!primitiveCache[primitive]) {
        primitiveCache[NKPrimitiveCube] = [NKVertexBuffer defaultCube];
    }
    return primitiveCache[primitive];
}

+(void)drawBoundingBoxForNode:(NKNode*)node{
    [[NKStaticDraw sharedInstance]drawBoundingBoxForNode:node];
}

-(void)drawBoundingBoxForNode:(NKNode*)node {
    if (!_boundingBoxMesh) {
        _boundingBoxMesh = [[NKMeshNode alloc]initWithPrimitive:NKPrimitiveCube texture:nil color:NKGREEN size:V3MakeF(1.)];
        _boundingBoxMesh.drawMode = GL_LINES;
    }
    _boundingBoxMesh.localTransformMatrix = node.localTransformMatrix;
    [_boundingBoxMesh customDraw];
}

@end