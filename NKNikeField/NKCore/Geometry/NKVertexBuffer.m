//
//  NKAttributeBuffer.m
//  NKNikeField
//
//  Created by Leif Shackelford on 5/1/14.
//  Copyright (c) 2014 Chroma Developer. All rights reserved.
//

#import "NodeKitten.h"

@implementation NKVertexBuffer

{
    GLuint _vertexArray;
    GLuint _vertexBuffer;
}

- (id)initWithSize:(GLsizeiptr)size
              data:(const GLvoid *)data
             setup:(void(^)())geometrySetupBlock
{
    self = [super init];
    if ( self )
    {
        glEnable(GL_DEPTH_TEST);
        
        glGenVertexArraysOES(1, &_vertexArray);
        glBindVertexArrayOES(_vertexArray);
        
        glGenBuffers(1, &_vertexBuffer);
        glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
        
        glBufferData(GL_ARRAY_BUFFER,
                     size,
                     data,
                     GL_STATIC_DRAW);
        
        geometrySetupBlock();
        
        glBindBuffer(GL_ARRAY_BUFFER, 0);
        glBindVertexArrayOES(0);
    }
    return self;
}

+(instancetype)axes {

    GLfloat gCubeVertexData[7*6] =
    {
        -1.0f, 0.0f, 0.0f,      .5f, 0.0f, 0.0f, 1.0f,
        1.0f, 0.0f, 0.0f,       1.0f, 0.5f, 0.5f, 1.0f,
        0.0f, -1.0f, 0.0f,      0.0f, .5f, 0.0f, 1.0f,
        0.0f, 1.0f, 0.0f,       0.5f, 1.0f, 0.5f, 1.0f,
        0.0f, 0.0f, -1.0f,      0.0f, 0.0f, .5f, 1.0f,
        0.0f, 0.0f, 1.0f,       0.5f, 0.5f, 1.0f, 1.0f
    };
    
    NKVertexBuffer *buf = [[NKVertexBuffer alloc] initWithSize:sizeof(gCubeVertexData) data:gCubeVertexData setup:^{
        glEnableVertexAttribArray(NKVertexAttribPosition);
        glVertexAttribPointer(NKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE,
                              28, BUFFER_OFFSET(0));
        
        glEnableVertexAttribArray(NKVertexAttribColor);
        glVertexAttribPointer(NKVertexAttribColor, 3, GL_FLOAT, GL_FALSE,
                              28, BUFFER_OFFSET(12));
        
    }];
    
    buf.numberOfElements = sizeof(gCubeVertexData) / (sizeof(F1t)*7.);
    return buf;
}

+(instancetype)defaultRect {

    GLfloat gCubeVertexData[48] =
    {
        0.5f, 0.5f, 0.0f,          1.0f, 0.0f, 0.0f,        1.0f, 1.0f,
        -0.5f, 0.5f, 0.0f,         1.0f, 0.0f, 0.0f,        0.0f, 1.0f,
        0.5f, -0.5f, 0.0f,         1.0f, 0.0f, 0.0f,        1.0f, 0.0f,
        -0.5f, 0.5f, 0.0f,         1.0f, 0.0f, 0.0f,        0.0f, 1.0f,
        -0.5f, -0.5f, 0.0f,        1.0f, 0.0f, 0.0f,        0.0f, 0.0f,
        0.5f, -0.5f, 0.0f,         1.0f, 0.0f, 0.0f,        1.0f, 0.0f,
    };

    NKVertexBuffer *buf = [[NKVertexBuffer alloc] initWithSize:sizeof(gCubeVertexData) data:gCubeVertexData setup:^{
        glEnableVertexAttribArray(NKVertexAttribPosition);
        glVertexAttribPointer(NKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE,
                              32, BUFFER_OFFSET(0));
        
        glEnableVertexAttribArray(NKVertexAttribNormal);
        glVertexAttribPointer(NKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE,
                              32, BUFFER_OFFSET(12));
        
        glEnableVertexAttribArray(NKVertexAttribTexCoord0);
        glVertexAttribPointer(NKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE,
                              32, BUFFER_OFFSET(24));
        
    }];
    
    buf.numberOfElements = sizeof(gCubeVertexData) / (sizeof(F1t)*8.);
    return buf;
}

