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
    buf.drawMode = GL_TRIANGLES;
    return buf;
}

+(instancetype)sphereWithStacks:(GLint)stacks slices:(GLint)slices squash:(GLfloat)squash
{
    unsigned int colorIncrement = 0;
    unsigned int blue = 1.;
    unsigned int red = 1.;
    unsigned int green = 1.;
    
    colorIncrement = 1./stacks;
    
    float m_Scale = 1.;
    
    int numElements = (slices*2+2) * (stacks);
    
    // Vertices
    V3t *vertices = (V3t*)malloc(sizeof(V3t) * numElements);
    F1t *vPtr = (F1t*)&vertices[0];
    
    // Color
    C4t *vertexColors = (C4t*)malloc(sizeof(C4t) * numElements);
    F1t *cPtr = (F1t*)&vertexColors[0];
    
    // Normal pointers for lighting
    V3t *vertexNormals = (V3t*)malloc(sizeof(V3t) * numElements);
    F1t *nPtr = (F1t*)&vertexNormals[0];
    
    V2t *textureCoords = (V2t*)malloc(sizeof(V2t) * numElements);
    F1t *tPtr = (F1t*)&textureCoords[0];
    
    unsigned int phiIdx, thetaIdx;
    
    for(phiIdx = 0; phiIdx < stacks; phiIdx++)
    {
        //starts at -pi/2 goes to pi/2
        //the first circle
        float phi0 = M_PI * ((float)(phiIdx+0) * (1.0/(float)(stacks)) - 0.5);
        //second one
        float phi1 = M_PI * ((float)(phiIdx+1) * (1.0/(float)(stacks)) - 0.5);
        float cosPhi0 = cos(phi0);
        float sinPhi0 = sin(phi0);
        float cosPhi1 = cos(phi1);
        float sinPhi1 = sin(phi1);
        
        float cosTheta, sinTheta;
        //longitude
        for(thetaIdx = 0; thetaIdx < slices; thetaIdx++)
        {
            float theta = -2.0*M_PI * ((float)thetaIdx) * (1.0/(float)(slices - 1));
            cosTheta = cos(theta);
            sinTheta = sin(theta);
            
            //We're generating a vertical pair of points, such
            //as the first point of stack 0 and the first point of stack 1
            //above it. this is how triangle_strips work,
            //taking a set of 4 vertices and essentially drawing two triangles
            //at a time. The first is v0-v1-v2 and the next is v2-v1-v3, and so on.
            
            //get x-y-x of the first vertex of stack
            vPtr[0] = m_Scale*cosPhi0 * cosTheta;
            vPtr[1] = m_Scale*sinPhi0 * squash;
            vPtr[2] = m_Scale*(cosPhi0 * sinTheta);
            //the same but for the vertex immediately above the previous one.
            vPtr[3] = m_Scale*cosPhi1 * cosTheta;
            vPtr[4] = m_Scale*sinPhi1 * squash;
            vPtr[5] = m_Scale*(cosPhi1 * sinTheta);
            
            nPtr[0] = cosPhi0 * cosTheta;
            nPtr[1] = sinPhi0;
            nPtr[2] = cosPhi0 * sinTheta;
            nPtr[3] = cosPhi1 * cosTheta;
            nPtr[4] = sinPhi1;
            nPtr[5] = cosPhi1 * sinTheta;
            
            if(tPtr!=nil){
                GLfloat texX = (float)thetaIdx * (1.0f/(float)(slices-1));
                tPtr[0] = texX;
                tPtr[1] = (float)(phiIdx + 0) * (1.0f/(float)(stacks));
                tPtr[2] = texX;
                tPtr[3] = (float)(phiIdx + 1) * (1.0f/(float)(stacks));
            }
            
            cPtr[0] = red;
            cPtr[1] = green;
            cPtr[2] = blue;
            cPtr[4] = red;
            cPtr[5] = green;
            cPtr[6] = blue;
            cPtr[3] = cPtr[7] = 1.;
            
            cPtr += 2*4;
            vPtr += 2*3;
            nPtr += 2*3;
            
            if(tPtr != nil) tPtr += 2*2;
        }
        //        blue+=colorIncrement;
        //        red-=colorIncrement;
        
        //Degenerate triangle to connect stacks and maintain winding order
        
        vPtr[0] = vPtr[3] = vPtr[-3];
        vPtr[1] = vPtr[4] = vPtr[-2];
        vPtr[2] = vPtr[5] = vPtr[-1];
        
        nPtr[0] = nPtr[3] = nPtr[-3];
        nPtr[1] = nPtr[4] = nPtr[-2];
        nPtr[2] = nPtr[5] = nPtr[-1];
        
        if(tPtr != nil){
            tPtr[0] = tPtr[2] = tPtr[-2];
            tPtr[1] = tPtr[3] = tPtr[-1];
        }
        
    }
    
    NKVertexArray *elements = (NKVertexArray*)malloc(sizeof(NKVertexArray)*numElements);
    
    for (int i = 0; i < numElements; i++) {
        memcpy(&elements[i].vertex, &vertices[i], sizeof(V3t));
        memcpy(&elements[i].normal, &vertexNormals[i], sizeof(V3t));
        memcpy(&elements[i].texCoord, &textureCoords[i], sizeof(V2t));
       // memcpy(&elements[i].color, &vertexColors[i], sizeof(C4t));
    }
    
    free(vertices);
    free(vertexNormals);
    free(vertexColors);
    free(textureCoords);
    
    NSLog(@"V2t: %lu V3t: %lu V4t: %lu ", sizeof(V2t), sizeof(V3t), sizeof(V4t));
    NSLog(@"NKVertexArraySize: %lu", sizeof(NKVertexArray));
    
    NKVertexBuffer *buf = [[NKVertexBuffer alloc] initWithSize:sizeof(NKVertexArray)*numElements data:elements setup:^{
        glEnableVertexAttribArray(NKVertexAttribPosition);
        glVertexAttribPointer(NKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE,
                              sizeof(NKVertexArray), BUFFER_OFFSET(0));
        
        glEnableVertexAttribArray(NKVertexAttribNormal);
        glVertexAttribPointer(NKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE,
                              sizeof(NKVertexArray), BUFFER_OFFSET(sizeof(V3t)));
        
        glEnableVertexAttribArray(NKVertexAttribTexCoord0);
        glVertexAttribPointer(NKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE,
                              sizeof(NKVertexArray), BUFFER_OFFSET(sizeof(V3t)*2));

//        glEnableVertexAttribArray(NKVertexAttribColor);
//        glVertexAttribPointer(NKVertexAttribColor, 4, GL_FLOAT, GL_FALSE,
//                              sizeof(NKVertexArray), BUFFER_OFFSET(sizeof(V3t)*2+sizeof(V2t)));
    }];
    
    buf.numberOfElements = numElements;
    buf.drawMode = GL_TRIANGLE_STRIP;
    free(elements);
    
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
    buf.drawMode = GL_TRIANGLES;
    
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
