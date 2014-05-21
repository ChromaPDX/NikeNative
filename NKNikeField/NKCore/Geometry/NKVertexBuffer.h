//*
//*  NODE KITTEN
//*

#import <Foundation/Foundation.h>

typedef struct NKVertexArray{
    V3t vertex;
    V3t normal;
    V2t texCoord;
    C4t color;
} NKVertexArray;

typedef NS_ENUM(NSInteger, NKPrimitive) {
    NKPrimitiveNone,
    NKPrimitiveAxes,
    NKPrimitiveRect,
    NKPrimitiveCube,
    NKPrimitiveSphere
} NS_ENUM_AVAILABLE(10_9, 7_0);

@interface NKVertexBuffer : NSObject

- (id)initWithSize:(GLsizeiptr)size
              data:(const GLvoid *)data
             setup:(void(^)())geometrySetupBlock;

-(instancetype)initWithVertexData:(const GLvoid *)data ofSize:(GLsizeiptr)size;

+(instancetype)pointSprite;
+(instancetype)defaultCube;
+(instancetype)defaultRect;
+(instancetype)sphereWithStacks:(GLint)stacks slices:(GLint)slices squash:(GLfloat)squash;

+(instancetype)axes;

- (void)bind;
- (void)bind:(void(^)())drawingBlock;
- (void)unbind;

@property (nonatomic) GLsizei numberOfElements;

@end

@interface NKVertexElementBuffer : NSObject

- (id)initWithSize:(GLsizeiptr)size
              data:(const GLvoid *)data;
- (void)bind;
//- (void)bind:(void(^)())drawingBlock;
- (void)unbind;

@property (nonatomic) int numberOfElements;

@end