+(instancetype)defaultCube {
    GLfloat gCubeVertexData[216] =
    {
        // Data layout for each line below is:
        // positionX, positionY, positionZ,     normalX, normalY, normalZ,
        0.5f, -0.5f, -0.5f,        1.0f, 0.0f, 0.0f,
        0.5f, 0.5f, -0.5f,         1.0f, 0.0f, 0.0f,
        0.5f, -0.5f, 0.5f,         1.0f, 0.0f, 0.0f,
        0.5f, -0.5f, 0.5f,         1.0f, 0.0f, 0.0f,
        0.5f, 0.5f, -0.5f,         1.0f, 0.0f, 0.0f,
        0.5f, 0.5f, 0.5f,          1.0f, 0.0f, 0.0f,
        
        0.5f, 0.5f, -0.5f,         0.0f, 1.0f, 0.0f,
        -0.5f, 0.5f, -0.5f,        0.0f, 1.0f, 0.0f,
        0.5f, 0.5f, 0.5f,          0.0f, 1.0f, 0.0f,
        0.5f, 0.5f, 0.5f,          0.0f, 1.0f, 0.0f,
        -0.5f, 0.5f, -0.5f,        0.0f, 1.0f, 0.0f,
        -0.5f, 0.5f, 0.5f,         0.0f, 1.0f, 0.0f,
        
        -0.5f, 0.5f, -0.5f,        -1.0f, 0.0f, 0.0f,
        -0.5f, -0.5f, -0.5f,       -1.0f, 0.0f, 0.0f,
        -0.5f, 0.5f, 0.5f,         -1.0f, 0.0f, 0.0f,
        -0.5f, 0.5f, 0.5f,         -1.0f, 0.0f, 0.0f,
        -0.5f, -0.5f, -0.5f,       -1.0f, 0.0f, 0.0f,
        -0.5f, -0.5f, 0.5f,        -1.0f, 0.0f, 0.0f,
        
        -0.5f, -0.5f, -0.5f,       0.0f, -1.0f, 0.0f,
        0.5f, -0.5f, -0.5f,        0.0f, -1.0f, 0.0f,
        -0.5f, -0.5f, 0.5f,        0.0f, -1.0f, 0.0f,
        -0.5f, -0.5f, 0.5f,        0.0f, -1.0f, 0.0f,
        0.5f, -0.5f, -0.5f,        0.0f, -1.0f, 0.0f,
        0.5f, -0.5f, 0.5f,         0.0f, -1.0f, 0.0f,
        
        0.5f, 0.5f, 0.5f,          0.0f, 0.0f, 1.0f,
        -0.5f, 0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
        0.5f, -0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
        0.5f, -0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
        -0.5f, 0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
        -0.5f, -0.5f, 0.5f,        0.0f, 0.0f, 1.0f,
        
        0.5f, -0.5f, -0.5f,        0.0f, 0.0f, -1.0f,
        -0.5f, -0.5f, -0.5f,       0.0f, 0.0f, -1.0f,
        0.5f, 0.5f, -0.5f,         0.0f, 0.0f, -1.0f,
        0.5f, 0.5f, -0.5f,         0.0f, 0.0f, -1.0f,
        -0.5f, -0.5f, -0.5f,       0.0f, 0.0f, -1.0f,
        -0.5f, 0.5f, -0.5f,        0.0f, 0.0f, -1.0f
    };
    
    NKVertexBuffer *buf = [[NKVertexBuffer alloc] initWithSize:sizeof(gCubeVertexData) data:gCubeVertexData setup:^{
        glEnableVertexAttribArray(NKVertexAttribPosition);
        glVertexAttribPointer(NKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE,
                              24, BUFFER_OFFSET(0));
        
        glEnableVertexAttribArray(NKVertexAttribNormal);
        glVertexAttribPointer(NKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE,
                              24, BUFFER_OFFSET(12));
    }];

    buf.numberOfElements = sizeof(gCubeVertexData) / 6;
    
    return buf;
}

-(instancetype)initWithVertexData:(const GLvoid *)data ofSize:(GLsizeiptr)size {
    
    return [self initWithSize:size data:data setup:^{
        glEnableVertexAttribArray(NKVertexAttribPosition);
        glVertexAttribPointer(NKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE,
                              sizeof(V3t), BUFFER_OFFSET(0));
    }];

}

- (void)dealloc
{
    glDeleteBuffers(1, &_vertexBuffer);
    glDeleteVertexArraysOES(1, &_vertexArray);
}

- (void)bind
{
    glBindVertexArrayOES(_vertexArray);
}

- (void)bind:(void(^)())drawingBlock
{
    [self bind];
    drawingBlock();
    [self unbind];
}

- (void)unbind
{
    glBindVertexArrayOES(0);
}

@end


@implementation NKVertexElementBuffer
{
    GLuint _elementBuffer;
}

- (id)initWithSize:(GLsizeiptr)size
              data:(const GLvoid *)data
{
    self = [super init];
    if ( self )
    {
        glGenBuffers(1, &_elementBuffer);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _elementBuffer);
        glBufferData(GL_ELEMENT_ARRAY_BUFFER,
                     size,
                     data,
                     GL_STATIC_DRAW);
    }
    return self;
}

- (void)dealloc
{
    glDeleteBuffers(1, &_elementBuffer);
}

- (void)bind
{
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _elementBuffer);
}

- (void)bind:(void(^)())drawingBlock
{
    [self bind];
    drawingBlock();
    [self unbind];
}

- (void)unbind
{
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _elementBuffer);
}

@end

