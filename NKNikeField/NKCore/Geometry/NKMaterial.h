//*
//*  NODE KITTEN
//*

#import "NKpch.h"

@class NKTexture;

@interface NKMaterial : NSObject
{
	NSString			*name;
	C4t                 diffuse;
	C4t                 ambient;
	C4t                 specular;
	GLfloat				shininess;
	NKTexture           *texture;
}

@property (nonatomic, retain) NSString *name;

@property C4t diffuse;
@property C4t ambient;
@property C4t specular;
@property F1t shininess;

@property (nonatomic, retain) NKTexture *texture;

+ (id)defaultMaterial;
+ (id)materialsFromMtlFile:(NSString *)path;
- (id)initWithName:(NSString *)inName shininess:(F1t)inShininess diffuse:(C4t)inDiffuse ambient:(C4t)inAmbient specular:(C4t)inSpecular;
- (id)initWithName:(NSString *)inName shininess:(F1t)inShininess diffuse:(C4t)inDiffuse ambient:(C4t)inAmbient specular:(C4t)inSpecular texture:(NKTexture *)inTexture;

@end

@class NKMaterial;

@interface NKMaterialGroup : NSObject
{
}

@property (nonatomic, strong) NSString *name;
@property GLuint numberOfFaces;
@property UB3t *faces;

@property (nonatomic, retain) NKMaterial *material;

- (id)initWithName:(NSString *)inName
	 numberOfFaces:(GLuint)inNumFaces
		  material:(NKMaterial *)inMaterial;
@end
