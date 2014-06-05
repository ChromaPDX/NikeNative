//
//  NKBatchNode.m
//  EMA Stage
//
//  Created by Leif Shackelford on 5/24/14.
//  Copyright (c) 2014 EMA. All rights reserved.
//

#import "NodeKitten.h"

@implementation NKBatchNode

-(instancetype)initWithPrimitive:(NKPrimitive)primitive texture:(NKTexture *)texture color:(NKByteColor *)color size:(V3t)size {
    self = [super initWithPrimitive:primitive texture:texture color:color size:size];
    
    if (self) {
        
        _mvStack = [[NKMatrixStack alloc]init];
        _mvpStack = [[NKMatrixStack alloc]init];
        _normalStack = [[NKM9Stack alloc]init];
        _childColors = [[NKVector4Stack alloc]init];
        
    }
    
    return self;
}

-(instancetype)initWithObjNamed:(NSString *)name withSize:(V3t)size normalize:(bool)normalize {
    self = [super initWithObjNamed:name withSize:size normalize:normalize];
    if (self) {
        _mvStack = [[NKMatrixStack alloc]init];
        _mvpStack = [[NKMatrixStack alloc]init];
        _normalStack = [[NKM9Stack alloc]init];
        _childColors = [[NKVector4Stack alloc]init];
    }
    return self;
}


-(void)chooseShader{

    self.hitShader = [NKShaderProgram newShaderNamed:@"batchHitShader" colorMode:NKS_COLOR_MODE_UNIFORM numTextures:0 lightNodes:nil withBatchSize:NK_BATCH_SIZE];
    
    if (_color && self.texture && ![_color isEqual:NKWHITE]) {
        self.shader = [NKShaderProgram newShaderNamed:@"batchColorTextureShader" colorMode:NKS_COLOR_MODE_UNIFORM numTextures:1 lightNodes:self.scene.lights withBatchSize:NK_BATCH_SIZE];
    }
    else if (self.texture) {
        self.shader = [NKShaderProgram newShaderNamed:@"batchTextureShader" colorMode:NKS_COLOR_MODE_NONE numTextures:1 lightNodes:self.scene.lights withBatchSize:NK_BATCH_SIZE];
    }
    else if (_color) {
        self.shader = [NKShaderProgram newShaderNamed:@"batchColorShader" colorMode:NKS_COLOR_MODE_UNIFORM numTextures:0 lightNodes:self.scene.lights withBatchSize:NK_BATCH_SIZE];
    }
    
}

-(void)draw {
   
    [self begin];
    
    [self pushStyle];
    
    [self customDraw];
    
    //NSLog(@"shader: %@",self.scene.activeShader.name);
    
    [self end];
}

-(void)customDraw {
    
    
    self.scene.activeShader = self.shader;
    
    bool useColor = false;
    
    if (self.scene.boundVertexBuffer != self.vertexBuffer) {
        [self.vertexBuffer bind];
        self.scene.boundVertexBuffer = self.vertexBuffer;
    }
    
    if ([self.scene.activeShader uniformNamed:NKS_V4_COLOR]) {
        useColor = true;
    }
    
    if ([self.scene.activeShader uniformNamed:NKS_S2D_TEXTURE]) {
        if (self.texture) {
            if (self.scene.boundTexture != self.texture) {
                [self.texture bind];
                self.scene.boundTexture = self.texture;
            }
        }
    }
    
    [_mvpStack reset];
    [_mvStack reset];
    [_childColors reset];
    [_normalStack reset];
    
    int spritesInBatch = 0;
    
    for (int i = 0; i < intChildren.count; i++) {
        
        NKNode *child = intChildren[i];
        
        M16t modelView = M16Multiply(self.scene.camera.viewMatrix,M16Multiply(self.scene.stack.currentMatrix,M16ScaleWithV3(child.localTransformMatrix, child.size3d)));
        M16t mvp = M16Multiply(self.scene.camera.projectionMatrix,modelView);
        
        [_mvStack pushMatrix:modelView];
        
        [_normalStack pushMatrix:M16GetInverseNormalMatrix(modelView)];
        [_mvpStack pushMatrix:mvp];

        if (useColor) {
            [_childColors pushVector:child.color.C4Color];
        }
        spritesInBatch++;
        
        if (spritesInBatch == NK_BATCH_SIZE || i == intChildren.count - 1) {
            
            [self drawGeometry:spritesInBatch useColor:useColor];
            
            [_mvpStack reset];
            [_mvStack reset];
            [_normalStack reset];
            [_childColors reset];
            spritesInBatch = 0;
            
        }
    }
    
    //NSLog(@"%d children, %d batches", intChildren.count, intChildren.count/NK_BATCH_SIZE);
    
}


