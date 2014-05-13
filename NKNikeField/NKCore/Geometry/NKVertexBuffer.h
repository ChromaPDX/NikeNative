//*
//*  NODE KITTEN
//*

#import <Foundation/Foundation.h>

typedef struct NKVertexArray{
    V3t vertex;
    V3t normal;
    V2t texCoord;
  //  C4t color;
} NKVertexArray;

@interface NKVertexBuffer : NSObject

- (id)initWithSize:(GLsizeiptr)size
              data:(const GLvoid *)data
             setup:(void(^)())geometrySetupBlock;

-(instancetype)initWithVertexData:(const GLvoid *)data ofSize:(GLsizeiptr)size;

+(instancetype)defaultCube;
+(instancetype)defaultRect;
+(instancetype)sphereWithStacks:(GLint)stacks slices:(GLint)slices squash:(GLfloat)squash;

+(instancetype)axes;

- (void)bind;
- (void)bind:(void(^)())drawingBlock;
- (void)unbind;

@property (nonatomic) GLenum drawMode;
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
