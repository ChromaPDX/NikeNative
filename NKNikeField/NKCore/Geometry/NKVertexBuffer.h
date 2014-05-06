//
//  NKAttributeBuffer.h
//  NKNikeField
//
//  Created by Leif Shackelford on 5/1/14.
//  Copyright (c) 2014 Chroma Developer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NKVertexBuffer : NSObject

- (id)initWithSize:(GLsizeiptr)size
              data:(const GLvoid *)data
             setup:(void(^)())geometrySetupBlock;
-(instancetype)initWithVertexData:(const GLvoid *)data ofSize:(GLsizeiptr)size;

+(instancetype)defaultCube;
+(instancetype)defaultRect;

- (void)bind;
- (void)bind:(void(^)())drawingBlock;
- (void)unbind;

@property (nonatomic) int numberOfElements;

@end

@interface NKVertexElementBuffer : NSObject

- (id)initWithSize:(GLsizeiptr)size
              data:(const GLvoid *)data;
- (void)bind;
- (void)bind:(void(^)())drawingBlock;
- (void)unbind;

@property (nonatomic) int numberOfElements;

@end
