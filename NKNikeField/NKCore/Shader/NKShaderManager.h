//
//  NKShaderManager.h
//  EMA Stage
//
//  Created by Leif Shackelford on 5/24/14.
//  Copyright (c) 2014 EMA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NKPch.h"

@class NKShaderProgram;

@interface NKShaderManager : NSObject
{
    NSMutableDictionary *programCache;
    NSMutableDictionary *uidColors;
}

+ (NKShaderManager *)sharedInstance;
+ (NSMutableDictionary*) programCache;
+ (NSMutableDictionary*) uidColors;

+(void)newUIDColorForNode:(NKNode*)node;
+(NKNode*)nodeForColor:(NKByteColor*)color;

@end

