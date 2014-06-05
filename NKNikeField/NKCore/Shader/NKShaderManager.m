//
//  NKShaderManager.m
//  EMA Stage
//
//  Created by Leif Shackelford on 5/24/14.
//  Copyright (c) 2014 EMA. All rights reserved.
//

#import "NodeKitten.h"

@implementation NKShaderManager

static NKShaderManager *sharedObject = nil;

-(instancetype)init {
    self = [super init];
    if (self) {
        programCache = [NSMutableDictionary dictionary];
        uidColors = [NSMutableDictionary dictionary];
        NSLog(@"shader manager loaded");
    }
    
    return self;
}

+ (NKShaderManager *)sharedInstance
{
    static dispatch_once_t _singletonPredicate;
    
    dispatch_once(&_singletonPredicate, ^{
        sharedObject = [[super alloc] init];
    });
    
    return sharedObject;
}

+(NSMutableDictionary*)programCache {
    return [[NKShaderManager sharedInstance] programCache];
}

-(NSMutableDictionary*)programCache {
    return programCache;
}

+(NSMutableDictionary*)uidColors {
    return [[NKShaderManager sharedInstance] programCache];
}

-(NSMutableDictionary*)uidColors {
    return uidColors;
}

+(NKNode*)nodeForColor:(NKByteColor*)color {
    return [[[NKShaderManager sharedInstance] uidColors] objectForKey:color];
}

+(void)newUIDColorForNode:(NKNode*)node {
     [[NKShaderManager sharedInstance] newUIDColorForNode:node];
}

-(void)newUIDColorForNode:(NKNode*)node {
    
    NKByteColor *color;
    
    while (!color) {
        NKByteColor *test = [NKByteColor colorWithRed:arc4random() % 255 green:arc4random() % 255 blue:arc4random() % 255 alpha:255];
        if (![uidColors objectForKey:test]) {
            color = test;
            node.uidColor = test;
            [uidColors setObject:node forKey:node.uidColor];
        }
    }
}



@end


