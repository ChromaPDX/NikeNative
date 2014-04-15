//
//  NKMesh.h
//  nike3dField
//
//  Created by Chroma Developer on 3/24/14.
//
//

@class NKTexture;

typedef NS_ENUM(NSInteger, NKPrimitive) {
    NKPrimitiveNone,
    NKPrimitiveRect,
    NKPrimitiveSphere
} NS_ENUM_AVAILABLE(10_9, 7_0);

// This line should be uncommented to use the famous Quake / invsqrt optimization
// If this line is commented out, normalization will happen using standard sqrtf()
//#define USE_FAST_NORMALIZE

@interface NKMesh : NSObject {
	NSString			*sourceObjFilePath;
	NSString			*sourceMtlFilePath;
	
	GLuint				numberOfVertices;
	V3t                 *vertices;
	GLuint				numberOfFaces;			// Total faces in all groups
	
	V3t                 *surfaceNormals;		// length = numberOfFaces
	V3t                 *vertexNormals;			// length = numberOfFaces (*3 vertices per triangle);
    C4t                 *vertexColors;
    
	GLfloat				*textureCoords;

	GLubyte				valuesPerCoord;			// 1, 2, or 3, representing U, UV, or UVW mapping, could be 4 but OBJ doesn't support 4
	
	NSDictionary		*materials;
	NSMutableArray		*groups;
}

@property (nonatomic, retain) NSString *sourceObjFilePath;
@property (nonatomic, retain) NSString *sourceMtlFilePath;
@property (nonatomic, retain) NSDictionary *materials;
@property (nonatomic, retain) NSMutableArray *groups;
@property (nonatomic) NKPrimitive primitiveType;

- (instancetype) initWithPath:(NSString *)path;
- (instancetype) initWithPrimitive:(NKPrimitive)primitive;

- (void)drawSelf;

-(void) drawWithTexture:(NKTexture*)texture color:(C4t)color;
-(void) drawWithColor:(C4t)color;

@end