-(void)drawWithHitShader {
    
    NKShaderProgram *temp = self.scene.hitDetectShader;
    
    self.scene.activeShader = self.hitShader;
    
    if (self.scene.boundVertexBuffer != self.vertexBuffer) {
        [self.vertexBuffer bind];
        self.scene.boundVertexBuffer = self.vertexBuffer;
    }
    
    [_mvpStack reset];
    [_mvStack reset];
    [_childColors reset];
    int spritesInBatch = 0;
    
    for (int i = 0; i < intChildren.count; i++) {
        NKNode *child = intChildren[i];
        
        [_mvpStack pushMatrix:M16Multiply(self.scene.camera.viewProjectionMatrix, M16Multiply(self.scene.stack.currentMatrix,M16ScaleWithV3(child.localTransformMatrix, child.size3d)))];
        [_childColors pushVector:child.uidColor.C4Color];
        
        spritesInBatch++;
        
        if (spritesInBatch == NK_BATCH_SIZE || i == intChildren.count - 1) {
            
            [self drawGeometry:spritesInBatch useColor:true];
            
            [_mvpStack reset];
            [_mvStack reset];
            [_childColors reset];
            spritesInBatch = 0;
            
        }
    }
    
    self.scene.activeShader = temp;
    [self.scene.activeShader use];
}


-(void)drawGeometry:(int)spritesInBatch useColor:(bool)useColor{
    
    [[self.scene.activeShader uniformNamed:NKS_M16_MV] bindM16Array:_mvStack.data count:spritesInBatch];
    
    [[self.scene.activeShader uniformNamed:NKS_M16_MVP] bindM16Array:_mvpStack.data count:spritesInBatch];
    
    [[self.scene.activeShader uniformNamed:NKS_M9_NORMAL] bindM9Array:_normalStack.data count:spritesInBatch];
    
    
    if (useColor) {
        [[self.scene.activeShader uniformNamed:NKS_V4_COLOR] bindV4Array:_childColors.data count:spritesInBatch];
    }
    
    if (self.primitiveType == NKPrimitiveLODSphere) {
#if TARGET_OS_IPHONE
        glDrawArraysInstancedEXT(self.drawMode, self.vertexBuffer.elementOffset[0], self.vertexBuffer.elementSize[0], spritesInBatch);
#else
        glDrawArraysInstancedARB(self.drawMode, self.vertexBuffer.elementOffset[0], self.vertexBuffer.elementSize[0], spritesInBatch);
#endif
    }
    else {
#if TARGET_OS_IPHONE
        glDrawArraysInstancedEXT(self.drawMode, 0, self.vertexBuffer.numberOfElements, spritesInBatch);
#else
        glDrawArraysInstancedARB(self.drawMode, 0, self.vertexBuffer.numberOfElements, spritesInBatch);
#endif
    }
    
    
}


//NSLog(@"batch children: %d, numPasses %d, lastPass ch %d", childCount, numPasses, lastPass);



//-(void)updateWithTimeSinceLast:(F1t)dt {
//    [animationHandler updateWithTimeSinceLast:dt];
//}

@end
