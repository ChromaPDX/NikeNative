//
//  NKBatchNode.h
//  EMA Stage
//
//  Created by Leif Shackelford on 5/24/14.
//  Copyright (c) 2014 EMA. All rights reserved.
//

#import "NKMeshNode.h"

@class NKShaderProgram;

@interface NKBatchNode : NKMeshNode
{
    GLuint spritesToDraw;
}
@property (nonatomic) NKMatrixStack *mvpStack;
@property (nonatomic) NKMatrixStack *mvStack;
@property (nonatomic) NKM9Stack *normalStack;
@property (nonatomic) NKVector4Stack *childColors;

@property (nonatomic) NKShaderProgram *hitShader;

@end
