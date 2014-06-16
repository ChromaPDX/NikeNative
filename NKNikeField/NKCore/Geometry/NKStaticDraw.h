//*
//*  NODE KITTEN
//*
#import "NKPch.h"
#import "NKVertexBuffer.h"

@class NKMeshNode;

@interface NKStaticDraw : NSObject
{
    NSMutableDictionary *meshesCache;
    NSMutableDictionary *vertexCache;
    NKVertexBuffer *primitiveCache[NKNumPrimitives];
}

+ (NKStaticDraw *)sharedInstance;
+ (NSMutableDictionary*) meshesCache;
+ (NSMutableDictionary*) vertexCache;
+ (NSMutableDictionary*) normalsCache;

+(NKVertexBuffer*)cachedPrimitive:(NKPrimitive)primitive;

+(NSString*)stringForPrimitive:(NKPrimitive)primitive;

@property (nonatomic, strong) NKMeshNode* boundingBoxMesh;

@end

@interface NKColor(OpenGL)
- (void)setOpenGLColor;
- (void)setColorArrayToColor:(NKColor *)toColor;
@end