//
//  NKLightNode.h
//  EMA Stage
//
//  Created by Leif Shackelford on 5/26/14.
//  Copyright (c) 2014 EMA. All rights reserved.
//

#import "NKNode.h"
#import "NKShaderProgram.h"

@interface NKLightNode : NKMeshNode
{
    //struct NKLightProperties properties;
   // NKMeshNode *drawSphere;
}

-(instancetype)initWithColor:(NKByteColor*)color;
-(instancetype)initWithProperties:(NKLightProperties)properties;

@property (nonatomic) NKLightProperties properties;
-(NKLightProperties*)pointer;

@end
